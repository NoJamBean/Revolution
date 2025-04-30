resource "azurerm_resource_group" "main" {
  name     = "rg-webserver"
  location = "Korea Central"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-webserver"
  address_space       = ["10.2.0.0/16"] # Azure쪽 대역 (AWS에서 Static Route 등록했던 그거)
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-webapp"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.2.1.0/24"]
}

# vpn gateway용 서브넷

resource "azurerm_subnet" "gateway_subnet" {
  name                 = "GatewaySubnet" # 이름 수정 불가
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.2.2.0/24"] #["10.2.254.0/27"]
}

resource "azurerm_service_plan" "asp" {
  name                = "asp-appserviceplan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "S1"
  os_type             = "Linux" # 또는 "Windows"
}

resource "azurerm_app_service" "app_service" {
  name                = "app-service-webapp"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_service_plan.asp.id
  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DOCKER_REGISTRY_SERVER_URL"          = "https://index.docker.io"
    "WEBSITES_CONTAINER_START_TIME_LIMIT" = "1800"
    "WEBSITES_PORT"                       = "3000"
    "PORT"                                = "3000" # Next.js 기본 포트
  }

  site_config {
    linux_fx_version = "DOCKER|yourdockerhub/nextjs-app:latest"
    always_on        = true
    app_command_line = "" # CMD는 Dockerfile에 정의됨
  }

  tags = {
    environment = "production"
  }
}

resource "azurerm_monitor_autoscale_setting" "autoscale" {
  name                = "autoscale-webapp"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  target_resource_id  = azurerm_service_plan.asp.id
  enabled             = true

  profile {
    name = "default"

    capacity {
      minimum = "1"
      maximum = "3"
      default = "1"
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.asp.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_app_service.app_service.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 30
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }

  notification {
    email {
      send_to_subscription_administrator    = true
      send_to_subscription_co_administrator = false
    }
  }
}

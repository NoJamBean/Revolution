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

resource "azurerm_service_plan" "asp" {
  name                = "asp-appserviceplan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "S1"
  os_type             = "Linux" # 또는 "Windows"
}

resource "azurerm_app_service" "app_service" {
  name                     = "app-service-webapp"
  location                 = azurerm_resource_group.main.location
  resource_group_name      = azurerm_resource_group.main.name
  app_service_plan_id      = azurerm_service_plan.asp.id
  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE"     = "false"
    "DOCKER_REGISTRY_SERVER_URL"              = "https://index.docker.io"
    "WEBSITES_CONTAINER_START_TIME_LIMIT"     = "1800"
    "WEBSITES_PORT"                           = "3000"
    "PORT"                                    = "3000" # Next.js 기본 포트
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
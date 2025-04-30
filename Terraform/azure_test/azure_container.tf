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

resource "azurerm_app_service_custom_hostname_binding" "custom_domain" {
  hostname            = "www.1bean.shop"
  app_service_name    = azurerm_app_service.app_service.name
  resource_group_name = azurerm_resource_group.main.name
}
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
    "DOCKER_REGISTRY_SERVER_USERNAME"         = var.dockerhub_username
    "DOCKER_REGISTRY_SERVER_PASSWORD"         = var.dockerhub_password
    "WEBSITES_CONTAINER_START_TIME_LIMIT"     = "1800"
    "WEBSITES_PORT"                           = "3000"
    "PORT"                                    = "3000" # Next.js 기본 포트
  }

  site_config {
    linux_fx_version = "DOCKER|kindread11/totoro:latest"
    always_on        = true
    app_command_line = "" # CMD는 Dockerfile에 정의됨
  }

  https_only = true  # 기본 도메인에서 HTTPS를 강제 적용

  tags = {
    environment = "production"
  }
}

# SSL 인증서 생성 (Azure 무료 인증서)
resource "azurerm_app_service_managed_certificate" "ssl" {
  custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.custom_domain.id
}

# 생성된 인증서를 웹앱에 바인딩
resource "azurerm_app_service_ssl_binding" "ssl_binding" {
  hostname_binding_id = azurerm_app_service_custom_hostname_binding.custom_domain.id
  certificate_id      = azurerm_app_service_managed_certificate.ssl.id
  ssl_state           = "SniEnabled"
}

resource "azurerm_app_service_custom_hostname_binding" "custom_domain" {
  hostname            = "www.1bean.shop"
  app_service_name    = azurerm_app_service.app_service.name
  resource_group_name = azurerm_resource_group.main.name
}
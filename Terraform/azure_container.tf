resource "azurerm_service_plan" "asp" {
  name                = "asp-appserviceplan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "S1"
  os_type             = "Linux" # 또는 "Windows"
}

resource "azurerm_linux_web_app" "app_service" {
  name                     = "app-service-webapp"
  location                 = azurerm_resource_group.main.location
  resource_group_name      = azurerm_resource_group.main.name
  service_plan_id          = azurerm_service_plan.asp.id
  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE"     = "false"
    "WEBSITES_CONTAINER_START_TIME_LIMIT"     = "1800"
    "WEBSITES_PORT"                           = "3000"
    "PORT"                                    = "3000" # Next.js 기본 포트
  }

  site_config {
    always_on        = true
    app_command_line = "" # CMD는 Dockerfile에 정의됨

    application_stack {
      docker_image_name        = "wonbinjung/nextjs-app:latest"  # Docker Hub 이미지
      docker_registry_url      = "https://index.docker.io"       # Docker Hub URL
      docker_registry_username = var.dockerhub_username          # Docker Hub 사용자명
      docker_registry_password = var.dockerhub_password          # Docker Hub 비밀번호
    }
  }

  https_only = true  # 기본 도메인에서 HTTPS를 강제 적용

  tags = {
    environment = "production"
  }
}

# Staging 슬롯 생성
resource "azurerm_linux_web_app_slot" "staging_slot" {
  name                = "staging"
  app_service_id = azurerm_linux_web_app.app_service.id

  site_config {
    always_on        = false
    app_command_line = "" # CMD는 Dockerfile에 정의됨

    application_stack {
      docker_image_name        = "wonbinjung/nextjs-app:latest"  # Docker Hub 이미지
      docker_registry_url      = "https://index.docker.io"       # Docker Hub URL
      docker_registry_username = var.dockerhub_username          # Docker Hub 사용자명
      docker_registry_password = var.dockerhub_password          # Docker Hub 비밀번호
    }
  }
}

# SSL 인증서 생성 (Azure 무료 인증서)
# resource "azurerm_app_service_managed_certificate" "ssl" {
#   custom_hostname_binding_id = azurerm_app_service.app_service.id  # 기본 도메인에 대한 바인딩 ID
# }

# # 생성된 인증서를 웹앱에 바인딩
# resource "azurerm_app_service_ssl_binding" "ssl_binding" {
#   hostname_binding_id = azurerm_app_service.app_service.id  # 기본 도메인에 대한 바인딩 ID
#   certificate_id      = azurerm_app_service_managed_certificate.ssl.id
#   ssl_state           = "SniEnabled"  # SNI 기반 SSL 사용
# }
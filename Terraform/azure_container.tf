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
    auto_swap_slot = "staging"
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE"     = "false"
    "WEBSITES_CONTAINER_START_TIME_LIMIT"     = "1800"
    "WEBSITES_PORT"                           = "3000"
    "PORT"                                    = "3000" # Next.js 기본 포트
    "WEBSITES_VNET_ROUTE_ALL"                 = "1" # 모든 트래픽이 VNet을 통해 라우팅되도록 설정
    "WEBSITE_DNS_SERVER"                     = "10.0.100.10,10.0.15.10"
  }

  site_config {
    vnet_route_all_enabled = true
    always_on        = true
    app_command_line = "" # CMD는 Dockerfile에 정의됨
    websockets_enabled = true
    
    application_stack {
      docker_image_name        = "wonbinjung/nextjs-app:latest"  # Docker Hub 이미지
      docker_registry_url      = "https://index.docker.io"       # Docker Hub URL
      docker_registry_username = var.dockerhub_username          # Docker Hub 사용자명
      docker_registry_password = var.dockerhub_password          # Docker Hub 비밀번호
    }
  }

  virtual_network_subnet_id = azurerm_subnet.subnet.id
  
  https_only = true  # 기본 도메인에서 HTTPS를 강제 적용

  tags = {
    environment = "production"
  }
}

# Staging 슬롯 생성
resource "azurerm_linux_web_app_slot" "staging_slot" {
  name                = "staging"
  app_service_id      = azurerm_linux_web_app.app_service.id
  virtual_network_subnet_id = azurerm_subnet.subnet.id

  app_settings = {
    auto_swap_slot = "staging"
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "WEBSITES_CONTAINER_START_TIME_LIMIT" = "1800"
    "WEBSITES_PORT"                       = "3000"
    "PORT"                                = "3000"
    "WEBSITES_VNET_ROUTE_ALL"            = "1"
    "WEBSITE_DNS_SERVER"                 = "10.0.100.10,10.0.15.10"
  }

  site_config {
    always_on        = true
    app_command_line = ""
    websockets_enabled = true

    application_stack {
      docker_image_name        = "wonbinjung/nextjs-app:latest"
      docker_registry_url      = "https://index.docker.io"
      docker_registry_username = var.dockerhub_username
      docker_registry_password = var.dockerhub_password
    }
  }

  tags = {
    environment = "staging"
  }
}

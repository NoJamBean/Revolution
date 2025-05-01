locals {
  timestamp_value = format("%s", timestamp())
}

resource "azurerm_logic_app_workflow" "main" {
  name                = "main-logic-app"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  workflow_schema     = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"

  # Logic Apps 정의 (메트릭 가져오기 및 S3로 데이터 전송)
  workflow_parameters = {
    subscription_id      = "29ec5d86-72b1-4f74-9d88-711d967e3b86",
    resource_group_name  = azurerm_resource_group.main.name,
    app_service_name     = azurerm_linux_web_app.app_service.name,
    metric_names         = "CpuPercentage,Requests,MemoryUsage",
    bucket_name          = "bet-application-total-logs",
    s3_key_prefix        = "azure/metrics_${local.timestamp_value}.json"
  }
}
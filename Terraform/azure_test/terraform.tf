terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0" # 필요한 버전으로 조정 가능
    }
  }
}

# azure용 provider
provider "azurerm" {
  features {}
  subscription_id = "29ec5d86-72b1-4f74-9d88-711d967e3b86"
}
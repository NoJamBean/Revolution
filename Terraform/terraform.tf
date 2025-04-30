terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.90.1"
    }
  }

  backend "s3" {
    bucket         = "tfstate-bucket-revolution112233"
    key            = "prod/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

provider "aws" {
  alias  = "singapore"
  region = "ap-southeast-1"
}

# azure용 provider
provider "azurerm" {
  features {}
  subscription_id = "29ec5d86-72b1-4f74-9d88-711d967e3b86"
}



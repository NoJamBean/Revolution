# Terraform 및 AWS Provider 설정
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # 필요에 따라 버전 조정
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region # 사용할 AWS 리전 (variables.tf 에서 정의)
}

# 현재 AWS 계정 ID 가져오기 (리소스 ARN 등에 사용)
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# 코드 재사용률이 높거나, Production과 Staging 환경을 다르게 설정할 변수만 등록


variable "aws_region" { default = "ap-northeast-2" }
variable "db_username" { 
  default = "admin" 
  sensitive   = true
  }
variable "db_password" { 
  default = "securepassword123"
  sensitive   = true
  }
variable "db_allocated_storage" { default = 20 }
variable "seoul_key_name" { default = "temp" }
variable "instance_type" { default = "t2.micro" }
variable "agwlog_role_arn" { default = "arn:aws:iam::248189921892:role/agwlog" }
variable "private_domain_name" { default = "backend.internal" } # 원하는 도메인명으로 변경
variable "public_domain_name" { default = "1bean.shop" }      # 원하는 도메인명으로 변경
variable "api_dns" { default = "api.backend.internal" }
variable "rds_dns" { default = "db.backend.internal" }
variable "github_branch" { default = "web" }

variable "zone" {
  type = map(string)
  default = {
    a = "ap-northeast-2a",
    b = "ap-northeast-2b",
    c = "ap-northeast-2c",
    d = "ap-northeast-2d"
  }
}

variable "egress_rules" {
  type = map(object({ port = number, protocol = string, cidr = list(string) }))
  default = {
    all = { port = 0, protocol = "-1", cidr = ["0.0.0.0/0"] }
  }
}


# # 배포 시 git repo 접근 권한용 토큰값
# variable "seop_github_token" {
#   description = "GitHub PAT"
#   type        = string
#   sensitive   = true
# }



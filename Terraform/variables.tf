# 코드 재사용률이 높거나, Production과 Staging 환경을 다르게 설정할 변수만 등록


variable "aws_region" { default = "ap-northeast-2" }
variable "db_username" { default = "admin" }
variable "db_password" { default = "securepassword123" }
variable "db_allocated_storage" { default = 20 }
variable "seoul_key_name" { default = "temp" }
variable "instance_type" { default = "t2.micro" }
variable "agwlog_role_arn" { default = "arn:aws:iam::248189921892:role/agwlog"}
variable "private_domain_name" { default = "backend" } # 원하는 도메인명으로 변경
variable "public_domain_name" { default = "frontend" } # 원하는 도메인명으로 변경

variable "zone" {
  type = map(string)
  default = {
    a = "ap-northeast-2a",
    c = "ap-northeast-2c"
  }
}

variable "egress_rules" {
  type = map(object({ port = number, protocol = string, cidr = list(string) }))
  default = {
    all    = { port = 0,   protocol = "-1", cidr = ["0.0.0.0/0"] }
  }
}
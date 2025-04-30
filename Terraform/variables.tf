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
variable "singapore_key_name" { default = "sptemp" }
variable "instance_type" { default = "t2.micro" }
variable "agwlog_role_arn" { default = "arn:aws:iam::248189921892:role/agwlog" }
variable "private_domain_name" { default = "backend.internal" } # 원하는 도메인명으로 변경
variable "public_domain_name" { default = "1bean.shop" }      # 원하는 도메인명으로 변경
variable "api_dns" { default = "api.backend.internal" }
variable "rds_dns" { default = "db.backend.internal" }
variable "github_branch" { default = "web" }
variable "dockerhub_username" { default = "kindread11"}
variable "dockerhub_password" {
  default = "dckr_pat_-rttjRaQs18PiA08JfGU8kXqQwo"
  sensitive = true
  }
variable "acm_arn"{ 
  default = "arn:aws:acm:ap-northeast-2:248189921892:certificate/25ce65ee-1992-49ed-bb57-8501fc778d0c"
 sensitive = true
 }

variable "zone" {
  type = map(string)
  default = {
    a = "ap-northeast-2a",
    b = "ap-northeast-2b",
    c = "ap-northeast-2c",
    d = "ap-northeast-2d"
  }
}

variable "sin_zone" {
  type = map(string)
  default = {
    "a" = "ap-southeast-1a"
    "b" = "ap-southeast-1b"
    "c" = "ap-southeast-1c"
  }
}

variable "egress_rules" {
  type = map(object({ port = number, protocol = string, cidr = list(string) }))
  default = {
    all = { port = 0, protocol = "-1", cidr = ["0.0.0.0/0"] }
  }
}



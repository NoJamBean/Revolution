# 코드 재사용률이 높거나, Production과 Staging 환경을 다르게 설정할 변수만 등록

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


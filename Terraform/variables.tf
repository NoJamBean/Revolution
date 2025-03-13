variable "zone" {
  type = map(string)
  default = {
    a = "ap-northeast-2a",
    c = "ap-northeast-2c"
  }
}

variable "subnets" {
  type = map(object({ cidr = string, zone = string }))
  default = {
    sn1 = { cidr = "10.0.1.0/24", zone = var.zone["a"] }
    sn2 = { cidr = "10.0.2.0/24", zone = var.zone["c"] }
    sn3 = { cidr = "10.0.3.0/24", zone = var.zone["a"] }
    sn4 = { cidr = "10.0.4.0/24", zone = var.zone["c"] }
  }
}

variable "route_table_associations" {
  type = map(object({ route_table_id = string, subnet_id = string }))
  default = {
    asn1 = { route_table_id = "rt1", subnet_id = "sn1" }
    asn2 = { route_table_id = "rt1", subnet_id = "sn2" }
    asn3 = { route_table_id = "rt2", subnet_id = "sn3" }
    asn4 = { route_table_id = "rt2", subnet_id = "sn4" }
  }
}

variable "ingress_rules" {
  type = map(object({ port = number, protocol = string, cidr = list(string) }))
  default = {
    ssh    = { port = 22,   protocol = "tcp", cidr = ["0.0.0.0/0"] }
    http   = { port = 80,   protocol = "tcp", cidr = ["0.0.0.0/0"] }
    https  = { port = 443,  protocol = "tcp", cidr = ["0.0.0.0/0"] }
    mysql  = { port = 3306, protocol = "tcp", cidr = ["0.0.0.0/0"] }
    api    = { port = 5000, protocol = "tcp", cidr = ["0.0.0.0/0"] }
  }
}


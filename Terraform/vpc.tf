# aws_vpc.vpc 10.0.0.0/16
# aws_subnet.subnet[sn1-4] 10.0.[1-4].0/24
# aws_internet_gateway.igw aws_vpc.vpc

# VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "totoro"
  }
}

# Subnet
resource "aws_subnet" "subnet" {
  for_each = {
    app1 = {cidr_block="10.0.10.0/24",availability_zone=var.zone["a"], map_public_ip_on_launch = true } #앱 서버 1
    app2 = {cidr_block="10.0.11.0/24",availability_zone=var.zone["c"], map_public_ip_on_launch = true } #앱 서버 2
    nat1 = {cidr_block="10.0.20.0/24",availability_zone=var.zone["a"], map_public_ip_on_launch = true } #NAT1
    nat2 = {cidr_block="10.0.21.0/24",availability_zone=var.zone["c"], map_public_ip_on_launch = true } #NAT2
    api1 = {cidr_block="10.0.100.0/24",availability_zone=var.zone["a"], map_public_ip_on_launch = false } #백 서버 1
    api2 = {cidr_block="10.0.101.0/24",availability_zone=var.zone["c"], map_public_ip_on_launch = false } #백 서버 2
    rds1 = {cidr_block="10.0.50.0/24",availability_zone=var.zone["a"], map_public_ip_on_launch = false } #DB 서버 1
    rds2 = {cidr_block="10.0.51.0/24",availability_zone=var.zone["c"], map_public_ip_on_launch = false } #DB 서버 2
    log1 = {cidr_block="10.0.200.0/24",availability_zone=var.zone["a"], map_public_ip_on_launch = false } #LOG 1
    log2 = {cidr_block="10.0.201.0/24",availability_zone=var.zone["a"], map_public_ip_on_launch = false } #LOG 2
    log3 = {cidr_block="10.0.202.0/24",availability_zone=var.zone["c"], map_public_ip_on_launch = false } #LOG 3
    log4 = {cidr_block="10.0.203.0/24",availability_zone=var.zone["c"], map_public_ip_on_launch = false } #LOG 4
  }
  vpc_id     = aws_vpc.vpc.id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip_on_launch
  tags = {
    Name = each.key
  }
}

# RDS 서브넷 그룹 생성
# 정원빈 수정
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.subnet["rds1"].id, aws_subnet.subnet["rds2"].id]
  tags       = { Name = "RDS Subnet Group" }
}

#Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "vpc-igw"
    # 수정자 : 김주관 031310 / MMDDHH
    # 수정 코드 :
    # Name = "vpc-igw" -> Name = "vpc-internet"
    # 수정 사유 : 이름이 꼴받음
  }
}

# 라우트 테이블
resource "aws_route_table" "routetable" {
  for_each = {
    app = {}
    nat = {}
    back1 = {}
    back2 = {}
    log1 = {}
    log2 = {}
  }
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = each.key
  }
}

# 기본 라우트 테이블 설정
resource "aws_route" "internet_access" {
  for_each = {
    rt1 = aws_route_table.routetable["app"].id
    rt2 = aws_route_table.routetable["nat"].id
  }
  route_table_id         = each.value
  destination_cidr_block = "0.0.0.0/0"  # 모든 트래픽
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "nat_instance_route" {
  for_each = {
    rt3 = { rt_id = aws_route_table.routetable["back1"].id, eni = aws_instance.nat_instance1.primary_network_interface_id }
    rt4 = { rt_id = aws_route_table.routetable["back2"].id, eni = aws_instance.nat_instance2.primary_network_interface_id }
    rt5 = { rt_id = aws_route_table.routetable["log1"].id, eni = aws_instance.nat_instance1.primary_network_interface_id }
    rt6 = { rt_id = aws_route_table.routetable["log2"].id, eni = aws_instance.nat_instance2.primary_network_interface_id }
  }

  route_table_id         = each.value.rt_id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = each.value.eni
}

# 서브넷과 라우트 테이블 연결
resource "aws_route_table_association" "routetable_association" {
    for_each = {
      app1 = {route_table_id=aws_route_table.routetable["app"].id, subnet_id=aws_subnet.subnet["app1"].id}
      app2 = {route_table_id=aws_route_table.routetable["app"].id, subnet_id=aws_subnet.subnet["app2"].id}
      nat1 = {route_table_id=aws_route_table.routetable["nat"].id, subnet_id=aws_subnet.subnet["nat1"].id}
      nat2 = {route_table_id=aws_route_table.routetable["nat"].id, subnet_id=aws_subnet.subnet["nat2"].id}
      api1 = {route_table_id=aws_route_table.routetable["back1"].id, subnet_id=aws_subnet.subnet["api1"].id}
      api2 = {route_table_id=aws_route_table.routetable["back2"].id, subnet_id=aws_subnet.subnet["api2"].id}
      rds1 = {route_table_id=aws_route_table.routetable["back1"].id, subnet_id=aws_subnet.subnet["rds1"].id}
      rds2 = {route_table_id=aws_route_table.routetable["back2"].id, subnet_id=aws_subnet.subnet["rds2"].id}
      log1 = {route_table_id=aws_route_table.routetable["log1"].id, subnet_id=aws_subnet.subnet["log1"].id}
      log2 = {route_table_id=aws_route_table.routetable["log1"].id, subnet_id=aws_subnet.subnet["log2"].id}
      log3 = {route_table_id=aws_route_table.routetable["log2"].id, subnet_id=aws_subnet.subnet["log3"].id}
      log4 = {route_table_id=aws_route_table.routetable["log2"].id, subnet_id=aws_subnet.subnet["log4"].id}
    }
  route_table_id = each.value.route_table_id
  subnet_id = each.value.subnet_id
}
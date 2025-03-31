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
    sn1 = {cidr_block="10.0.1.0/24",availability_zone=var.zone["a"]} #앱 서버 1
    sn2 = {cidr_block="10.0.2.0/24",availability_zone=var.zone["c"]} #앱 서버 2
    sn3 = {cidr_block="10.0.3.0/24",availability_zone=var.zone["a"]} #백 서버 1
    sn4 = {cidr_block="10.0.4.0/24",availability_zone=var.zone["c"]} #백 서버 2
    sn5 = {cidr_block="10.0.5.0/24",availability_zone=var.zone["a"]} #DB 서버 1
    sn6 = {cidr_block="10.0.6.0/24",availability_zone=var.zone["c"]} #DB 서버 2
  }
  vpc_id     = aws_vpc.vpc.id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = each.key
  }
}

# RDS 서브넷 그룹 생성
# 정원빈 수정
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.subnet["sn5"].id, aws_subnet.subnet["sn6"].id]
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
    rt1 = {}
    rt2 = {}
  }
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = each.key
  }
}

# 기본 라우트 테이블 설정
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.routetable["rt1"].id
  destination_cidr_block = "0.0.0.0/0"  # 모든 트래픽
  gateway_id             = aws_internet_gateway.igw.id
}

# 서브넷과 라우트 테이블 연결
resource "aws_route_table_association" "routetable_association" {
    for_each = {
      asn1 = {route_table_id=aws_route_table.routetable["rt1"].id, subnet_id=aws_subnet.subnet["sn1"].id}
      asn2 = {route_table_id=aws_route_table.routetable["rt1"].id, subnet_id=aws_subnet.subnet["sn2"].id}
      asn3 = {route_table_id=aws_route_table.routetable["rt2"].id, subnet_id=aws_subnet.subnet["sn3"].id}
      asn4 = {route_table_id=aws_route_table.routetable["rt2"].id, subnet_id=aws_subnet.subnet["sn4"].id}
    }
  route_table_id = each.value.route_table_id
  subnet_id = each.value.subnet_id
}




# 키페어
# module "ssh_key" {
#   source = "../modules/ssh_key"
# }
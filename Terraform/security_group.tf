# 보안그룹
# 수정자 : 정원빈 031311
# 수정코드 : 
# dynamic & variable.tf -> ingress_value
# 수정 사유 : 코드 간편화?
resource "aws_security_group" "SG" {
  name        = "SG"
  description = "Security group"
  vpc_id      = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = [
      { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 3306, to_port = 3306, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 5000, to_port = 5000, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = -1, to_port = -1, protocol = "icmp", cidr_blocks = ["10.0.0.0/16"] }
    ]
    content {
      from_port   = for_each.value.from_port
      to_port     = for_each.value.to_port
      protocol    = for_each.value.protocol
      cidr_blocks = for_each.value.cidr_blocks
    }
  }

  # 아웃바운드 트래픽 모두 허용
  dynamic "egress" {
    for_each = var.egress_rules
    content {
      from_port   = egress.value.port
      to_port     = egress.value.port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
  tags = {
    Name = "Security_Group"
  }
}

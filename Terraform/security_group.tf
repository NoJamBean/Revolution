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
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  # 아웃바운드 트래픽 모두 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Security_Group"
  }
}

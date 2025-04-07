# 보안그룹
# 수정자 : 정원빈 031311
# 수정코드 : 
# dynamic & variable.tf -> ingress_value
# 수정 사유 : 코드 간편화?
resource "aws_security_group" "default_sg" {
  name        = "default_sg"
  description = "Security group"
  vpc_id      = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = {
      ssh     = { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
      http    = { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
      https   = { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
      mysql   = { from_port = 3306, to_port = 3306, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
      dotnet  = { from_port = 5000, to_port = 5000, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
      icmp    = { from_port = -1, to_port = -1, protocol = "icmp", cidr_blocks = ["10.0.0.0/16"] }
    }

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
    Name = "default_sg"
  }
}

resource "aws_security_group" "nat_sg" {
  name        = "nat_sg"
  description = "Security group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "NAT_SG"
  }
}

resource "aws_security_group" "dotnet_sg" {
  name        = "dotnet_sg"
  description = "Security group"
  vpc_id      = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = {
      ssh     = { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
      http    = { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
      https   = { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
      mysql   = { from_port = 3306, to_port = 3306, protocol = "tcp", cidr_blocks = ["10.0.0.0/16"] }
      dotnet  = { from_port = 5000, to_port = 5000, protocol = "tcp", cidr_blocks = ["10.0.0.0/16"] }
      icmp    = { from_port = -1, to_port = -1, protocol = "icmp", cidr_blocks = ["10.0.0.0/16"] }
    }

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
    Name = "dotnet_sg"
  }
}

resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/10"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "RDS Security Group" }
}

resource "aws_security_group" "vpc_endpoint_sg" {
  name        = "vpc-endpoint-sg"
  description = "Security group for API Gateway interface VPC endpoint"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow API server to access endpoint"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # 또는 API 서버가 있는 CIDR만
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-vpc-endpoint"
  }
}
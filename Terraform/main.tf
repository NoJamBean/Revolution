# aws_vpc.vpc 10.0.0.0/16
# aws_subnet.subnet[sn1-4] 10.0.[1-4].0/24 ap-northeast-2[a,b]

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.90.1"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}



data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

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
    sn1 = {cidr_block="10.0.1.0/24",availability_zone=var.zone["a"]}
    sn2 = {cidr_block="10.0.2.0/24",availability_zone=var.zone["c"]}
    sn3 = {cidr_block="10.0.3.0/24",availability_zone=var.zone["a"]}
    sn4 = {cidr_block="10.0.4.0/24",availability_zone=var.zone["c"]}
  }
  vpc_id     = aws_vpc.vpc.id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = each.key
  }
}

#Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "vpc-igw"
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

# 보안그룹
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

# ALB
resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.SG.id]
  subnets            = [
    aws_subnet.subnet["sn1"].id,
    aws_subnet.subnet["sn2"].id
  ]
  enable_deletion_protection = false
  # access_logs {
  #   bucket  = aws_s3_bucket.athena_log_bucket.bucket # 위에서 생성한 S3 버킷
  #   prefix  = "elb_log" # (선택 사항) 로그 파일 접두사
  #   enabled = true                  # 액세스 로깅 활성화
  # }
  tags = {
    Name = "revolution-alb"
  }
}

resource "aws_lb_target_group" "alb_tg" {
  name_prefix = "lb-tg-"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
  target_type = "instance"
  tags = {
    Name = "alb-tg"
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

# Launch Template 생성
resource "aws_launch_template" "template" {
  name_prefix   = "web-server"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3a.medium"
  # iam_instance_profile {
  #   name = ""
  # }
  key_name      = module.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.SG.id]

  user_data = base64encode(<<-EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl enable --now httpd
EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "web-server" }
  }
}

# Auto Scaling Group 생성
resource "aws_autoscaling_group" "asg" {
  desired_capacity     = 2
  max_size            = 4
  min_size            = 2
  vpc_zone_identifier = [ aws_subnet.subnet["sn1"].id, aws_subnet.subnet["sn2"].id]

  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.alb_tg.arn]

  health_check_type         = "EC2"
  health_check_grace_period = 300
}

# CPU 사용량 60% 이상이면 Scale Out (증가)
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

# CPU 사용량 20% 이하이면 Scale In (감소)
resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale-in"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
  description = "Access the website using this ALB DNS name"
}

# 프라이빗 인스턴스 생성
resource "aws_instance" "api_server1" {
  for_each      = {
    sn3 = { subnet_id = aws_subnet.subnet["sn3"].id, az = "ap-northeast-2a" }
  }

  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  subnet_id     = each.value.subnet_id
  availability_zone = each.value.az
  private_ip = "10.0.3.100"

  associate_public_ip_address = false
  key_name      = module.ssh_key.key_name
  security_groups = [aws_security_group.SG.id]

  user_data = <<-EOF
#!/bin/bash
hostname api_server1
(
echo "qwe123"
echo "qwe123"
) | passwd --stdin root
sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sed -i "s/^#PermitRootLogin yes/PermitRootLogin yes/g" /etc/ssh/sshd_config
service sshd restart
yum update -y
EOF

  tags = {
    Name = "api-server1"
  }
}

# 프라이빗 인스턴스 생성
resource "aws_instance" "api_server2" {
  for_each      = {
    sn4 = { subnet_id = aws_subnet.subnet["sn4"].id, az = "ap-northeast-2c" }
  }

  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  subnet_id     = each.value.subnet_id
  availability_zone = each.value.az
  private_ip = "10.0.4.100"

  associate_public_ip_address = false
  key_name      = module.ssh_key.key_name
  security_groups = [aws_security_group.SG.id]

  user_data = <<-EOF
#!/bin/bash
hostname api_server2
(
echo "qwe123"
echo "qwe123"
) | passwd --stdin root
sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sed -i "s/^#PermitRootLogin yes/PermitRootLogin yes/g" /etc/ssh/sshd_config
service sshd restart
yum update -y
EOF

  tags = {
    Name = "api-server2"
  }
}
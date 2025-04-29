# 김주관 2025-04-28
# 멀티리전-싱가폴
#


# VPC 부분----------------------------------------------------------------------------------------------------
#DHCP
resource "aws_vpc_dhcp_options" "sin_custom" {
  provider = aws.singapore
  domain_name         = "ap-southeast-1.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
}

resource "aws_vpc_dhcp_options_association" "sin_custom" {
  provider = aws.singapore
  vpc_id          = aws_vpc.sin_vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.sin_custom.id
}

# VPC
resource "aws_vpc" "sin_vpc" {
  provider = aws.singapore
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "singapore-totoro"
  }
}

# Subnet
resource "aws_subnet" "sin_subnet" {
  provider = aws.singapore
  for_each = {
    app1   = { cidr_block = "10.1.10.0/24", availability_zone = var.sin_zone["a"], map_public_ip_on_launch = true }   #앱 서버 1
    app2   = { cidr_block = "10.1.11.0/24", availability_zone = var.sin_zone["c"], map_public_ip_on_launch = true }   #앱 서버 2
    nat1   = { cidr_block = "10.1.20.0/24", availability_zone = var.sin_zone["a"], map_public_ip_on_launch = true }   #NAT1
    # nat2   = { cidr_block = "10.1.21.0/24", availability_zone = var.sin_zone["c"], map_public_ip_on_launch = true }   #NAT2
    ws1    = { cidr_block = "10.1.15.0/24", availability_zone = var.sin_zone["a"], map_public_ip_on_launch = false }   #앱 서버 1
    # ws2    = { cidr_block = "10.1.16.0/24", availability_zone = var.sin_zone["c"], map_public_ip_on_launch = false }   #앱 서버 2
    api1   = { cidr_block = "10.1.100.0/24", availability_zone = var.sin_zone["a"], map_public_ip_on_launch = false } #백 서버 1
    api2   = { cidr_block = "10.1.101.0/24", availability_zone = var.sin_zone["c"], map_public_ip_on_launch = false } #백 서버 2
    rds1   = { cidr_block = "10.1.50.0/24", availability_zone = var.sin_zone["a"], map_public_ip_on_launch = false }  #DB 서버 1
    rds2   = { cidr_block = "10.1.51.0/24", availability_zone = var.sin_zone["c"], map_public_ip_on_launch = false }  #DB 서버 2
 }

  vpc_id                  = aws_vpc.sin_vpc.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip_on_launch
  tags = {
    Name = each.key
  }
}

# RDS 서브넷 그룹 생성
# 정원빈 수정
resource "aws_db_subnet_group" "sin_rds_subnet_group" {
  provider = aws.singapore
  name       = "singapore-rds-subnet-group"
  subnet_ids = [aws_subnet.sin_subnet["rds1"].id, aws_subnet.sin_subnet["rds2"].id]
  tags       = { Name = "RDS Subnet Group" }
}

#Gateway
resource "aws_internet_gateway" "sin_igw" {
  provider = aws.singapore
  vpc_id = aws_vpc.sin_vpc.id

  tags = {
    Name = "singapore-vpc-igw"
    # 수정자 : 김주관 031310 / MMDDHH
    # 수정 코드 :
    # Name = "vpc-igw" -> Name = "vpc-internet"
    # 수정 사유 : 이름이 꼴받음
  }
}

# 라우트 테이블
resource "aws_route_table" "sin_routetable" {
  provider = aws.singapore
  for_each = {
    app   = {}
    nat   = {}
    back1 = {}
    # back2 = {}
  }
  vpc_id = aws_vpc.sin_vpc.id
  tags = {
    Name = each.key
  }
}

# 기본 라우트 테이블 설정
resource "aws_route" "sin_internet_access" {
  provider = aws.singapore
  for_each = {
    rt1 = aws_route_table.sin_routetable["app"].id
    rt2 = aws_route_table.sin_routetable["nat"].id
  }
  route_table_id         = each.value
  destination_cidr_block = "0.0.0.0/0" # 모든 트래픽
  gateway_id             = aws_internet_gateway.sin_igw.id
}

resource "aws_route" "sin_nat_instance_route" {
  provider = aws.singapore
  for_each = {
    rt1 = { rt_id = aws_route_table.sin_routetable["back1"].id, eni = aws_instance.sin_nat_instance1.primary_network_interface_id }
    # rt2 = { rt_id = aws_route_table.sin_routetable["back2"].id, eni = aws_instance.sin_nat_instance2.primary_network_interface_id }
  }

  route_table_id         = each.value.rt_id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = each.value.eni
}

# 서브넷과 라우트 테이블 연결
resource "aws_route_table_association" "sin_routetable_association" {
  provider = aws.singapore
  for_each = {
    app1 = { route_table_id = aws_route_table.sin_routetable["app"].id, subnet_id = aws_subnet.sin_subnet["app1"].id }
    app2 = { route_table_id = aws_route_table.sin_routetable["app"].id, subnet_id = aws_subnet.sin_subnet["app2"].id }
    nat1 = { route_table_id = aws_route_table.sin_routetable["nat"].id, subnet_id = aws_subnet.sin_subnet["nat1"].id }
    # nat2 = { route_table_id = aws_route_table.sin_routetable["nat"].id, subnet_id = aws_subnet.sin_subnet["nat2"].id }
    ws1  = { route_table_id = aws_route_table.sin_routetable["back1"].id, subnet_id = aws_subnet.sin_subnet["ws1"].id }
    # ws2  = { route_table_id = aws_route_table.sin_routetable["back2"].id, subnet_id = aws_subnet.sin_subnet["ws2"].id }
    api1 = { route_table_id = aws_route_table.sin_routetable["back1"].id, subnet_id = aws_subnet.sin_subnet["api1"].id }
    # api2 = { route_table_id = aws_route_table.sin_routetable["back2"].id, subnet_id = aws_subnet.sin_subnet["api2"].id }
    rds1 = { route_table_id = aws_route_table.sin_routetable["back1"].id, subnet_id = aws_subnet.sin_subnet["rds1"].id }
    # rds2 = { route_table_id = aws_route_table.sin_routetable["back2"].id, subnet_id=aws_subnet.sin_subnet["rds2"].id}
  }
  route_table_id = each.value.route_table_id
  subnet_id      = each.value.subnet_id
}
# ALB 부분--------------------------------------------------------------------------------------------------
# ALB
resource "aws_lb" "sin_alb" {
  provider = aws.singapore
  name               = "sin-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sin_alb_sg.id]
  subnets = [
    aws_subnet.sin_subnet["app1"].id,
    aws_subnet.sin_subnet["app2"].id
  ]
  enable_deletion_protection = false
  idle_timeout               = 60
  # access_logs {
  #   bucket  = aws_s3_bucket.athena_log_bucket.bucket # 위에서 생성한 S3 버킷
  #   prefix  = "elb_log" # (선택 사항) 로그 파일 접두사
  #   enabled = true                  # 액세스 로깅 활성화
  # }
  tags = {
    Name = "sin-revolution-alb"
  }
}

resource "aws_lb" "sin_private_alb" {
  provider = aws.singapore
  name               = "sin-priv-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sin_alb_sg.id]
  subnets = [
    aws_subnet.sin_subnet["api1"].id,
    aws_subnet.sin_subnet["api2"].id
  ]
  enable_deletion_protection = false
  idle_timeout               = 60

  tags = {
    Name = "sin-private-alb"
  }
}

resource "aws_lb_target_group" "sin_web_tg" {
  provider = aws.singapore

  lifecycle {
    create_before_destroy = true
  }

  name_prefix = "web-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.sin_vpc.id

  health_check {
    enabled             = true
    interval            = 60
    port                = 80
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 10
    matcher             = "200"
  }
  target_type = "instance"
  tags = {
    Name = "sin-web-tg"
  }
}

resource "aws_lb_target_group" "sin_api_tg" {
  provider = aws.singapore
  name_prefix = "api-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.sin_vpc.id
  target_type = "instance"
  health_check {
    enabled             = true
    interval            = 60
    port                = 80
    path                = "/api/health"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 10
    matcher             = "200"
  }
  tags = {
    Name = "sin-api-tg"
  }
}

resource "aws_lb_target_group" "sin_websocket_tg" {
  provider = aws.singapore
  name_prefix = "ws-tg"
  port        = 3001
  protocol    = "HTTP"
  vpc_id      =aws_vpc.sin_vpc.id
  target_type = "instance"
  health_check {
    enabled             = true
    interval            = 60
    port                = 3001
    path                = "/health"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 10
    matcher             = "200"
  }
  tags = {
    Name = "sin-websocket-tg"
  }
}

resource "aws_lb_listener" "sin_alb_http" {
  provider = aws.singapore
  load_balancer_arn = aws_lb.sin_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "sin_alb_https" {
  provider = aws.singapore
  load_balancer_arn = aws_lb.sin_alb.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.sin_alb_cert.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sin_web_tg.arn
  }
}

resource "aws_lb_listener" "sin_private_alb_http" {
  provider = aws.singapore
  load_balancer_arn = aws_lb.sin_private_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sin_api_tg.arn
  }
}

resource "aws_lb_listener_rule" "sin_api_rule" {
  provider = aws.singapore
  listener_arn = aws_lb_listener.sin_private_alb_http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sin_api_tg.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

resource "aws_lb_listener_rule" "sin_websocket_rule" {
  provider = aws.singapore
  listener_arn = aws_lb_listener.sin_private_alb_http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sin_websocket_tg.arn
  }

  condition {
    path_pattern {
      values = ["/ws/*", "/ws"]
    }
  }
}

resource "aws_lb_target_group_attachment" "sin_api_tg_attachment_1" {
  provider = aws.singapore
  target_group_arn = aws_lb_target_group.sin_api_tg.arn
  target_id        = aws_instance.sin_api_server_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "sin_websocket_tg_attachment_1" {
  provider = aws.singapore
  target_group_arn = aws_lb_target_group.sin_websocket_tg.arn
  target_id        = aws_instance.sin_websocket_1.id
  port             = 3001
}



# 보안그룹 부분 ----------------------------------------------------------------------------------------------
resource "aws_security_group" "sin_default_sg" {
  provider = aws.singapore
  name        = "sin_default_sg"
  description = "Security group"
  vpc_id      = aws_vpc.sin_vpc.id

  dynamic "ingress" {
    for_each = {
      ssh = { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
      http      = { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
      https     = { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
      webserver = { from_port = 3000, to_port = 3000, protocol = "tcp", cidr_blocks = ["10.0.0.0/14"] }
      icmp      = { from_port = -1, to_port = -1, protocol = "icmp", cidr_blocks = ["10.0.0.0/14"] }
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
    Name = "sin_default_sg"
  }
}

resource "aws_security_group" "sin_alb_sg" {
  provider = aws.singapore
  name        = "sin_alb_sg"
  description = "Security group"
  vpc_id      = aws_vpc.sin_vpc.id

  dynamic "ingress" {
    for_each = {
      ssh = { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
      http      = { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
      https     = { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
      mysql     = { from_port = 3306, to_port = 3306, protocol = "tcp", cidr_blocks = ["10.0.0.0/14"] }
      webserver = { from_port = 3000, to_port = 3000, protocol = "tcp", cidr_blocks = ["10.0.0.0/14"] }
      websocket = { from_port = 3001, to_port = 3001, protocol = "tcp", cidr_blocks = ["10.0.0.0/14"] }
      dotnet    = { from_port = 5000, to_port = 5000, protocol = "tcp", cidr_blocks = ["10.0.0.0/14"] }
      icmp      = { from_port = -1, to_port = -1, protocol = "icmp", cidr_blocks = ["10.0.0.0/14"] }
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
    Name = "sin_alb_sg"
  }
}




#API SERVER SG
resource "aws_security_group" "sin_dotnet_sg" {
  provider = aws.singapore
  name        = "sin_dotnet_sg"
  description = "Security group"
  vpc_id      = aws_vpc.sin_vpc.id

  dynamic "ingress" {
    for_each = {
      ssh    = { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["10.0.0.0/14"] }
      http   = { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
      https   = { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
      mysql  = { from_port = 3306, to_port = 3306, protocol = "tcp", cidr_blocks = ["10.0.0.0/14"] }
      dotnet = { from_port = 5000, to_port = 5000, protocol = "tcp", cidr_blocks = ["10.0.0.0/14"] }
    }

    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sin_dotnet_sg"
  }
}

#RDS SG
resource "aws_security_group" "sin_rds_sg" {
  provider = aws.singapore
  vpc_id = aws_vpc.sin_vpc.id

  dynamic "ingress" {
    for_each = {
      ssh = { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["10.0.0.0/14"] }
      mysql  = { from_port = 3306, to_port = 3306, protocol = "tcp", cidr_blocks = ["10.0.0.0/14"] }
      dotnet = { from_port = 5000, to_port = 5000, protocol = "tcp", cidr_blocks = ["10.0.0.0/14"] }
      icmp   = { from_port = -1, to_port = -1, protocol = "icmp", cidr_blocks = ["10.0.0.0/14"] }
    }

    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
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





# Redis용 보안그룹
resource "aws_security_group" "sin_redis_sg" {
  provider = aws.singapore
  name        = "sin-redis-sg"
  description = "Allow access from WebSocket EC2"
  vpc_id      = aws_vpc.sin_vpc.id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    cidr_blocks = ["10.0.0.0/14"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "redis_sg"
  }
}

resource "aws_security_group" "sin_websocket_sg" {
  provider = aws.singapore
  name        = "sin_websocket_sg"
  description = "Security group"
  vpc_id      = aws_vpc.sin_vpc.id

  dynamic "ingress" {
    for_each = {
      ssh    = { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["10.0.0.0/14"] }
      http   = { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["10.0.0.0/14"] }
      https  = { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["10.0.0.0/14"] }
      ws     = { from_port = 3001, to_port = 3001, protocol = "tcp", cidr_blocks = ["10.0.0.0/14"] }
      redis = { from_port = 6379, to_port = 6379, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
    }

    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sin_websocket_sg"
  }
}


# ASG 부분---------------------------------------------------------------------------------------------------

# Launch Template 생성
resource "aws_launch_template" "sin_template" {
  provider = aws.singapore
  name_prefix   = "sin-web-server"
  image_id      =  "ami-0c1907b6d738188e5"  #data.aws_ami.ubuntu.id
  instance_type = "t3a.small"
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  key_name               = var.singapore_key_name
  vpc_security_group_ids = [aws_security_group.sin_default_sg.id]
  user_data              = base64encode(data.template_file.app_server.rendered)

  credit_specification {
    cpu_credits = "standard"
  }
  
  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "sin-web-server" }
  }
}

# Auto Scaling Group 생성
resource "aws_autoscaling_group" "sin_asg" {
  provider = aws.singapore
  name                = "sin-web-asg"
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2
  vpc_zone_identifier = [aws_subnet.sin_subnet["app1"].id, aws_subnet.sin_subnet["app2"].id]

  launch_template {
    id      = aws_launch_template.sin_template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.sin_web_tg.arn]

  health_check_type         = "EC2"
  health_check_grace_period = 300


  # blue / green 배포 시 무중단으로 템플릿 ddd변경
  lifecycle {
    create_before_destroy = true
  }
}

# CPU 사용량 60% 이상이면 Scale Out 정책(증가)
resource "aws_autoscaling_policy" "sin_scale_out" {
  provider = aws.singapore
  name                   = "scale-out"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.sin_asg.name
}

# CPU 사용량 20% 이하이면 Scale In 정책(감소)
resource "aws_autoscaling_policy" "sin_scale_in" {
  provider = aws.singapore
  name                   = "scale-in"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.sin_asg.name
}


# CPU 사용률 70% 이상일 경우 Metric Alarm
resource "aws_cloudwatch_metric_alarm" "sin_cpu_high" {
  provider = aws.singapore
  alarm_name          = "high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70

  alarm_actions = [aws_autoscaling_policy.sin_scale_out.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.sin_asg.name
  }
}

# CPU 사용률 20% 이하일 경우 Metric Alarm
resource "aws_cloudwatch_metric_alarm" "sin_cpu_low" {
  provider = aws.singapore
  alarm_name          = "low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 20

  alarm_actions = [aws_autoscaling_policy.sin_scale_in.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.sin_asg.name
  }
}

# 인스턴스 부분----------------------------------------------------------------------------------------------

resource "aws_instance" "sin_nat_instance1" {
  provider = aws.singapore
  ami                    = "ami-05ab12222a9f39021"#data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.sin_subnet["nat1"].id
  vpc_security_group_ids = [aws_security_group.sin_default_sg.id]
  key_name               = var.singapore_key_name
  source_dest_check      = false
  associate_public_ip_address = true
  private_ip = "10.1.20.100"

  credit_specification {
    cpu_credits = "standard"
  }

  user_data = file("userdatas/nat.sh")

  tags = {
    Name = "SINGAPORE-NAT-INSTANCE-1"
  }
}


# resource "aws_instance" "sin_nat_instance2" {
#   provider = aws.singapore
#   ami                    = data.aws_ami.amazon_linux.id
#   instance_type          = "t3.micro"
#   subnet_id              = aws_subnet.sin_subnet["nat2"].id
#   vpc_security_group_ids = [aws_security_group.sin_default_sg.id]
#   key_name               = var.singapore_key_name
#   source_dest_check      = false
#   associate_public_ip_address = true
#   private_ip = "10.1.21.100"

#   credit_specification {
#     cpu_credits = "standard"
#   }

#   user_data = file("userdatas/nat.sh")

#   tags = {
#     Name = "SINGAPORE-NAT-INSTANCE-2"
#   }
# }

# WebSocket용 인스턴스 
# 송현섭
resource "aws_instance" "sin_websocket_1" {
  provider = aws.singapore
  ami                    = "ami-05ab12222a9f39021"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.sin_subnet["ws1"].id
  vpc_security_group_ids = [aws_security_group.sin_websocket_sg.id]
  key_name               = var.singapore_key_name # SSH용 키 페어
  iam_instance_profile = aws_iam_instance_profile.api_server_profile.name
  private_ip = "10.1.15.100"
  
  user_data = data.template_file.websocket_server.rendered

  tags = {
    Name = "Singapore-WebSocketServer1"
  }
}

# resource "aws_instance" "sin_websocket_2" {
#   provider = aws.singapore
#   ami                    = data.aws_ami.amazon_linux.id
#   instance_type          = "t3.micro"
#   subnet_id              = aws_subnet.sin_subnet["ws2"].id
#   vpc_security_group_ids = [aws_security_group.sin_websocket_sg.id]
#   key_name               = var.singapore_key_name # SSH용 키 페어
#   iam_instance_profile = aws_iam_instance_profile.api_server_profile.name
#   private_ip = "10.1.16.100"
  
#   user_data = data.template_file.websocket_server.rendered

#   tags = {
#     Name = "Singapore-WebSocketServer2"
#   }
# }



resource "aws_instance" "sin_api_server_1" {
  provider = aws.singapore
  depends_on             = [aws_instance.sin_nat_instance1]
  ami                    = "ami-05ab12222a9f39021"
  instance_type          = "t3a.small" //var.instance_type
  subnet_id              = aws_subnet.sin_subnet["api1"].id
  vpc_security_group_ids = [aws_security_group.sin_dotnet_sg.id]
  key_name               = var.singapore_key_name
  iam_instance_profile   = aws_iam_instance_profile.api_server_profile.name
  private_ip             = "10.1.100.100"

  credit_specification {
    cpu_credits = "standard"
  }

  user_data = <<-EOT
#!/bin/bash
    
set -e

sudo tee -a /etc/environment > /dev/null <<EOL
DB_ENDPOINT="${split(":", aws_db_instance.mysql_multi_az.endpoint)[0]}"
DB_ENDPOINT_RO="${split(":", aws_db_instance.sin_mysql_read_replica.endpoint)[0]}"
DB_USERNAME="${var.db_username}"
DB_PASSWORD="${var.db_password}"
COGNITO_USER_POOL="${aws_cognito_user_pool.user_pool.id}"
COGNITO_APP_CLIENT="${aws_cognito_user_pool_client.app_client.id}"
API_SERVER_DNS="${var.api_dns}"

S3_BUCKET="${aws_s3_bucket.long_user_data_bucket.bucket}"
S3_LOG_BUCKET="${aws_s3_bucket.log_bucket.bucket}"
LOCAL_PATH="/var/www/dotnet-api/MyApi"
EOL

source /etc/environment

export S3_BUCKET="${aws_s3_bucket.long_user_data_bucket.bucket}"
export LOCAL_PATH="/var/www/dotnet-api/MyApi"

sudo aws s3 cp s3://$S3_BUCKET/userdatas/api_server.sh /tmp/api_server.sh
sudo chmod +x /tmp/api_server.sh
sudo /tmp/api_server.sh
EOT

  tags = {
    Name = "Singapore-DotNet-API-SERVER1"
  }
}

# resource "aws_instance" "sin_api_server_2" {
#   provider = aws.singapore
#   depends_on             = [aws_instance.sin_nat_instance1]
#   ami                    = data.aws_ami.amazon_linux.id
#   instance_type          = "t3a.small" //var.instance_type
#   subnet_id              = aws_subnet.sin_subnet["api2"].id
#   vpc_security_group_ids = [aws_security_group.sin_dotnet_sg.id]
#   key_name               = var.singapore_key_name
#   iam_instance_profile   = aws_iam_instance_profile.api_server_profile.name
#   private_ip             = "10.1.101.100"

#   credit_specification {
#     cpu_credits = "standard"
#   }

#   user_data = <<-EOT
# #!/bin/bash
    
# set -e

# sudo tee -a /etc/environment > /dev/null <<EOL
# DB_ENDPOINT="${split(":", aws_db_instance.mysql_multi_az.endpoint)[0]}"
# DB_ENDPOINT_RO="${split(":", aws_db_instance.sin_mysql_read_replica.endpoint)[0]}"
# DB_USERNAME="${var.db_username}"
# DB_PASSWORD="${var.db_password}"
# COGNITO_USER_POOL="${aws_cognito_user_pool.user_pool.id}"
# COGNITO_APP_CLIENT="${aws_cognito_user_pool_client.app_client.id}"
# API_SERVER_DNS="${var.api_dns}"

# S3_BUCKET="${aws_s3_bucket.long_user_data_bucket.bucket}"
# S3_LOG_BUCKET="${aws_s3_bucket.log_bucket.bucket}"
# LOCAL_PATH="/var/www/dotnet-api/MyApi"
# EOL

# source /etc/environment

# export S3_BUCKET="${aws_s3_bucket.long_user_data_bucket.bucket}"
# export LOCAL_PATH="/var/www/dotnet-api/MyApi"

# sudo aws s3 cp s3://$S3_BUCKET/userdatas/api_server.sh /tmp/api_server.sh
# sudo chmod +x /tmp/api_server.sh
# sudo /tmp/api_server.sh
# EOT

#   tags = {
#     Name = "Singapore-DotNet-API-SERVER2"
#   }
# }

# RDS 읽기 복제본 부분-------------------------------------------------------------------------------------
# RDS 파라미터 그룹 생성
resource "aws_db_parameter_group" "sin_parm" {
  provider = aws.singapore
  name   = "mysql-parameter-group"
  family = "mysql8.0"

  dynamic "parameter" {
    for_each = {
      time_zone              = "Asia/Seoul"
      character_set_client   = "utf8mb4"
      character_set_results  = "utf8mb4"
      character_set_server   = "utf8mb4"
      collation_connection   = "utf8mb4_general_ci"
      collation_server       = "utf8mb4_general_ci"
      general_log            = "1"            # 일반 쿼리 로그 활성화
      slow_query_log         = "1"            # 슬로우 쿼리 로그 활성화
      log_output             = "FILE"         # 로그 출력 형식
      long_query_time        = "1"            # 슬로우 쿼리 판별 기준 시간 (초)
      log_queries_not_using_indexes = "1"     # 인덱스를 사용하지 않는 쿼리도 로그
    }
    content {
      name  = parameter.key
      value = parameter.value
    }
}

  tags = {
    Name = "Singapore-RDS MySQL Parameter Group"
  }
}

resource "aws_db_instance" "sin_mysql_read_replica" {
  provider = aws.singapore
  identifier           = "sin-mysql-read-replica"
  engine               = "mysql"
  instance_class       = "db.t3.micro"
  replicate_source_db  = aws_db_instance.mysql_multi_az.arn  # 반드시 마스터의 identifier를 지정
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.sin_rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.sin_rds_sg.id]
  skip_final_snapshot = true
  storage_encrypted = true
  kms_key_id          = "arn:aws:kms:ap-southeast-1:248189921892:key/mrk-b3f30d170a584dea8b949979e4471fdc"

  tags = {
    Name = "Singapore-MySQL Read Replica"
  }
}

#읽기 복제본 프록시

#DB PROXY
# resource "aws_db_proxy" "sin_db_proxy" {
#   provider = aws.singapore
#   name                   = "sin_db_proxy"
#   debug_logging          = false
#   engine_family          = "MYSQL"
#   idle_client_timeout    = 1800
#   require_tls            = true
#   role_arn               = aws_iam_role.example.arn
#   vpc_security_group_ids = [aws_security_group.sin_sg.id]
#   vpc_subnet_ids         = [data.aws_subnets.sin_default.id[*]]

#   auth {
#     auth_scheme = "SECRETS"
#     description = "example"
#     iam_auth    = "DISABLED"
#     secret_arn  = aws_secretsmanager_secret.sin_example.arn
#   }

#   tags = {
#     Name = "example"
#     Key  = "value"
#   }
# }

# resource "aws_db_proxy_default_target_group" "sin_group" {
#   provider = aws.singapore
#   db_proxy_name = aws_db_proxy.sin_db_proxy.name

#   connection_pool_config {
#     connection_borrow_timeout    = 120
#     init_query                   = "SET x=1, y=2"
#     max_connections_percent      = 100
#     max_idle_connections_percent = 50
#     session_pinning_filters      = ["EXCLUDE_VARIABLE_SETS"]
#   }
# }

# resource "aws_db_proxy_target" "sin_target" {
#   provider = aws.singapore
#   db_instance_identifier = aws_db_instance.sin_mysql_multi_az.identifier
#   db_proxy_name          = aws_db_proxy.sin_db_proxy.name
#   target_group_name      = aws_db_proxy_default_target_group.sin_group.name
# }
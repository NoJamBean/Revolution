# ALB
resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets = [
    aws_subnet.subnet["app1"].id,
    aws_subnet.subnet["app2"].id
  ]
  enable_deletion_protection = false
  idle_timeout               = 60
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

  lifecycle {
    create_before_destroy = true
  }

  name_prefix = "lb-tg-"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id

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
    Name = "alb-tg"
  }
}

resource "aws_lb_target_group" "api_tg" {
  name_prefix = "api-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "instance"
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
  tags = {
    Name = "api-tg"
  }
}

resource "aws_lb_target_group" "websocket_tg" {
  name_prefix = "ws-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "instance"
  health_check {
    enabled             = true
    interval            = 60
    port                = 3000
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 10
    matcher             = "200"
  }
  tags = {
    Name = "websocket-tg"
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

resource "aws_lb_listener_rule" "api_rule" {
  listener_arn = aws_lb_listener.alb_listener.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_tg.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

resource "aws_lb_listener_rule" "websocket_rule" {
  listener_arn = aws_lb_listener.alb_listener.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.websocket_tg.arn
  }

  condition {
    path_pattern {
      values = ["/ws/*"]
    }
  }
}

# Launch Template 생성
resource "aws_launch_template" "template" {
  name_prefix   = "web-server"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3a.medium"
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  key_name               = var.seoul_key_name
  vpc_security_group_ids = [aws_security_group.default_sg.id]
  user_data              = base64encode(data.template_file.app_server.rendered)

  credit_specification {
    cpu_credits = "standard"
  }
  
  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "web-server" }
  }
}

# Auto Scaling Group 생성
resource "aws_autoscaling_group" "asg" {
  name                = "web-asg"
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2
  vpc_zone_identifier = [aws_subnet.subnet["app1"].id, aws_subnet.subnet["app2"].id]

  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.alb_tg.arn]

  health_check_type         = "EC2"
  health_check_grace_period = 300


  # blue / green 배포 시 무중단으로 템플릿 ddd변경
  lifecycle {
    create_before_destroy = true
  }
}

# CPU 사용량 60% 이상이면 Scale Out 정책(증가)
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

# CPU 사용량 20% 이하이면 Scale In 정책(감소)
resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale-in"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.asg.name
}


# CPU 사용률 70% 이상일 경우 Metric Alarm
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70

  alarm_actions = [aws_autoscaling_policy.scale_out.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}

# CPU 사용률 20% 이하일 경우 Metric Alarm
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 20

  alarm_actions = [aws_autoscaling_policy.scale_in.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}


output "alb_dns_name" {
  value       = aws_lb.alb.dns_name
  description = "Access the website using this ALB DNS name"
}

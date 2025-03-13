
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

  user_data = file("userdatas/webserver.sh")
  
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

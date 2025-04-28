# Launch Template 생성
resource "aws_launch_template" "template" {
  name_prefix   = "web-server"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t3a.small"
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

  target_group_arns = [aws_lb_target_group.web_tg.arn]

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
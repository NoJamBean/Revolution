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

resource "aws_lb" "private_alb" {
  name               = "priv-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets = [
    aws_subnet.subnet["api1"].id,
    aws_subnet.subnet["api2"].id
  ]
  enable_deletion_protection = false
  idle_timeout               = 60

  tags = {
    Name = "private-alb"
  }
}

resource "aws_lb_target_group" "web_tg" {

  lifecycle {
    create_before_destroy = true
  }

  name_prefix = "web-tg"
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
    Name = "web-tg"
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
  port        = 3001
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
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
    Name = "websocket-tg"
  }
}

resource "aws_lb_listener" "alb_http" {
  load_balancer_arn = aws_lb.alb.arn
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

resource "aws_lb_listener" "alb_https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.alb_cert.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

resource "aws_lb_listener" "private_alb_https" {
  load_balancer_arn = aws_lb.private_alb.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.self_signed.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_tg.arn
  }
}

resource "aws_lb_listener_rule" "api_rule" {
  listener_arn = aws_lb_listener.private_alb_https.arn
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
  listener_arn = aws_lb_listener.private_alb_https.arn
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

resource "aws_lb_target_group_attachment" "api_tg_attachment" {
  target_group_arn = aws_lb_target_group.api_tg.arn
  target_id        = aws_instance.api_server_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "websocket_tg_attachment" {
  target_group_arn = aws_lb_target_group.websocket_tg.arn
  target_id        = aws_instance.websocket_1.id
  port             = 3001
}


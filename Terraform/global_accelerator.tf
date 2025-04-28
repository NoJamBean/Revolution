resource "aws_globalaccelerator_accelerator" "frontend" {
  name            = "revolution-global-accel"
  enabled         = true
  ip_address_type = "IPV4"
}

resource "aws_globalaccelerator_listener" "frontend" {
  accelerator_arn = aws_globalaccelerator_accelerator.frontend.id
  protocol        = "TCP"
  port_range {
    from_port = 80
    to_port   = 80
  }
  port_range {
    from_port = 443
    to_port   = 443
  }
}

resource "aws_globalaccelerator_endpoint_group" "frontend" {
  listener_arn          = aws_globalaccelerator_listener.frontend.id
  endpoint_group_region = "ap-northeast-2" # 서울 리전

  endpoint_configuration {
    endpoint_id = aws_lb.alb.arn
    weight      = 128
  }

  # 필요하면 health check, 트래픽 분배 등 추가 가능
}

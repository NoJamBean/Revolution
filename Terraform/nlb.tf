resource "aws_lb" "api_nlb" {
  name               = "api-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = [ aws_subnet.subnet["api1"].id, aws_subnet.subnet["api2"].id ]
}

# 2. Target Group 생성 (TCP 80)
resource "aws_lb_target_group" "api_tg" {
  name     = "api-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.vpc.id
  target_type = "instance"
}

# 3. Target Group에 EC2 2대 등록
resource "aws_lb_target_group_attachment" "tg_attachment1" {
  target_group_arn = aws_lb_target_group.api_tg.arn
  target_id        = aws_instance.api_server_1.id
  port             = 80
}

# resource "aws_lb_target_group_attachment" "tg_attachment2" {
#   target_group_arn = aws_lb_target_group.tg.arn
#   target_id        = aws_instance.api_server2.id
#   port             = 80
# }

# 4. NLB Listener
resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.api_nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_tg.arn
  }
}
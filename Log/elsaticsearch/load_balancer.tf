
resource "aws_security_group" "elasticsearch_lb_sg" {
  name        = "elasticsearch-lb-sg"
  description = "Security group for internal Elasticsearch ALB"
  vpc_id      = var.vpc_id 
  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = [var.cidr_blocks]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "ElasticsearchLBSecurityGroup"
    Project = "LogMonitoring"
  }
}

resource "aws_lb" "elasticsearch_lb" {
  name               = "elasticsearch-internal-lb" 
  internal           = true 
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elasticsearch_lb_sg.id] 

  subnets            = var.subnets 

  tags = {
    Name    = "ElasticsearchInternalLB"
    Project = "LogMonitoring"
  }
}

resource "aws_lb_target_group" "elasticsearch_tg" {
  name        = "elasticsearch-tg" 
  port        = 9200    
  protocol    = "HTTP"
  vpc_id      = var.vpc_id  
  target_type = "ip"   
  health_check {
    enabled             = true
    interval            = 30  
    path                = "/"  
    port                = "traffic-port" 
    protocol            = "HTTP"
    timeout             = 5   
    healthy_threshold   = 3   
    unhealthy_threshold = 3   
    matcher             = "200" 
  }

  tags = {
    Name    = "ElasticsearchTargetGroup"
    Project = "LogMonitoring"
  }
}

resource "aws_lb_listener" "elasticsearch_listener" {
  load_balancer_arn = aws_lb.elasticsearch_lb.arn 
  port              = 9200       
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.elasticsearch_tg.arn 
  }
}

output "elasticsearch_lb_dns_name" {
  description = "생성된 내부 ALB의 DNS 이름"
  value       = aws_lb.elasticsearch_lb.dns_name
}

output "elasticsearch_target_group_arn" {
  description = "생성된 Elasticsearch 대상 그룹의 ARN"
  value       = aws_lb_target_group.elasticsearch_tg.arn
}

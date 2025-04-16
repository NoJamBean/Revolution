resource "aws_ecs_service" "elasticsearch_service" {
  name            = "elasticsearch-service"
  cluster         = aws_ecs_cluster.integration_log_cluster.id 
  task_definition = aws_ecs_task_definition.elasticsearch_task.arn 
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets = var.subnets 
    security_groups = [aws_security_group.ecs_task_sg.id] 
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.elasticsearch_tg.arn 
    container_name   = "elasticsearch-container"
    container_port   = 9200
  }

  depends_on = [
    aws_lb_listener.elasticsearch_listener,
  ]

  tags = {
    Name        = "ElasticsearchService"
    Environment = "Development"
    Project     = "LogMonitoring"
  }
}

resource "aws_security_group" "ecs_task_sg" {
  name        = "ecs-task-sg"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id 
  ingress {
    from_port       = 9200
    to_port         = 9200
    protocol        = "tcp"
    security_groups = [aws_security_group.elasticsearch_lb_sg.id] 
  }
  ingress {
    from_port       = 9300
    to_port         = 9300
    protocol        = "tcp"
    security_groups = [aws_security_group.elasticsearch_lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "ECSTaskSecurityGroup"
    Project = "LogMonitoring"
  }
}

output "elasticsearch_service_name" {
  description = "생성된 Elasticsearch ECS 서비스의 이름"
  value       = aws_ecs_service.elasticsearch_service.name
}

resource "aws_ecs_service" "kibana_service" {
  name            = "kibana-service" 
  cluster         = aws_ecs_cluster.integration_log_cluster.id
  task_definition = aws_ecs_task_definition.kibana_task.arn
  desired_count   = 1 
  launch_type     = "FARGATE"

  network_configuration {
    subnets = var.subnets 
    security_groups = [aws_security_group.ecs_task_sg.id] 
    assign_public_ip = false
  }

  depends_on = [
    aws_ecs_service.elasticsearch_service, 
  ]

  tags = {
    Name        = "KibanaService"
    Environment = "Development"
    Project     = "LogMonitoring"
  }
}

output "kibana_service_name" {
  description = "생성된 Kibana ECS 서비스의 이름"
  value       = aws_ecs_service.kibana_service.name
}


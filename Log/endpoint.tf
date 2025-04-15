resource "aws_security_group" "vpc_endpoint_sg" {
  name        = "vpc-endpoint-sg"
  description = "Security group for VPC interface endpoints (ECR)"
  vpc_id      = var.vpc_id 

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_task_sg.id] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "VPCEndpointSecurityGroup"
    Project = "LogMonitoring"
  }
}

resource "aws_vpc_endpoint" "s3_gateway_endpoint" {
  vpc_id            = var.vpc_id 
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = var.private_route_table_ids 
  tags = {
    Name    = "S3GatewayEndpoint"
    Project = "LogMonitoring"
  }
}

resource "aws_vpc_endpoint" "ecr_api_endpoint" {
  vpc_id              = var.vpc_id 
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true        

  subnet_ids          = var.subnets 
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id] 

  tags = {
    Name    = "ECR-API-InterfaceEndpoint"
    Project = "LogMonitoring"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr_endpoint" {
  vpc_id              = var.vpc_id 
  service_name        = "com.amazonaws.${var.region}.ecr.dkr" 
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true      
  subnet_ids          = var.subnets 
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id] 

  tags = {
    Name    = "ECR-DKR-InterfaceEndpoint"
    Project = "LogMonitoring"
  }
}
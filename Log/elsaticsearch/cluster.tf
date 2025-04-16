provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_ecs_cluster" "integration_log_cluster" {
  name = "integration-log-cluster" 

  tags = {
    Name        = "IntegrationLogCluster"
    Environment = "Development" 
    Project     = "LogMonitoring"
  }
}

output "ecs_cluster_name" {
  description = "생성된 ECS 클러스터의 이름"
  value       = aws_ecs_cluster.integration_log_cluster.name
}


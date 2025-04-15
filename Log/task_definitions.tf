
resource "aws_ecs_task_definition" "elasticsearch_task" {
  family                   = "elasticsearch-task"
  network_mode             = "awsvpc"
  execution_role_arn       = "arn:aws:iam::248189921892:role/ecsTaskExecutionRole" 
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048" 
  container_definitions = jsonencode([
    {
      name      = "elasticsearch-container" 
      image     = "248189921892.dkr.ecr.ap-northeast-2.amazonaws.com/elasticsearch/integration_log:es01" 
      essential = true
      portMappings = [
        {
          containerPort = 9200 
          hostPort      = 9200 
          protocol      = "tcp"
        },
        {
          containerPort = 9300 
          hostPort      = 9300
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "node.name", value = "es01" },
        { name = "cluster.name", value = "es-docker-cluster" },
        { name = "discovery.type", value = "single-node" },
        { name = "bootstrap.memory_lock", value = "true" },
        { name = "ES_JAVA_OPTS", value = "-Xms1g -Xmx1g" } 
      ]
      ulimits = [
        {
          name      = "memlock"
          softLimit = -1
          hardLimit = -1
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/elasticsearch-task"
          "awslogs-region"        = "ap-northeast-2"     
          "awslogs-stream-prefix" = "es"             
        }
      }
      mountPoints = [
        {
          sourceVolume  = "esdata01" 
          containerPath = "/usr/share/elasticsearch/data" 
          readOnly      = false
        }
      ]
    }
  ])

  volume {
    name = "esdata01" 
  }

  tags = {
    Name        = "ElasticsearchTaskDefinition"
    Environment = "Development"
    Project     = "LogMonitoring"
  }
}

output "elasticsearch_task_definition_arn" {
  description = "생성된 Elasticsearch Task Definition의 ARN"
  value       = aws_ecs_task_definition.elasticsearch_task.arn
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole-integration-log" 

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Project = "LogMonitoring"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "kibana_task" {
  family                   = "kibana-task" 
  network_mode             = "awsvpc"

  execution_role_arn       = "arn:aws:iam::248189921892:role/ecsTaskExecutionRole" 
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"  
  memory                   = "1024"
  container_definitions = jsonencode([
    {
      name      = "kibana-container" 
      image     = "248189921892.dkr.ecr.ap-northeast-2.amazonaws.com/elasticsearch/integration_log:kibana" 
      essential = true
      portMappings = [
        {
          containerPort = 5601
          hostPort      = 5601
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "ELASTICSEARCH_HOSTS", value = "[\"http://${aws_lb.elasticsearch_lb.dns_name}:9200\"]" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/kibana-task"   
          "awslogs-region"        = "ap-northeast-2"   
          "awslogs-stream-prefix" = "kibana"       
        }
      }
    }
  ])

  tags = {
    Name        = "KibanaTaskDefinition"
    Environment = "Development"
    Project     = "LogMonitoring"
  }
  depends_on = [ aws_lb.elasticsearch_lb ]
}

output "kibana_task_definition_arn" {
  description = "생성된 Kibana Task Definition의 ARN"
  value       = aws_ecs_task_definition.kibana_task.arn
}

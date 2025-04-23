resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name        = "redis-subnet-group"
  description = "Subnet group for Redis"
  subnet_ids = [
    aws_subnet.subnet["redis1"].id,
    aws_subnet.subnet["redis2"].id,
  ]

  tags = {
    Name = "redis-subnet-group"
  }
}



resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = "chat-redis"
  description          = "Redis replication group"
  engine               = "redis"
  engine_version       = "7.0"
  node_type            = "cache.t3.micro"
  port                 = 6379

  num_node_groups         = 1
  replicas_per_node_group = 0

  subnet_group_name  = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids = [aws_security_group.redis_sg.id]
  apply_immediately  = true

  tags = {
    Name = "ChatRedis"
  }
}




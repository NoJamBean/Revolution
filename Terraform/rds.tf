# RDS 파라미터 그룹 생성
resource "aws_db_parameter_group" "parm" {
  name   = "mysql-parameter-group"
  family = "mysql8.0"

  dynamic "parameter" {
    for_each = {
      time_zone              = "Asia/Seoul"
      character_set_client   = "utf8mb4"
      character_set_results  = "utf8mb4"
      character_set_server   = "utf8mb4"
      collation_connection   = "utf8mb4_general_ci"
      collation_server       = "utf8mb4_general_ci"
      general_log            = "1"            # 일반 쿼리 로그 활성화
      slow_query_log         = "1"            # 슬로우 쿼리 로그 활성화
      log_output             = "FILE"         # 로그 출력 형식
      long_query_time        = "1"            # 슬로우 쿼리 판별 기준 시간 (초)
      log_queries_not_using_indexes = "1"     # 인덱스를 사용하지 않는 쿼리도 로그
    }
    content {
      name  = parameter.key
      value = parameter.value
    }
}

  tags = {
    Name = "RDS MySQL Parameter Group"
  }
}

resource "aws_db_instance" "mysql_multi_az" {
  identifier                          = "mysql-multi-az-rds-instance"
  engine                              = "mysql"
  engine_version                      = "8.0.40"
  instance_class                      = "db.t3.micro"
  allocated_storage                   = var.db_allocated_storage
  storage_type                        = "gp3"
  username                            = var.db_username
  password                            = var.db_password
  multi_az                            = true # 다중 AZ 활성화
  db_subnet_group_name                = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids              = [aws_security_group.rds_sg.id]
  backup_retention_period             = 1
  apply_immediately                   = true # 수정 즉시적용
  skip_final_snapshot                 = true
  deletion_protection                 = false
  publicly_accessible                 = false
  storage_encrypted                   = true
  monitoring_interval                 = 0 
  iam_database_authentication_enabled = false # IAM 인증 비활성화 (암호 인증 사용)
  parameter_group_name                = aws_db_parameter_group.parm.name
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery", "audit"]
  availability_zone                   = null # 자동 배정
  tags                                = { Name = "MySQL Multi-AZ RDS Instance" }
}

resource "aws_db_instance" "mysql_read_replica" {
  identifier           = "mysql-read-replica"
  engine               = "mysql"
  instance_class       = "db.t3.micro"
  replicate_source_db  = aws_db_instance.mysql_multi_az.arn  # 반드시 마스터의 identifier를 지정
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot = true

  tags = {
    Name = "MySQL Read Replica"
  }
}

#읽기 복제본 프록시

#DB PROXY
# resource "aws_db_proxy" "db_proxy" {
#   name                   = "db_proxy"
#   debug_logging          = false
#   engine_family          = "MYSQL"
#   idle_client_timeout    = 1800
#   require_tls            = true
#   role_arn               = aws_iam_role.example.arn
#   vpc_security_group_ids = [aws_security_group.sg.id]
#   vpc_subnet_ids         = [data.aws_subnets.default.id[*]]

#   auth {
#     auth_scheme = "SECRETS"
#     description = "example"
#     iam_auth    = "DISABLED"
#     secret_arn  = aws_secretsmanager_secret.example.arn
#   }

#   tags = {
#     Name = "example"
#     Key  = "value"
#   }
# }

# resource "aws_db_proxy_default_target_group" "group" {
#   db_proxy_name = aws_db_proxy.db_proxy.name

#   connection_pool_config {
#     connection_borrow_timeout    = 120
#     init_query                   = "SET x=1, y=2"
#     max_connections_percent      = 100
#     max_idle_connections_percent = 50
#     session_pinning_filters      = ["EXCLUDE_VARIABLE_SETS"]
#   }
# }

# resource "aws_db_proxy_target" "target" {
#   db_instance_identifier = aws_db_instance.mysql_multi_az.identifier
#   db_proxy_name          = aws_db_proxy.db_proxy.name
#   target_group_name      = aws_db_proxy_default_target_group.group.name
# }




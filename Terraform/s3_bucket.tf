#tfstatefile저장용 버킷
# resource "aws_s3_bucket" "tf_state" {
#   bucket = "tfstate-bucket-revolution112233"

#   lifecycle {
#     prevent_destroy = true
#   }
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state_sse" {
#   bucket = aws_s3_bucket.tf_state.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

resource "aws_s3_bucket_policy" "allow_same_vpc_only_1" {
  bucket = aws_s3_bucket.long_user_data_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowAccessFromSameVPC",
        Effect = "Allow",
        Principal = "*",
        Action = [
          "s3:*"
        ],
        Resource = [
          "${aws_s3_bucket.long_user_data_bucket.arn}",
          "${aws_s3_bucket.long_user_data_bucket.arn}/*"
        ]
        Condition = {
          StringEquals = {
            "aws:SourceVpc" = [
              aws_vpc.sin_vpc.id,
              aws_vpc.vpc.id
            ]
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket" "long_user_data_bucket" {
  bucket = "long-user-data-bucket"

  lifecycle {
    prevent_destroy = false # S3 버킷 삭제가 가능하도록 설정
  }

  tags = {
    Name        = "Long User Data Bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_public_access_block" "allow_public_access_user_data_bucket" {
  bucket = aws_s3_bucket.long_user_data_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "allow_same_vpc_only_2" {
  bucket = aws_s3_bucket.log_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowAccessFromSameVPC",
        Effect = "Allow",
        Principal = "*",
        Action = [
          "s3:*"
        ],
        Resource = [
          "${aws_s3_bucket.log_bucket.arn}",
          "${aws_s3_bucket.log_bucket.arn}/*"
        ]
        Condition = {
          StringEquals = {
            "aws:SourceVpc" = [
              aws_vpc.sin_vpc.id,
              aws_vpc.vpc.id
            ]
          }
        }
      },
      {
        Sid    = "AllowLambdaAccess",
        Effect = "Allow",
        Principal = {
          AWS = [
            data.aws_iam_role.lambda_execution_role_1.arn,
            data.aws_iam_role.lambda_execution_role_2.arn,
            data.aws_iam_role.lambda_execution_role_3.arn
          ]
        },
        Action = [
          "s3:*"
        ],
        Resource = [
          "${aws_s3_bucket.log_bucket.arn}",
          "${aws_s3_bucket.log_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket" "log_bucket" {
  # bucket        = "logs-${random_id.bucket_suffix.hex}"
  bucket        = "bet-application-total-logs"
  force_destroy = true

  lifecycle {
    prevent_destroy = false # S3 버킷 삭제가 가능하도록 설정
  }


  tags = {
    Name        = "LOG BUCKET"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_public_access_block" "allow_public_access_log_bucket" {
  bucket = aws_s3_bucket.log_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "allow_same_vpc_only_3" {
  bucket = aws_s3_bucket.my_pipelines_first_artifact_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowAccessFromSameVPC",
        Effect = "Allow",
        Principal = "*",
        Action = [
          "s3:*"
        ],
        Resource = [
          "${aws_s3_bucket.my_pipelines_first_artifact_bucket.arn}",  # 버킷 자체 리소스
          "${aws_s3_bucket.my_pipelines_first_artifact_bucket.arn}/*"  # 버킷 내 객체들
        ],
        Condition = {
          StringEquals = {
            "aws:SourceVpc" = [
              aws_vpc.sin_vpc.id,
              aws_vpc.vpc.id
            ]
          }
        }
      },
      {
        Sid    = "AllowCodeDeployAccess",
        Effect = "Allow",
        Principal = {
          AWS = [
            aws_iam_role.codedeploy_role.arn
          ]
        },
        Action = [
          "s3:*"
        ],
        Resource = [
          "${aws_s3_bucket.my_pipelines_first_artifact_bucket.arn}",
          "${aws_s3_bucket.my_pipelines_first_artifact_bucket.arn}/*"  # 버킷 내 객체들만 지정
        ]
      }
    ]
  })
}

# Build 파일 저장용 버킷 생성
resource "aws_s3_bucket" "my_pipelines_first_artifact_bucket" {
  bucket        = "webdeploy-artifact-bucket" # 전 세계 유일한 이름 필요
  force_destroy = true

  versioning {
    enabled = true  # 버전 관리 활성화
  }

  tags = {
    Name        = "codebuild-artifact-bucket"
    Environment = "production"
  }
}

resource "aws_s3_bucket" "my_pipelines_second_artifact_bucket" {
  provider = aws.singapore
  bucket        = "webdeploy-artifact-bucket-sg" # 싱가포르 리전에서 사용할 S3 버킷
  force_destroy = true

  versioning {
    enabled = true  # 버전 관리 활성화
  }

  tags = {
    Name        = "codebuild-artifact-bucket-sg"
    Environment = "production"
  }
}

resource "aws_s3_bucket_replication_configuration" "replica" {
  bucket = aws_s3_bucket.my_pipelines_first_artifact_bucket.bucket

  role = aws_iam_role.s3_replication_role.arn

  rule {
    id     = "ReplicationRule"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.my_pipelines_second_artifact_bucket.arn
      storage_class = "STANDARD"
    }

    filter {
      prefix = ""  # 복제할 객체의 접두사 필터 (빈 값이면 모든 객체가 복제됨)
    }

    delete_marker_replication {
      status = "Enabled"  # 삭제 마커 복제 활성화
    }
  }
}

resource "aws_s3_bucket_public_access_block" "allow_public_access_artifact_bucket" {
  bucket = aws_s3_bucket.my_pipelines_first_artifact_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


# 서버 측 암호화 설정 
resource "aws_s3_bucket_server_side_encryption_configuration" "artifact_bucket_encryption" {
  bucket = aws_s3_bucket.my_pipelines_first_artifact_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 8
}


#UserData
resource "aws_s3_object" "api_server_userdata" {
  bucket = aws_s3_bucket.long_user_data_bucket.id
  key    = "userdatas/api_server.sh"
  source = "${path.module}/userdatas/api_server.sh"
  acl    = "private"
  source_hash = filemd5("${path.module}/userdatas/api_server.sh")
}

resource "aws_s3_object" "dotnet_run_script" {
  bucket      = aws_s3_bucket.long_user_data_bucket.id
  key         = "dotnet_scripts/dotnet_run.sh"
  source      = "${path.module}/dotnet_scripts/dotnet_run.sh"
  acl         = "private"
  source_hash = filemd5("${path.module}/dotnet_scripts/dotnet_run.sh")
}

resource "aws_s3_object" "rds_userdata" {
  bucket      = aws_s3_bucket.long_user_data_bucket.id
  key         = "userdatas/rds_userdata.sh"
  source      = "${path.module}/userdatas/rds_userdata.sh"
  acl         = "private"
  source_hash = filemd5("${path.module}/userdatas/rds_userdata.sh")
}

#API_SERVER_FILES
resource "aws_s3_object" "program_cs" {
  bucket      = aws_s3_bucket.long_user_data_bucket.id
  key         = "dotnet_scripts/Program.cs"
  source      = "${path.module}/dotnet_scripts/Program.cs"
  acl         = "private"
  source_hash = filemd5("${path.module}/dotnet_scripts/Program.cs")
}

resource "aws_s3_object" "health_controller" {
  bucket      = aws_s3_bucket.long_user_data_bucket.id
  key         = "dotnet_scripts/Controllers/HealthController.cs"
  source      = "${path.module}/dotnet_scripts/Controllers/HealthController.cs"
  acl         = "private"
  source_hash = filemd5("${path.module}/dotnet_scripts/Controllers/HealthController.cs")
}

resource "aws_s3_object" "games_controller" {
  bucket      = aws_s3_bucket.long_user_data_bucket.id
  key         = "dotnet_scripts/Controllers/GamesController.cs"
  source      = "${path.module}/dotnet_scripts/Controllers/GamesController.cs"
  acl         = "private"
  source_hash = filemd5("${path.module}/dotnet_scripts/Controllers/GamesController.cs")
}

resource "aws_s3_object" "users_controller" {
  bucket      = aws_s3_bucket.long_user_data_bucket.id
  key         = "dotnet_scripts/Controllers/UsersController.cs"
  source      = "${path.module}/dotnet_scripts/Controllers/UsersController.cs"
  acl         = "private"
  source_hash = filemd5("${path.module}/dotnet_scripts/Controllers/UsersController.cs")
}

resource "aws_s3_object" "chat_controller" {
  bucket      = aws_s3_bucket.long_user_data_bucket.id
  key         = "dotnet_scripts/Controllers/ChatController.cs"
  source      = "${path.module}/dotnet_scripts/Controllers/ChatController.cs"
  acl         = "private"
  source_hash = filemd5("${path.module}/dotnet_scripts/Controllers/ChatController.cs")
}

resource "aws_s3_object" "user_db_context" {
  bucket      = aws_s3_bucket.long_user_data_bucket.id
  key         = "dotnet_scripts/DBContext/UserDbContext.cs"
  source      = "${path.module}/dotnet_scripts/DBContext/UserDbContext.cs"
  acl         = "private"
  source_hash = filemd5("${path.module}/dotnet_scripts/DBContext/UserDbContext.cs")
}

resource "aws_s3_object" "game_db_context" {
  bucket      = aws_s3_bucket.long_user_data_bucket.id
  key         = "dotnet_scripts/DBContext/GameDbContext.cs"
  source      = "${path.module}/dotnet_scripts/DBContext/GameDbContext.cs"
  acl         = "private"
  source_hash = filemd5("${path.module}/dotnet_scripts/DBContext/GameDbContext.cs")
}

resource "aws_s3_object" "chat_db_context" {
  bucket      = aws_s3_bucket.long_user_data_bucket.id
  key         = "dotnet_scripts/DBContext/ChatDbContext.cs"
  source      = "${path.module}/dotnet_scripts/DBContext/ChatDbContext.cs"
  acl         = "private"
  source_hash = filemd5("${path.module}/dotnet_scripts/DBContext/ChatDbContext.cs")
}

resource "aws_s3_object" "cognito_service" {
  bucket      = aws_s3_bucket.long_user_data_bucket.id
  key         = "dotnet_scripts/Services/CognitoService.cs"
  source      = "${path.module}/dotnet_scripts/Services/CognitoService.cs"
  acl         = "private"
  source_hash = filemd5("${path.module}/dotnet_scripts/Services/CognitoService.cs")
}

resource "aws_s3_object" "BcryptPasswordHasher" {
  bucket      = aws_s3_bucket.long_user_data_bucket.id
  key         = "dotnet_scripts/Services/BcryptPasswordHasher.cs"
  source      = "${path.module}/dotnet_scripts/Services/BcryptPasswordHasher.cs"
  acl         = "private"
  source_hash = filemd5("${path.module}/dotnet_scripts/Services/BcryptPasswordHasher.cs")
}

resource "aws_s3_object" "IPasswordHasher" {
  bucket      = aws_s3_bucket.long_user_data_bucket.id
  key         = "dotnet_scripts/Services/IPasswordHasher.cs"
  source      = "${path.module}/dotnet_scripts/Services/IPasswordHasher.cs"
  acl         = "private"
  source_hash = filemd5("${path.module}/dotnet_scripts/Services/IPasswordHasher.cs")
}

resource "aws_s3_object" "LoggingMidleWare" {
  bucket      = aws_s3_bucket.long_user_data_bucket.id
  key         = "dotnet_scripts/Services/RequestLoggingMiddleware.cs"
  source      = "${path.module}/dotnet_scripts/Services/RequestLoggingMiddleware.cs"
  acl         = "private"
  source_hash = filemd5("${path.module}/dotnet_scripts/Services/RequestLoggingMiddleware.cs")
}

#WEB_SOCKET_FILES
resource "aws_s3_object" "ws_package_json" {
  bucket      = aws_s3_bucket.long_user_data_bucket.id
  key         = "websocket_files/package.json"
  source      = "${path.module}/../Web/websocket_server/package.json"
  acl         = "private"
  source_hash = filemd5("${path.module}/../Web/websocket_server/package.json")
}

resource "aws_s3_object" "ws_serverjs" {
  bucket      = aws_s3_bucket.long_user_data_bucket.id
  key         = "websocket_files/server.js"
  source      = "${path.module}/../Web/websocket_server/server.js"
  acl         = "private"
  source_hash = filemd5("${path.module}/../Web/websocket_server/server.js")
}

resource "aws_s3_object" "ws_yarn_lock" {
  bucket      = aws_s3_bucket.long_user_data_bucket.id
  key         = "websocket_files/yarn.lock"
  source      = "${path.module}/../Web/websocket_server/yarn.lock"
  acl         = "private"
  source_hash = filemd5("${path.module}/../Web/websocket_server/yarn.lock")
}
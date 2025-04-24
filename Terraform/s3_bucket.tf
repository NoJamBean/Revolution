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


# Build 파일 저장용 버킷 생성
resource "aws_s3_bucket" "my_pipelines_first_artifact_bucket" {
  bucket        = "webdeploy-artifact-bucket" # 전 세계 유일한 이름 필요
  force_destroy = true


  tags = {
    Name        = "codebuild-artifact-bucket"
    Environment = "production"
  }
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

# 버킷 퍼블릭 액세스 차단
resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.my_pipelines_first_artifact_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
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
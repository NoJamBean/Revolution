resource "aws_s3_bucket" "long_user_data_bucket" {
  bucket = "long-user-data-bucket"
  
  lifecycle {
    prevent_destroy = false  # S3 버킷 삭제가 가능하도록 설정
  }

  tags = {
    Name        = "Long User Data Bucket"
    Environment = "Dev"
  }
}


resource "random_id" "bucket_suffix" {
  byte_length = 8
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = "logs-${random_id.bucket_suffix.hex}"
  force_destroy = true
  
  lifecycle {
    prevent_destroy = false  # S3 버킷 삭제가 가능하도록 설정
  }
  

  tags = {
    Name        = "LOG BUCKET"
    Environment = "Dev"
  }
}

resource "aws_s3_object" "api_server_script" {
  bucket = aws_s3_bucket.long_user_data_bucket.id
  key    = "api_server.sh"
  source = "${path.module}/userdatas/api_server.sh"
  acl    = "private"

  # 파일 변경이 감지되면 항상 덮어쓰기
  source_hash = filemd5("${path.module}/userdatas/api_server.sh")
}

resource "aws_s3_object" "users_controller" {
  bucket       = aws_s3_bucket.long_user_data_bucket.id
  key          = "dotnet_scripts/UsersController.cs"
  source       = "${path.module}/dotnet_scripts/UsersController.cs"
  acl          = "private"
  source_hash  = filemd5("${path.module}/dotnet_scripts/UsersController.cs")
}

resource "aws_s3_object" "games_controller" {
  bucket       = aws_s3_bucket.long_user_data_bucket.id
  key          = "dotnet_scripts/GamesController.cs"
  source       = "${path.module}/dotnet_scripts/GamesController.cs"
  acl          = "private"
  source_hash  = filemd5("${path.module}/dotnet_scripts/GamesController.cs")
}

resource "aws_s3_object" "program_cs" {
  bucket       = aws_s3_bucket.long_user_data_bucket.id
  key          = "dotnet_scripts/Program.cs"
  source       = "${path.module}/dotnet_scripts/Program.cs"
  acl          = "private"
  source_hash  = filemd5("${path.module}/dotnet_scripts/Program.cs")
}

resource "aws_s3_object" "user_db_context" {
  bucket       = aws_s3_bucket.long_user_data_bucket.id
  key          = "dotnet_scripts/UserDbContext.cs"
  source       = "${path.module}/dotnet_scripts/UserDbContext.cs"
  acl          = "private"
  source_hash  = filemd5("${path.module}/dotnet_scripts/UserDbContext.cs")
}

resource "aws_s3_object" "game_db_context" {
  bucket       = aws_s3_bucket.long_user_data_bucket.id
  key          = "dotnet_scripts/GameDbContext.cs"
  source       = "${path.module}/dotnet_scripts/GameDbContext.cs"
  acl          = "private"
  source_hash  = filemd5("${path.module}/dotnet_scripts/GameDbContext.cs")
}

resource "aws_s3_object" "dotnet_run_script" {
  bucket       = aws_s3_bucket.long_user_data_bucket.id
  key          = "dotnet_scripts/dotnet_run.sh"
  source       = "${path.module}/dotnet_scripts/dotnet_run.sh"
  acl          = "private"
  source_hash  = filemd5("${path.module}/dotnet_scripts/dotnet_run.sh")
}

resource "aws_s3_object" "appsettings_json" {
  bucket       = aws_s3_bucket.long_user_data_bucket.id
  key          = "dotnet_scripts/appsettings.json"
  source       = "${path.module}/dotnet_scripts/appsettings.json"
  acl          = "private"
  source_hash  = filemd5("${path.module}/dotnet_scripts/appsettings.json")
}



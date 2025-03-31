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


resource "aws_s3_bucket_object" "user_data_file" {
  bucket = aws_s3_bucket.long_user_data_bucket.bucket
  key    = "api_server.sh"
  source = "userdatas/api_server.sh"

  etag = filemd5("userdatas/api_server.sh")
}


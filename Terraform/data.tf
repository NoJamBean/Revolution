# Amazon Linux 2 AMI 찾기
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical 공식 AWS 계정 ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

#TemplateFiles
//정원빈 수정
data "template_file" "app_server" {
  template = file("userdatas/web_server.sh")

  vars = {
    # cognito_user_id    = split(":", aws_db_instance.mysql_multi_az.endpoint)[0]
    # db_username    = var.db_username
    # db_password    = var.db_password
  }
}

data "template_file" "websocket_server" {
  template = file("userdatas/websocket_server.sh")

  vars = {
    bucket_name = aws_s3_bucket.long_user_data_bucket.bucket
    redis_endpoint = aws_elasticache_replication_group.redis.primary_endpoint_address
  }
}

#Route53
data "aws_route53_zone" "public" {
  name         = var.public_domain_name
  private_zone = false
}

data "aws_route53_zone" "private" {
  name         = var.private_domain_name
  private_zone = true
}

data "aws_caller_identity" "current" {}

# data "aws_iam_role" "lambda_execution_role_1" {
#   name = "lambda-s3-opensearch-role"
# }

# data "aws_iam_role" "lambda_execution_role_2" {
#   name = "metric-stream-to-firehose-role"
# }

# data "aws_iam_role" "lambda_execution_role_3" {
#   name = "firehose-s3-delivery-role"
# }

#ACM
# data "aws_acm_certificate" "alb_cert" {
#   # arn = var.acm_arn  # 인증서 ARN을 입력하세요
#   domain = "1bean.shop"

#   most_recent = true  # 가장 최근의 인증서를 선택
#   statuses = ["ISSUED"]
#   types       = ["AMAZON_ISSUED"]
# }

# # 인증서 검증 정보 가져오기 (선택 사항)
# data "aws_acm_certificate_validation" "alb_cert_validation" {
#   certificate_arn = data.aws_acm_certificate.alb_cert.arn
# }

data "aws_elb_service_account" "main" {}
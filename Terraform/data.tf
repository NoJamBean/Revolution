# Amazon Linux 2 AMI 찾기
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
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
    # file_userscontroller = file("${path.module}/dotnet_scripts/UsersController.cs")
    # file_gamescontroller = file("${path.module}/dotnet_scripts/GamesController.cs")
    # file_programcs = file("${path.module}/dotnet_scripts/Program.cs")
    # file_userdbcontext = file("${path.module}/dotnet_scripts/UserDbContext.cs")
    # file_gamedbcontext = file("${path.module}/dotnet_scripts/GameDbContext.cs")
    # cognito_user_pool = aws_cognito_user_pool.user_pool.id
    # cognito_app_client = aws_cognito_user_pool_client.app_client.id
  }
}

data "aws_s3_bucket_object" "api_server_file" {
  depends_on = [aws_s3_object.api_server_script]

  bucket = aws_s3_bucket.long_user_data_bucket.bucket   # S3 버킷 이름
  key    = "api_server.sh"  # S3 객체 키
}

data "template_file" "rds_user_data" {
  template = file("userdatas/rds_userdata.sh")

  vars = {
    db_endpoint    = split(":", aws_db_instance.mysql_multi_az.endpoint)[0]
    db_username    = var.db_username
    db_password    = var.db_password
    cognito_user_id = aws_cognito_user.dummy_user.id
  }
}

#Route53
# data "aws_route53_zone" "public" {
#   name         = var.public_domain_name
#   private_zone = false
# }

data "aws_route53_zone" "private" {
  name         = var.private_domain_name
  private_zone = true
}
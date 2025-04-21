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
  }
}

# data "template_file" "rds_user_data" {
#   template = file("userdatas/rds_userdata.sh")

#   vars = {
#     db_endpoint     = var.rds_dns
#     db_username     = var.db_username
#     db_password     = var.db_password
#     cognito_user_id = aws_cognito_user.dummy_user.id
#   }
# }

#Route53
# data "aws_route53_zone" "public" {
#   name         = var.public_domain_name
#   private_zone = false
# }

data "aws_route53_zone" "private" {
  name         = var.private_domain_name
  private_zone = true
}

data "aws_caller_identity" "current" {}




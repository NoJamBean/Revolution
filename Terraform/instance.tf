#DotNet Backend Server1
#정원빈 수정

# Web 서버 접속 테스트용 인스턴스
# resource "aws_instance" "api_test_server" {
#   ami                  = data.aws_ami.amazon_linux.id
#   instance_type        = "t3.micro"
#   subnet_id            = aws_subnet.subnet["app1"].id
#   security_groups      = [aws_security_group.default_sg.id]
#   key_name             = var.seoul_key_name
#   source_dest_check    = false
#   iam_instance_profile = aws_iam_instance_profile.ec2_ssm_profile.name

#   credit_specification {
#     cpu_credits = "standard"
#   }

#   user_data = file("userdatas/web_server.sh")




#   tags = {
#     Name = "NAT-INSTANCE-1"
#   }
# }



resource "aws_instance" "nat_instance1" {
  ami               = data.aws_ami.amazon_linux.id
  instance_type     = "t3.micro"
  subnet_id         = aws_subnet.subnet["nat1"].id
  security_groups   = [aws_security_group.default_sg.id]
  key_name          = var.seoul_key_name
  source_dest_check = false

  credit_specification {
    cpu_credits = "standard"
  }

  user_data = file("userdatas/nat.sh")

  tags = {
    Name = "NAT-INSTANCE-1"
  }
}

# resource "aws_instance" "nat_instance2" {
#   ami             = data.aws_ami.amazon_linux.id
#   instance_type   = "t3.micro"
#   subnet_id       = aws_subnet.subnet["nat2"].id
#   security_groups = [aws_security_group.default_sg.id]
#   key_name        = var.seoul_key_name
#   source_dest_check = false

#   credit_specification {
#     cpu_credits = "standard"
#   }

#   user_data = file("userdatas/nat.sh")

#   tags = {
#     Name = "NAT-INSTANCE-2"
#   }
# }

resource "aws_instance" "api_server_1" {
  depends_on           = [aws_instance.nat_instance1]
  ami                  = data.aws_ami.amazon_linux.id
  instance_type        = "t3.medium" //var.instance_type
  subnet_id            = aws_subnet.subnet["api1"].id
  security_groups      = [aws_security_group.dotnet_sg.id]
  key_name             = var.seoul_key_name
  iam_instance_profile = aws_iam_instance_profile.api_server_profile.name
  private_ip           = "10.0.100.100"

  credit_specification {
    cpu_credits = "standard"
  }

  #user_data = data.template_file.api_server.rendered
  user_data = <<-EOT
#!/bin/bash
    
set -e

sudo tee -a /etc/environment > /dev/null <<EOL
DB_ENDPOINT="${var.rds_dns}"
DB_USERNAME="${var.db_username}"
DB_PASSWORD="${var.db_password}"
COGNITO_USER_POOL="${aws_cognito_user_pool.user_pool.id}"
COGNITO_APP_CLIENT="${aws_cognito_user_pool_client.app_client.id}"
API_SERVER_DNS="${var.api_dns}"

S3_BUCKET="${aws_s3_bucket.long_user_data_bucket.bucket}"
S3_LOG_BUCKET="${aws_s3_bucket.log_bucket.bucket}"
LOCAL_PATH="/var/www/dotnet-api/MyApi"
EOL

source /etc/environment

export S3_BUCKET="${aws_s3_bucket.long_user_data_bucket.bucket}"
export LOCAL_PATH="/var/www/dotnet-api/MyApi"

sudo aws s3 cp s3://$S3_BUCKET/api_server.sh /home/ec2-user/api_server.sh
sudo chmod +x /home/ec2-user/api_server.sh
sudo /home/ec2-user/api_server.sh
EOT

  tags = {
    Name = "DotNet-API-SERVER"
  }
}
# AGW_URL="https://${aws_api_gateway_rest_api.rest_api.id}.execute-api.ap-northeast-2.amazonaws.com"



#DB접근용 인스턴스
#정원빈
# resource "aws_instance" "rds_access_instance" {
#   depends_on                  = [aws_instance.nat_instance1]
#   provider                    = aws
#   ami                         = data.aws_ami.amazon_linux.id
#   instance_type               = var.instance_type
#   key_name                    = var.seoul_key_name
#   subnet_id                   = aws_subnet.subnet["rds1"].id
#   security_groups             = [aws_security_group.default_sg.id]

#   tags = { Name = "RDS-ACCESS-Instance" }

#   user_data = data.template_file.rds_user_data.rendered
# }

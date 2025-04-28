resource "aws_instance" "nat_instance1" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.subnet["nat1"].id
  vpc_security_group_ids = [aws_security_group.default_sg.id]
  key_name               = var.seoul_key_name
  source_dest_check      = false
  associate_public_ip_address = true
  private_ip = "10.0.20.100"

  credit_specification {
    cpu_credits = "standard"
  }

  user_data = file("userdatas/nat.sh")

  tags = {
    Name = "NAT-INSTANCE-1"
  }
}


resource "aws_instance" "nat_instance2" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.subnet["nat2"].id
  vpc_security_group_ids = [aws_security_group.default_sg.id]
  key_name               = var.seoul_key_name
  source_dest_check      = false
  associate_public_ip_address = true
  private_ip = "10.0.21.100"

  credit_specification {
    cpu_credits = "standard"
  }

  user_data = file("userdatas/nat.sh")

  tags = {
    Name = "NAT-INSTANCE-2"
  }
}

# WebSocket용 인스턴스 
# 송현섭
resource "aws_instance" "websocket_1" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.subnet["ws1"].id
  vpc_security_group_ids = [aws_security_group.websocket_sg.id]
  key_name               = var.seoul_key_name # SSH용 키 페어
  iam_instance_profile = aws_iam_instance_profile.api_server_profile.name
  private_ip = "10.0.15.100"
  
  user_data = data.template_file.websocket_server.rendered

  tags = {
    Name = "WebSocketServer1"
  }
}

resource "aws_instance" "websocket_2" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.subnet["ws2"].id
  vpc_security_group_ids = [aws_security_group.websocket_sg.id]
  key_name               = var.seoul_key_name # SSH용 키 페어
  iam_instance_profile = aws_iam_instance_profile.api_server_profile.name
  private_ip = "10.0.16.100"
  
  user_data = data.template_file.websocket_server.rendered

  tags = {
    Name = "WebSocketServer2"
  }
}



resource "aws_instance" "api_server_1" {
  depends_on             = [aws_instance.nat_instance1]
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3a.medium" //var.instance_type
  subnet_id              = aws_subnet.subnet["api1"].id
  vpc_security_group_ids = [aws_security_group.dotnet_sg.id]
  key_name               = var.seoul_key_name
  iam_instance_profile   = aws_iam_instance_profile.api_server_profile.name
  private_ip             = "10.0.100.100"

  credit_specification {
    cpu_credits = "standard"
  }

  user_data = <<-EOT
#!/bin/bash
    
set -e

sudo tee -a /etc/environment > /dev/null <<EOL
DB_ENDPOINT="${split(":", aws_db_instance.mysql_multi_az.endpoint)[0]}"
DB_ENDPOINT_RO="${split(":", aws_db_instance.mysql_read_replica.endpoint)[0]}"
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

sudo aws s3 cp s3://$S3_BUCKET/userdatas/api_server.sh /tmp/api_server.sh
sudo chmod +x /tmp/api_server.sh
sudo /tmp/api_server.sh
EOT

  tags = {
    Name = "DotNet-API-SERVER1"
  }
}

resource "aws_instance" "api_server_2" {
  depends_on             = [aws_instance.nat_instance1]
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3a.medium" //var.instance_type
  subnet_id              = aws_subnet.subnet["api2"].id
  vpc_security_group_ids = [aws_security_group.dotnet_sg.id]
  key_name               = var.seoul_key_name
  iam_instance_profile   = aws_iam_instance_profile.api_server_profile.name
  private_ip             = "10.0.101.100"

  credit_specification {
    cpu_credits = "standard"
  }

  user_data = <<-EOT
#!/bin/bash
    
set -e

sudo tee -a /etc/environment > /dev/null <<EOL
DB_ENDPOINT="${split(":", aws_db_instance.mysql_multi_az.endpoint)[0]}"
DB_ENDPOINT_RO="${split(":", aws_db_instance.mysql_read_replica.endpoint)[0]}"
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

sudo aws s3 cp s3://$S3_BUCKET/userdatas/api_server.sh /tmp/api_server.sh
sudo chmod +x /tmp/api_server.sh
sudo /tmp/api_server.sh
EOT

  tags = {
    Name = "DotNet-API-SERVER2"
  }
}
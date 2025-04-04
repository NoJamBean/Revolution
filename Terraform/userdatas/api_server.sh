#!/bin/bash

sudo source /etc/environment

sudo yum update -y
sudo yum install -y amazon-linux-extras

# Microsoft 리포지토리 추가
wget https://packages.microsoft.com/config/rhel/7/prod.repo
sudo mv prod.repo /etc/yum.repos.d/microsoft-prod.repo
sudo yum install -y dotnet-sdk-6.0

# 디렉토리 생성
sudo mkdir -p $LOCAL_PATH $LOCAL_PATH/Controllers $LOCAL_PATH/Data /var/log/api $LOCAL_PATH/Service
sudo chown -R ec2-user:ec2-user /var/www/dotnet-api
cd $LOCAL_PATH
sudo dotnet new webapi

# Entity Framework Core 패키지 추가
sudo dotnet add package AWSSDK.CognitoIdentityProvider
sudo dotnet add package AWSSDK.S3 --version 3.7.0
sudo dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer --version 6.0.26
sudo dotnet add package Microsoft.AspNetCore.Authorization --version 6.0.0
sudo dotnet add package Microsoft.Bcl.AsyncInterfaces --version 6.0.0
sudo dotnet add package Microsoft.EntityFrameworkCore.Design --version 6.0.0
sudo dotnet add package Microsoft.EntityFrameworkCore.SqlServer --version 6.0.0
sudo dotnet add package Pomelo.EntityFrameworkCore.MySql --version 6.0.0
sudo dotnet add package Serilog --version 4.1.0
sudo dotnet add package Serilog.AspNetCore --version 4.1.0
sudo dotnet add package Serilog.Sinks.Console --version 4.1.0
sudo dotnet add package System.IO.Pipelines --version 6.0.0
sudo dotnet add package System.Text.Json --version 6.0.0

# curl -u "username:your_personal_access_token" -sL https://raw.githubusercontent.com/사용자명/저장소명/브랜치명/경로/파일명 | sudo tee /경로/파일명 > /dev/null

sudo chown -R ec2-user:ec2-user ~/.dotnet
sudo chmod -R 755 ~/.dotnet

# /var/log/api 디렉토리의 소유자를 ec2-user로 변경합니다.
sudo chown -R ec2-user:ec2-user /var/log/api
sudo chmod -R 777 /var/log/api

sudo chown nginx:nginx /var/log/nginx
sudo chmod -R 777 /var/log/nginx

sudo chown -R ec2-user:ec2-user /usr/share/dotnet
sudo chmod -R 755 /usr/share/dotnet

# S3에서 설정 파일 다운로드
# sudo aws s3 cp s3://$S3_BUCKET/dotnet_scripts/appsettings.json $LOCAL_PATH/appsettings.json

# S3에서 주요 프로젝트 파일 다운로드
sudo aws s3 cp s3://$S3_BUCKET/dotnet_scripts/Program.cs $LOCAL_PATH/Program.cs
sudo aws s3 cp s3://$S3_BUCKET/dotnet_scripts/UserDbContext.cs $LOCAL_PATH/Data/UserDbContext.cs
sudo aws s3 cp s3://$S3_BUCKET/dotnet_scripts/GameDbContext.cs $LOCAL_PATH/Data/GameDbContext.cs
sudo aws s3 cp s3://$S3_BUCKET/dotnet_scripts/UsersController.cs $LOCAL_PATH/Controllers/UsersController.cs
sudo aws s3 cp s3://$S3_BUCKET/dotnet_scripts/GamesController.cs $LOCAL_PATH/Controllers/GamesController.cs
sudo aws s3 cp s3://$S3_BUCKET/dotnet_scripts/CognitoService.cs $LOCAL_PATH/Service/CognitoService.cs

sudo aws s3 cp s3://$S3_BUCKET/dotnet_scripts/dotnet_run.sh ~/run

# 종속성 복원 및 빌드
cd $LOCAL_PATH
sudo dotnet restore
sudo dotnet publish -c Release -o $LOCAL_PATH/published


# systemd 서비스 설정
sudo tee /etc/systemd/system/dotnet-api.service > /dev/null <<EOL
[Unit]
Description=My .NET API Application
After=network.target

[Service]
EnvironmentFile=/etc/environment
Environment="S3_LOG_BUCKET=$S3_LOG_BUCKET"
WorkingDirectory=$LOCAL_PATH/published
ExecStart=/usr/bin/dotnet $LOCAL_PATH/published/MyApi.dll
Restart=always
RestartSec=10
SyslogIdentifier=dotnet-api
User=ec2-user
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=DOTNET_CLI_HOME=/home/ec2-user
Environment=HOME=/home/ec2-user

[Install]
WantedBy=multi-user.target
EOL

# systemd 서비스 시작
sudo systemctl daemon-reload
sudo systemctl enable dotnet-api
sudo systemctl start dotnet-api

# Nginx 설치 및 설정
sudo amazon-linux-extras enable nginx1
sudo yum install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# Nginx 프록시 설정
INSTANCE_PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
sudo tee /etc/nginx/conf.d/dotnet-api.conf > /dev/null <<EOL
server {
    listen 80;
    server_name $INSTANCE_PRIVATE_IP;

    location / {
        proxy_pass http://localhost:5000;
        # proxy_pass_request_headers on;

        # CORS 설정 추가
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' '*' always;
        add_header 'Access-Control-Allow-Credentials' 'true' always; # Credential 허용

        # OPTIONS 요청 처리 (Preflight 요청에 응답)
        if (\$request_method = OPTIONS) {
            add_header 'Access-Control-Allow-Origin' '*';
            add_header 'Access-Control-Allow-Methods' 'GET, POST';
            add_header 'Access-Control-Allow-Headers' '*';
            add_header 'Access-Control-Allow-Credentials' 'true';
            return 204; # No Content 응답
        }
    }
}
EOL

sudo systemctl restart nginx

sudo chmod +x ~/run
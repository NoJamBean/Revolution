#!/bin/bash
set -e  # 에러 발생 시 스크립트 중단

# 시스템 업데이트 및 필수 패키지 설치
sudo yum update -y
sudo yum install -y wget curl unzip amazon-linux-extras

# Microsoft 리포지토리 추가
wget https://packages.microsoft.com/config/rhel/7/prod.repo
sudo mv prod.repo /etc/yum.repos.d/microsoft-prod.repo
sudo yum install -y dotnet-sdk-6.0

# 애플리케이션 디렉토리 생성 및 프로젝트 생성
sudo mkdir -p /var/www/dotnet-api/MyApi
cd /var/www/dotnet-api/MyApi
sudo dotnet new webapi

# Entity Framework Core 패키지 추가
sudo dotnet add package Microsoft.EntityFrameworkCore.SqlServer --version 6.0.0
sudo dotnet add package Microsoft.EntityFrameworkCore.Design --version 6.0.0
sudo dotnet add package Pomelo.EntityFrameworkCore.MySql --version 6.0.0
sudo dotnet add package System.IO.Pipelines --version 6.0.0
sudo dotnet add package Microsoft.Bcl.AsyncInterfaces --version 6.0.0
sudo dotnet add package System.Text.Json --version 6.0.0
sudo dotnet add package Serilog --version 2.10.0
sudo dotnet add package Serilog.Sinks.Console --version 4.1.0
sudo dotnet add package Serilog.AspNetCore --version 4.1.0

# ValuesController.cs 파일 생성
# curl -u "username:your_personal_access_token" -sL https://raw.githubusercontent.com/사용자명/저장소명/브랜치명/경로/파일명 | sudo tee /경로/파일명 > /dev/null
sudo tee Controllers/UsersController.cs > /dev/null <<EOF
${file_userscontroller}
EOF

sudo tee Controllers/GamesController.cs > /dev/null <<EOF
${file_gamescontroller}
EOF

sudo tee /var/www/dotnet-api/MyApi/Program.cs > /dev/null <<EOF
${file_programcs}
EOF

sudo mkdir -p /var/log/api

# /var/log/api 디렉토리의 소유자를 ec2-user로 변경합니다.
sudo chown -R ec2-user:ec2-user /var/log/api
sudo chmod -R 755 /var/log/api


sudo tee appsettings.json > /dev/null <<EOL
{
  "ConnectionStrings": {
    "UserDbConnection": "Server=${db_endpoint};Database=userDB;User=${db_username};Password=${db_password};SslMode=Preferred;",
    "GameDbConnection": "Server=${db_endpoint};Database=gameDB;User=${db_username};Password=${db_password};SslMode=Preferred;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft": "Warning",
      "Microsoft.Hosting.Lifetime": "Information"
    }
  },
  "Serilog": {
    "Using": [ "Serilog.Sinks.File" ],
    "WriteTo": [
      {
        "Name": "File",
        "Args": {
          "path": "/var/log/api/myapi.log",
          "rollingInterval": "Day",
          "retainedFileCountLimit": 7
        }
      }
    ]
  },
  "Cognito": {
    "UserPoolId": "${cognito_user_pool}",
    "AppClientId": "${cognito_app_client}"
  }
}
EOL

# 모델 및 DB 컨텍스트 추가
sudo mkdir -p Data

# DbContext.cs 생성
sudo tee Data/UserDbContext.cs > /dev/null <<EOF
${file_userdbcontext}
EOF

sudo tee Data/GameDbContext.cs > /dev/null <<EOF
${file_gamedbcontext}
EOF

# 종속성 복원 및 빌드
sudo dotnet restore
sudo dotnet publish -c Release -o /var/www/dotnet-api/MyApi/published

# systemd 서비스 설정
sudo tee /etc/systemd/system/dotnet-api.service > /dev/null <<'EOL'
[Unit]
Description=My .NET API Application
After=network.target

[Service]
WorkingDirectory=/var/www/dotnet-api/MyApi/published
ExecStart=/usr/bin/dotnet /var/www/dotnet-api/MyApi/published/MyApi.dll
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
INSTANCE_PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
sudo tee /etc/nginx/conf.d/dotnet-api.conf > /dev/null <<EOL
server {
    listen 80;
    server_name $INSTANCE_PUBLIC_IP;

    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # CORS 헤더 추가
    add_header 'Access-Control-Allow-Origin' '*' always;
    add_header 'Access-Control-Allow-Methods' 'GET, POST' always;
    add_header 'Access-Control-Allow-Headers' 'Origin, X-Requested-With, Content-Type, Accept, Authorization' always;
}
EOL

sudo systemctl restart nginx

sudo tee ~/run > /dev/null <<EOF
${file_dotnet_run}
EOF

sudo chmod +x ~/run
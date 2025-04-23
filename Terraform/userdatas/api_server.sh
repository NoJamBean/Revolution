#!/bin/bash

sudo source /etc/environment

sudo yum update -y
sudo yum install -y amazon-linux-extras mysql
sudo amazon-linux-extras enable nginx1
sudo yum install -y nginx

#inotify 설치
sudo yum groupinstall "Development Tools" -y
sudo yum install -y wget gcc make autoconf

cd /tmp
wget https://github.com/rvoicilas/inotify-tools/archive/refs/tags/3.20.11.0.tar.gz -O inotify-tools.tar.gz
tar -xzf inotify-tools.tar.gz
cd inotify-tools-3.20.11.0

./autogen.sh
./configure
make
sudo make install

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
sudo dotnet add package BCrypt.Net-Next --version 4.0.2
sudo dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer --version 6.0.26
sudo dotnet add package Microsoft.AspNetCore.Authorization --version 6.0.0
sudo dotnet add package Microsoft.Bcl.AsyncInterfaces --version 6.0.0
sudo dotnet add package Microsoft.EntityFrameworkCore.Design --version 6.0.0
sudo dotnet add package Microsoft.EntityFrameworkCore.SqlServer --version 6.0.0
sudo dotnet add package Microsoft.Extensions.DependencyInjection --version 6.0.0
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

sudo chown -R ec2-user:ec2-user /var/log/nginx
sudo chmod -R 777 /var/log/nginx

sudo chown -R ec2-user:ec2-user /usr/share/dotnet
sudo chmod -R 755 /usr/share/dotnet

# S3에서 설정 파일 다운로드
# sudo aws s3 cp s3://$S3_BUCKET/dotnet_scripts/appsettings.json $LOCAL_PATH/appsettings.json
sudo aws s3 cp s3://$S3_BUCKET/userdatas/rds_userdata.sh /home/ec2-user/rdsuserdata.sh
sudo chmod +x /home/ec2-user/rdsuserdata.sh
sudo /home/ec2-user/rdsuserdata.sh

# S3에서 주요 프로젝트 파일 다운로드
sudo aws s3 cp s3://$S3_BUCKET/dotnet_scripts/Program.cs $LOCAL_PATH/Program.cs

sudo aws s3 cp s3://$S3_BUCKET/dotnet_scripts/Controllers/ChatController.cs $LOCAL_PATH/Controllers/ChatController.cs
sudo aws s3 cp s3://$S3_BUCKET/dotnet_scripts/Controllers/GamesController.cs $LOCAL_PATH/Controllers/GamesController.cs
sudo aws s3 cp s3://$S3_BUCKET/dotnet_scripts/Controllers/HealthController.cs $LOCAL_PATH/HealthController.cs
sudo aws s3 cp s3://$S3_BUCKET/dotnet_scripts/Controllers/UsersController.cs $LOCAL_PATH/Controllers/UsersController.cs
sudo aws s3 cp s3://$S3_BUCKET/dotnet_scripts/DBContext/ChatDbContext.cs $LOCAL_PATH/Data/ChatDbContext.cs
sudo aws s3 cp s3://$S3_BUCKET/dotnet_scripts/DBContext/GameDbContext.cs $LOCAL_PATH/Data/GameDbContext.cs
sudo aws s3 cp s3://$S3_BUCKET/dotnet_scripts/DBContext/UserDbContext.cs $LOCAL_PATH/Data/UserDbContext.cs
sudo aws s3 cp s3://$S3_BUCKET/dotnet_scripts/Services/BcryptPasswordHasher.cs $LOCAL_PATH/Service/BcryptPasswordHasher.cs
sudo aws s3 cp s3://$S3_BUCKET/dotnet_scripts/Services/CognitoService.cs $LOCAL_PATH/Service/CognitoService.cs
sudo aws s3 cp s3://$S3_BUCKET/dotnet_scripts/Services/IPasswordHasher.cs $LOCAL_PATH/Service/IPasswordHasher.cs
sudo aws s3 cp s3://$S3_BUCKET/dotnet_scripts/Services/RequestLoggingMiddleware.cs $LOCAL_PATH/Service/RequestLoggingMiddleware.cs

sudo aws s3 cp s3://$S3_BUCKET/dotnet_scripts/dotnet_run.sh ~/run.sh

# 종속성 복원 및 빌드
cd $LOCAL_PATH
sudo dotnet restore
sudo dotnet publish -c Release -o $LOCAL_PATH/published


sudo tee /usr/local/bin/watch_nginx_log_upload.sh > /dev/null <<'EOL'
#!/bin/bash

LOG_FILES=("/var/log/nginx/access.log" "/var/log/nginx/error.log")
WATCH_LOG="/var/log/api/nginx_watch.log"

echo "[Watcher] Starting Nginx log watcher..." >> "${WATCH_LOG}"

for LOG_FILE in "${LOG_FILES[@]}"; do
  (
    echo "[Watcher] Watching ${LOG_FILE} for changes..." >> "${WATCH_LOG}"

    while inotifywait -e modify "${LOG_FILE}"; do
      # 한국 시간 기준 타임스탬프
      TZ="Asia/Seoul" TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
      BASENAME=$(basename "${LOG_FILE}")
      DEST_FILENAME="${BASENAME%.*}-${TIMESTAMP}.${BASENAME##*.}"
      S3_DEST="s3://${S3_LOG_BUCKET}/API_Server/nginx/${DEST_FILENAME}"

      echo "[Watcher] Change detected in ${LOG_FILE}, uploading to ${S3_DEST}..." >> "${WATCH_LOG}"
      aws s3 cp "${LOG_FILE}" "${S3_DEST}" >> "${WATCH_LOG}" 2>&1
    done
  ) &
done

wait
EOL

# 실행 권한 부여
sudo chmod +x /usr/local/bin/watch_nginx_log_upload.sh

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

sudo tee /etc/systemd/system/nginx-log-watcher.service > /dev/null <<EOL
[Unit]
Description=Nginx Log Watcher Service
After=network.target

[Service]
EnvironmentFile=/etc/environment
Environment="S3_LOG_BUCKET=${S3_LOG_BUCKET}"
ExecStart=/usr/local/bin/watch_nginx_log_upload.sh
Restart=always
RestartSec=5
User=ec2-user
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOL

# systemd 서비스 시작
sudo systemctl daemon-reload
sudo systemctl enable dotnet-api
sudo systemctl enable nginx-log-watcher
sudo systemctl start dotnet-api
sudo systemctl start nginx-log-watcher

# Nginx 설치 및 설정
sudo systemctl enable nginx
sudo systemctl start nginx

# Nginx 프록시 설정
sudo tee /etc/nginx/conf.d/dotnet-api.conf > /dev/null <<EOL
server {
    listen 80;
    server_name ${API_SERVER_DNS};

    location / {
        proxy_pass http://localhost:5000;
    }
}
EOL

sudo systemctl restart nginx

sudo chmod +x ~/run.sh
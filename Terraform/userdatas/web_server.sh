#!/bin/bash
set -e

apt-get update -y
apt-get upgrade -y

apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# 도커 공식 GPG 키 등록
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    gpg --dearmor -o /etc/apt/keyrings/docker.gpg

chmod a+r /etc/apt/keyrings/docker.gpg

# 저장소 추가
echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io

systemctl enable docker
systemctl start docker

# 3. Docker Compose 플러그인 설치 (v2 방식)
mkdir -p /home/ubuntu/.docker/cli-plugins/
curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
  -o /home/ubuntu/.docker/cli-plugins/docker-compose
chmod +x /home/ubuntu/.docker/cli-plugins/docker-compose
chown -R ubuntu:ubuntu /home/ubuntu/.docker

# 4. CodeDeploy Agent 설치
apt-get install -y ruby wget

cd /home/ubuntu
wget https://aws-codedeploy-ap-northeast-2.s3.amazonaws.com/latest/install
chmod +x ./install
./install auto
systemctl start codedeploy-agent
systemctl enable codedeploy-agent

apt install -y nginx

systemctl enable nginx
systemctl start nginx

sudo tee /etc/nginx/conf.d/webserver.conf > /dev/null <<EOL
server {
    listen 80;
    server_name www.1bean.shop;

    # API 프록시 (프라이빗 ALB)
    location /api/ {
        proxy_pass https://alb.backend.internal/api/;
        proxy_set_header Host alb.backend.internal;
        proxy_ssl_verify off;  # self-signed 인증서면 필요
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # WebSocket 프록시 (필요할 때만)
    location /ws/ {
        proxy_pass https://alb.backend.internal/ws/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_ssl_verify off;
        proxy_set_header Host alb.backend.internal;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # Next.js SSR (혹은 정적 파일 서비스)
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

sudo systemctl restart nginx


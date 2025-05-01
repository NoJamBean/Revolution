#!/bin/bash
# set -e

# apt-get update -y
# apt-get upgrade -y

# apt-get install -y \
#     ca-certificates \
#     curl \
#     gnupg \
#     lsb-release

# # 도커 공식 GPG 키 등록
# install -m 0755 -d /etc/apt/keyrings
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
#     gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# chmod a+r /etc/apt/keyrings/docker.gpg

# # 저장소 추가
# echo \
#   "deb [arch=$(dpkg --print-architecture) \
#   signed-by=/etc/apt/keyrings/docker.gpg] \
#   https://download.docker.com/linux/ubuntu \
#   $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# apt-get update -y
# apt-get install -y docker-ce docker-ce-cli containerd.io

# systemctl enable docker
# systemctl start docker

# # 3. Docker Compose 플러그인 설치 (v2 방식)
# mkdir -p /home/ubuntu/.docker/cli-plugins/
# curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
#   -o /home/ubuntu/.docker/cli-plugins/docker-compose
# chmod +x /home/ubuntu/.docker/cli-plugins/docker-compose
# chown -R ubuntu:ubuntu /home/ubuntu/.docker

# # 4. CodeDeploy Agent 설치
# apt-get install -y ruby wget

# cd /home/ubuntu
# wget https://aws-codedeploy-ap-northeast-2.s3.amazonaws.com/latest/install
# chmod +x ./install
# ./install auto
# systemctl start codedeploy-agent
# systemctl enable codedeploy-agent

# apt install -y nginx

# systemctl enable nginx
# systemctl start nginx

# sudo tee /etc/nginx/conf.d/webserver.conf > /dev/null <<EOL
# server {
#     listen 80;
#     server_name www.1bean.shop;

#     location = /api/log {
#         proxy_pass http://localhost:3000;
#         proxy_set_header Host \$host;
#         proxy_set_header X-Real-IP \$remote_addr;
#         proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
#         proxy_set_header X-Forwarded-Proto \$scheme;
#     }

#     # API 프록시 (프라이빗 ALB)
#     location /api/ {
#         proxy_pass http://alb.backend.internal/api/;
#         proxy_set_header Host alb.backend.internal;
#         proxy_set_header X-Real-IP \$remote_addr;
#         proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
#         proxy_set_header X-Forwarded-Proto \$scheme;
#     }

#     # WebSocket 프록시 (필요할 때만)
#     location /ws/ {
#         proxy_pass http://alb.backend.internal/ws/;
#         proxy_http_version 1.1;
#         proxy_set_header Upgrade \$http_upgrade;
#         proxy_set_header Connection "upgrade";
#         proxy_set_header Host alb.backend.internal;
#         proxy_set_header X-Real-IP \$remote_addr;
#         proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
#         proxy_set_header X-Forwarded-Proto \$scheme;
#     }

#     location = /ws {
#         proxy_pass http://alb.backend.internal/ws;
#         proxy_http_version 1.1;
#         proxy_set_header Upgrade \$http_upgrade;
#         proxy_set_header Connection "upgrade";
#         proxy_set_header Host alb.backend.internal;
#         proxy_set_header X-Real-IP \$remote_addr;
#         proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
#         proxy_set_header X-Forwarded-Proto \$scheme;
#     }

#     # Next.js SSR (혹은 정적 파일 서비스)
#     location / {
#         proxy_pass http://localhost:3000;
#         proxy_set_header Host \$host;
#         proxy_set_header X-Real-IP \$remote_addr;
#         proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
#         proxy_set_header X-Forwarded-Proto \$scheme;
#     }
# }
# EOL

# sudo systemctl restart nginx



# Create a folder
$ mkdir actions-runner && cd actions-runner
Copied!# Download the latest runner package
$ curl -o actions-runner-linux-x64-2.323.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.323.0/actions-runner-linux-x64-2.323.0.tar.gz
# Optional: Validate the hash
$ echo "0dbc9bf5a58620fc52cb6cc0448abcca964a8d74b5f39773b7afcad9ab691e19  actions-runner-linux-x64-2.323.0.tar.gz" | shasum -a 256 -c
Copied!# Extract the installer
$ tar xzf ./actions-runner-linux-x64-2.323.0.tar.gz

# Create the runner and start the configuration experience
$ ./config.sh --url https://github.com/NoJamBean/Revolution --token AZN76PSTX626ZSH7N6D7QZTICOND4
# Last step, run it!
$ ./run.sh
#!/bin/bash
sudo yum clean all
sudo yum update -y

# [1] Node.js 18.17.1 수동 설치
sudo wget -nv https://d3rnber7ry90et.cloudfront.net/linux-x86_64/node-v18.17.1.tar.gz
sudo mkdir -p /usr/local/lib/node
sudo tar -xf node-v18.17.1.tar.gz
sudo mv node-v18.17.1 /usr/local/lib/node/nodejs
sudo rm -f node-v18.17.1.tar.gz

echo 'export NODEJS_HOME=/usr/local/lib/node/nodejs' | sudo tee /etc/profile.d/node.sh
echo 'export PATH=$NODEJS_HOME/bin:$PATH' | sudo tee -a /etc/profile.d/node.sh
sudo chmod +x /etc/profile.d/node.sh
source /etc/profile.d/node.sh

sudo env "PATH=$PATH" npm install -g yarn pm2

# ec2-user 홈 디렉토리에 websocket 디렉토리 생성
sudo -u ec2-user mkdir -p /home/ec2-user/websocket

# S3에서 파일 복사
sudo aws s3 cp s3://${bucket_name}/websocket_files/package.json /home/ec2-user/websocket/package.json --region ap-northeast-2
sudo aws s3 cp s3://${bucket_name}/websocket_files/server.js /home/ec2-user/websocket/server.js --region ap-northeast-2
sudo aws s3 cp s3://${bucket_name}/websocket_files/yarn.lock /home/ec2-user/websocket/yarn.lock --region ap-northeast-2

# 디렉토리 권한 ec2-user로 재설정 (중요)
sudo chown -R ec2-user:ec2-user /home/ec2-user/websocket

# .env 파일을 ec2-user 권한으로 생성
sudo -u ec2-user bash -c "cat <<EOF > /home/ec2-user/websocket/.env
REDIS_URL=redis://${redis_endpoint}:6379
BACKEND_API_ENDPOINT=http://alb.backend.internal
EOF
"

# yarn install을 ec2-user로 실행
cd /home/ec2-user/websocket
sudo -u ec2-user env "PATH=$PATH" yarn install

# pm2를 ec2-user로 실행
sudo -u ec2-user env "PATH=$PATH" pm2 start server.js --name websocket-server
sudo -u ec2-user env "PATH=$PATH" pm2 save
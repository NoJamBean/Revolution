#!/bin/bash

# [1] Node.js 18.17.1 수동 설치
wget -nv https://d3rnber7ry90et.cloudfront.net/linux-x86_64/node-v18.17.1.tar.gz
mkdir -p /usr/local/lib/node
tar -xf node-v18.17.1.tar.gz
mv node-v18.17.1 /usr/local/lib/node/nodejs
rm -f node-v18.17.1.tar.gz

export NODEJS_HOME=/usr/local/lib/node/nodejs
export PATH=$NODEJS_HOME/bin:$PATH

echo "export NODEJS_HOME=/usr/local/lib/node/nodejs" > /etc/profile.d/node.sh
echo "export PATH=\$NODEJS_HOME/bin:\$PATH" >> /etc/profile.d/node.sh
chmod +x /etc/profile.d/node.sh
source /etc/profile.d/node.sh

# [2] 필수 글로벌 패키지 설치
npm install -g yarn pm2

# [3] 리포 클론 후 경로 이동
cd /home/ec2-user
git clone --filter=blob:none --no-checkout --branch web https://github.com/NoJamBean/Revolution.git Revolution

cd Revolution

# Sparse checkout 초기화
git sparse-checkout init --cone

# Web/websocket-server 폴더만 가져오기
git sparse-checkout set Web/websocket-server

# 선택된 경로만 checkout
git checkout

# 이후 Web/websocket-server 진입해서 작업
cd Web/websocket-server
echo "REDIS_URL=redis://${redis_host}:6379" > .env
yarn install
pm2 start server.js --name websocket-server
pm2 save
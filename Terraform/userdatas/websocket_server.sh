#!/bin/bash

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

cd /home/ec2-user
mkdir websocket
cd websocket

sudo aws s3 cp s3://${aws_s3_bucket.long_user_data_bucket.bucket}/websocket_files/package.json /home/ec2-user/websocket/package.json
sudo aws s3 cp s3://${aws_s3_bucket.long_user_data_bucket.bucket}/websocket_files/server.js /home/ec2-user/websocket/server.js
sudo aws s3 cp s3://${aws_s3_bucket.long_user_data_bucket.bucket}/websocket_files/yarn.lock /home/ec2-user/websocket/yarn.lock

# 이후 Web/websocket-server 진입해서 작업
cat <<EOF > /home/ec2-user/websocket/.env
REDIS_URL=redis://${aws_elasticache_replication_group.redis.primary_endpoint_address}:6379
BACKEND_API_ENDPOINT=http://api.backend.internal
EOF

yarn install
pm2 start server.js --name websocket-server
pm2 save
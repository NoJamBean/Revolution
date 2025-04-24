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
mkdir websocket
cd websocket

sudo aws s3 cp s3://${aws_s3_bucket.long_user_data_bucket.bucket}/websocket_files/package.json websocket/package.json
sudo aws s3 cp s3://${aws_s3_bucket.long_user_data_bucket.bucket}/websocket_files/server.js websocket/server.js
sudo aws s3 cp s3://${aws_s3_bucket.long_user_data_bucket.bucket}/websocket_files/yarn.lock websocket/yarn.lock

# 이후 Web/websocket-server 진입해서 작업
cat <<EOF > /home/ec2-user/websocket/.env
REDIS_URL=redis://${aws_elasticache_replication_group.redis.primary_endpoint_address}:6379
BACKEND_API_ENDPOINT=http://nat.1bean.shop
EOF

yarn install
pm2 start server.js --name websocket-server
pm2 save





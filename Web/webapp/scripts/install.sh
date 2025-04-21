#!/bin/bash

echo "[AfterInstall] 의존성 설치 시작"

# Node.js 수동 설치
echo "[AfterInstall] Node.js 18.17.1 설치 중"

sudo wget -nv https://d3rnber7ry90et.cloudfront.net/linux-x86_64/node-v18.17.1.tar.gz
sudo mkdir -p /usr/local/lib/node
sudo tar -xf node-v18.17.1.tar.gz
sudo mv node-v18.17.1 /usr/local/lib/node/nodejs

sudo rm -f node-v18.17.1.tar.gz

export NODEJS_HOME=/usr/local/lib/node/nodejs
export PATH=$NODEJS_HOME/bin:$PATH

cat << 'EOF' | sudo tee /etc/profile.d/node.sh > /dev/null
export NODEJS_HOME=/usr/local/lib/node/nodejs
export PATH=$NODEJS_HOME/bin:$PATH
EOF

sudo chmod +x /etc/profile.d/node.sh


# 임시코드
rm -rf /home/ec2-user/.cache/yarn
yarn cache clean


# pm2, yarn 설치
sudo env "PATH=$PATH" npm install -g pm2
sudo env "PATH=$PATH" npm install -g yarn



# 📌 이제 프로젝트 폴더로 이동
cd /home/ec2-user/app

#ec2-user에게 권한 부여
sudo chown -R ec2-user:ec2-user /home/ec2-user/app

# 의존성 설치
yarn install --frozen-lockfile

# 배포 스크립트 실행 권한 부여
sudo chmod +x scripts/*.sh

echo "[AfterInstall] 완료"


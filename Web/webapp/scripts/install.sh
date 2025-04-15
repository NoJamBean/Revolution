#!/bin/bash

echo "[AfterInstall] 의존성 설치 시작"

# Node.js 18.17.1 직접 설치
if ! command -v node &> /dev/null; then
  echo "[AfterInstall] Node.js 바이너리 직접 설치 중"
  wget -nv https://d3rnber7ry90et.cloudfront.net/linux-x86_64/node-v18.17.1.tar.gz
  mkdir -p /usr/local/lib/node
  tar -xf node-v18.17.1.tar.gz
  mv node-v18.17.1 /usr/local/lib/node/nodejs

  echo "export NODEJS_HOME=/usr/local/lib/node/nodejs" >> /etc/profile.d/node.sh
  echo 'export PATH=$NODEJS_HOME/bin:$PATH' >> /etc/profile.d/node.sh
  chmod +x /etc/profile.d/node.sh
  source /etc/profile.d/node.sh
fi



# pm2, yarn 설치
npm install -g pm2
npm install -g yarn


# 📌 이제 프로젝트 폴더로 이동
cd /home/ec2-user/app

# 의존성 설치
yarn install --frozen-lockfile

# 배포 스크립트 실행 권한 부여
chmod +x scripts/*.sh

echo "[AfterInstall] 완료"


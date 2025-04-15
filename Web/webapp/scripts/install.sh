#!/bin/bash

echo "[AfterInstall] 의존성 설치 시작"

cd /home/ec2-user/app


# node 설치 - 18.17.1v
export NVM_DIR="/home/ec2-user/.nvm"
if [ ! -d "$NVM_DIR" ]; then
  echo "[AfterInstall] nvm 설치 중"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi

# nvm 로딩
export NVM_DIR="/home/ec2-user/.nvm"
source "$NVM_DIR/nvm.sh"

# Node.js 18.17.1 설치 및 사용
nvm install 18.17.1
nvm use 18.17.1
nvm alias default 18.17.1


# pm2 없으면 설치
if ! command -v pm2 &> /dev/null; then
  echo "[AfterInstall] pm2 설치 중"
  sudo npm install -g pm2
fi

yarn install --frozen-lockfile

chmod +x scripts/*.sh

echo "[AfterInstall] 완료"

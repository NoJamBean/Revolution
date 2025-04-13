#!/bin/bash

echo "[AfterInstall] 의존성 설치 시작"

cd /home/ec2-user/app

# pm2 없으면 설치
if ! command -v pm2 &> /dev/null; then
  echo "[AfterInstall] pm2 설치 중"
  sudo npm install -g pm2
fi

yarn install --frozen-lockfile

chmod +x scripts/*.sh

echo "[AfterInstall] 완료"

#!/bin/bash
set -e

echo "[ApplicationStart] PM2로 Next.js 앱 실행 시작"

export NODEJS_HOME=/usr/local/lib/nodejs/node-v18.17.1-linux-x64
export PATH=$NODEJS_HOME/bin:$PATH

cd /home/ubuntu/app

APP_NAME="revolution-app"

# 필수 패키지 설치 (libcap2-bin: setcap 제공)
sudo apt-get update -y
sudo apt-get install -y libcap2-bin

# setcap으로 1024 미만 포트 사용 권한 부여
sudo setcap 'cap_net_bind_service=+ep' $NODEJS_HOME/bin/node

# 이전 실행된 pm2 프로세스 종료 (있으면)
pm2 delete "$APP_NAME" || echo "[ApplicationStart] 기존 pm2 앱 없음"

# 앱 실행 (yarn start → next start, 80포트)
PORT=3000 pm2 start yarn --name "$APP_NAME" -- start

# PM2 상태 저장 (재부팅 시 자동 복구용)
pm2 save

# healthCheck 서버 종료 전 next 서버 on 체크
until curl -s -o /dev/null -w "%{http_code}" http://localhost/ | grep -q "200"; do
  echo "Waiting for Next.js server to become healthy..."
  sleep 3
done

echo "[ApplicationStart] PM2 앱 실행 완료"
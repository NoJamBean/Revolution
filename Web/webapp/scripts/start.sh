#!/bin/bash
set -e

echo "[ApplicationStart] PM2로 Next.js 앱 실행 시작"

export NODEJS_HOME=/usr/local/lib/node/nodejs
export PATH=$NODEJS_HOME/bin:$PATH

cd /home/ec2-user/app

APP_NAME="revolution-app"

# 이전 실행된 pm2 프로세스 종료 (있으면)
pm2 delete "$APP_NAME" || echo "[ApplicationStart] 기존 pm2 앱 없음"




# 앱 실행 (yarn start → next start)
PORT=3000 pm2 start yarn --name "$APP_NAME" -- start

# PM2 상태 저장 (재부팅 시 자동 복구용)
pm2 save


# healthCheck 서버 종료 전 next 서버 on 체크
until curl -s -o /dev/null -w "%{http_code}" http://localhost/ | grep -q "200"; do
  echo "Waiting for Next.js server to become healthy..."
  sleep 3
done
# HealthCheck 용 Python 서버 종료
pkill -f "python3 -m http.server"

echo "[ApplicationStart] PM2 앱 실행 완료"

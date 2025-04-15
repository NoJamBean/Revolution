#!/bin/bash

echo "[ApplicationStart] PM2로 Next.js 앱 실행 시작"

cd /home/ec2-user/app

APP_NAME="revolution-app"

# 이전 실행된 pm2 프로세스 종료 (있으면)
pm2 delete "$APP_NAME" || echo "[ApplicationStart] 기존 pm2 앱 없음"

# HealthCheck 용 Python 서버 종료
pkill -f "python3 -m http.server"

# 앱 실행 (yarn start → next start)
PORT=80 pm2 start yarn --name "$APP_NAME" -- start

# PM2 상태 저장 (재부팅 시 자동 복구용)
pm2 save

echo "[ApplicationStart] PM2 앱 실행 완료"

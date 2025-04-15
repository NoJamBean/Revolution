#!/bin/bash

echo "[ValidateService] 앱 상태 확인 시작"

RETRY=5
SLEEP=3
PORT=3000

for i in $(seq 1 $RETRY); do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$PORT)

  if [ "$STATUS" -eq 200 ]; then
    echo "[ValidateService] 서버 정상 응답 (200 OK)"
    exit 0
  fi

  echo "[ValidateService] 응답 실패 (status: $STATUS) - 재시도 중 ($i/$RETRY)"
  sleep $SLEEP
done

echo "[ValidateService] 서버 응답 실패!! (error)"
exit 1

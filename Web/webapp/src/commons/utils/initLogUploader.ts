//
// Log flush 및 S3 저장 트리거 (5분 간격)
import { flushLogs } from './logger'; // logBuffer 비우는 함수
import { uploadToS3 } from './s3uploader'; // S3 업로더 로직 함수

let hasStarted = false; // ✅ 중복 방지 (dev 환경에서 모듈 리로드 시 보호용)

export function initLogUploader() {
  if (hasStarted) return; // 이미 실행 중이면 무시
  hasStarted = true;

  console.log('[LOGGER] 로그기록 S3 업로더 타이머 시작됨 (5분 간격)');

  setInterval(async () => {
    const flushed = flushLogs();

    if (flushed.Records.length === 0) {
      console.log('[LOGGER] 업로드할 로그 없음 → 스킵');
      return;
    }

    try {
      await uploadToS3(flushed);
    } catch (err) {
      console.error('[LOGGER] S3 업로드 실패:', err);
    }
  }, 5 * 60 * 1000); // 5분 간격으로 트리거
}

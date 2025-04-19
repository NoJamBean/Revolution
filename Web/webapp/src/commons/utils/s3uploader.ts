import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import { v4 as uuidv4 } from 'uuid';

const s3 = new S3Client({ region: 'ap-northeast-2' });

export async function uploadToS3(logObject: object) {
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-'); // 파일명용 타임스탬프
  const key = `WebApp_logs/${timestamp}-${uuidv4()}.json`;

  const command = new PutObjectCommand({
    Bucket: 'logs-c2145228627377c3',
    Key: key,
    Body: JSON.stringify(logObject, null, 2),
    ContentType: 'application/json',
  });

  try {
    await s3.send(command);
    console.log(`[S3 UPLOAD ✅] 저장 완료 → ${key}`);
  } catch (err) {
    console.error('[S3 UPLOAD ❌] 실패:', err);
    throw err;
  }
}

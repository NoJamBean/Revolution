import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import { v4 as uuidv4 } from 'uuid';

const s3 = new S3Client({
  region: 'ap-northeast-2',
  // 필요한 경우 아래 credentials 주석 해제 후 환경변수로 설정
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID!,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY!,
  },
});

export async function uploadToS3(logObject: object) {
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const key = `WebApp_logs/${timestamp}-${uuidv4()}.json`;

  const command = new PutObjectCommand({
    Bucket: 'bet-application-total-logs',
    Key: key,
    Body: JSON.stringify(logObject, null, 2),
    ContentType: 'application/json',
  });

  console.log('\n\n[🚀 S3 업로드 시도]');
  console.log(`[🪣 Bucket] ${command.input.Bucket}`);
  console.log(`[📄 Key] ${command.input.Key}`);
  console.log(
    `[📦 Body preview]\n${command.input.Body?.toString().slice(0, 500)}\n`
  );

  try {
    const result = await s3.send(command);
    console.log(`[✅ S3 업로드 성공] → ${key}`);
    console.dir(result, { depth: null });
  } catch (err: any) {
    console.error('[❌ S3 업로드 실패]');
    console.error('🧾 에러 메시지:', err?.message || err);
    console.error('📛 전체 에러:', err);
    throw err;
  }
}

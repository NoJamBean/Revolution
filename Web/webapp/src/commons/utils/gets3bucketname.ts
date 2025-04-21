import dotenv from 'dotenv';
dotenv.config();

export function getS3BucketFromEnv(): string {
  const bucketName = process.env.S3_BUCKET_NAME;

  if (!bucketName) {
    throw new Error('❌ .env에 S3_BUCKET_NAME이 없습니다.');
  }

  return bucketName;
}

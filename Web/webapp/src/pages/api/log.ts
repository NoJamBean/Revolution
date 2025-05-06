import type { NextApiRequest, NextApiResponse } from 'next';
import { addLog } from '../../commons/utils/logger';
import { initLogUploader } from '@/src/commons/utils/initLogUploader';

// ✅ 서버 시작 시 로그 업로더 타이머 시작
let uploaderStarted = false;
if (!uploaderStarted) {
  uploaderStarted = true;
  initLogUploader();
}

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  try {
    const rawLog = req.body;

    const sourceIPAddress = Array.isArray(req.headers['x-forwarded-for'])
      ? req.headers['x-forwarded-for'][0]
      : typeof req.headers['x-forwarded-for'] === 'string'
      ? req.headers['x-forwarded-for']
      : typeof req.socket.remoteAddress === 'string'
      ? req.socket.remoteAddress
      : '';

    const userAgent = req.headers['user-agent'] || '';

    const completeLog = {
      ...rawLog,
      sourceIPAddress,
      userAgent,
    };

    addLog(completeLog);

    res.status(200).json({ status: 'ok' });
  } catch (err) {
    console.error('[❌ /api/log 에러 발생]', err);
    res.status(500).json({ error: '로그 처리 실패' });
  }
}

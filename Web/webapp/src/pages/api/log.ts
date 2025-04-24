import type { NextApiRequest, NextApiResponse } from 'next';
import { addLog } from '../../commons/utils/logger';
import { initLogUploader } from '@/src/commons/utils/initLogUploader';
import { random } from '@/src/commons/utils/temporaryIp';

// ✅ 서버 실행 시 1번만 타이머 시작하도록 제어
let uploaderStarted = false;
if (!uploaderStarted) {
  uploaderStarted = true;
  initLogUploader();
}

export default function handler(req: NextApiRequest, res: NextApiResponse) {
  const rawLog = req.body;

  const sourceIPAddress = Array.isArray(req.headers['x-forwarded-for'])
    ? req.headers['x-forwarded-for'][0]
    : typeof req.headers['x-forwarded-for'] === 'string'
    ? req.headers['x-forwarded-for']
    : typeof req.socket.remoteAddress === 'string'
    ? req.socket.remoteAddress
    : '';

  const userAgent = req.headers['user-agent'] || '';

  //random ip 할당함수 (임시용)
  const getRandomIp = (arr) => {
    const randomIdx = Math.floor(Math.random() * arr.length);

    return arr[randomIdx];
  };

  const completeLog = {
    ...rawLog,
    sourceIPAddress: getRandomIp(random),
    userAgent,
  };

  addLog(completeLog);
  res.status(200).json({ status: 'ok' });
}

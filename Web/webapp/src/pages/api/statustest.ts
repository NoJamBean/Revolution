// GET /api/log/status
import type { NextApiRequest, NextApiResponse } from 'next';
import { logBuffer } from '../../commons/utils/logger';

export default function handler(req: NextApiRequest, res: NextApiResponse) {
  res.status(200).json({
    message: '현재 메모리에 쌓인 로그',
    count: logBuffer.Records.length,
    Records: logBuffer.Records,
  });
}

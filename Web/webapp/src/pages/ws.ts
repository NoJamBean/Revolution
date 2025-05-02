// pages/ws.ts
import { createProxyServer } from 'http-proxy';
import type { NextApiRequest, NextApiResponse } from 'next';

export const config = {
  api: { bodyParser: false, externalResolver: true },
};

const proxy = createProxyServer({
  target: 'http://alb.backend.internal/ws',
  changeOrigin: true,
  ws: true,
});

export default function handler(req: NextApiRequest, res: NextApiResponse) {
  proxy.web(req, res, {
    target: 'http://alb.backend.internal/ws',
    headers: {
      Host: 'alb.backend.internal',
      'X-Real-IP': req.socket.remoteAddress || '',
      'X-Forwarded-For': req.socket.remoteAddress || '',
      'X-Forwarded-Proto': Array.isArray(req.headers['x-forwarded-proto'])
        ? req.headers['x-forwarded-proto'][0]
        : req.headers['x-forwarded-proto'] || 'http',
    },
  });
}

// WebSocket 업그레이드 핸들링
if (typeof (proxy as any).on === 'function') {
  (proxy as any).on('upgrade', (req: any, socket: any, head: any) => {
    proxy.ws(req, socket, head);
  });
}

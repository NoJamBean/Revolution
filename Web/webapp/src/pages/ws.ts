import { createProxyServer } from 'http-proxy';
import type { NextApiRequest, NextApiResponse } from 'next';

export const config = {
  api: { bodyParser: false, externalResolver: true },
};

const proxy = createProxyServer({
  target: 'http://alb.backend.internal/ws',
  changeOrigin: true,
  ws: true,  // WebSocket 지원을 활성화
});

export default function handler(req: NextApiRequest, res: NextApiResponse) {
  // WebSocket 업그레이드 핸들링
  if (req.headers['upgrade'] === 'websocket') {
    // WebSocket 요청인 경우, proxy.ws()로 처리
    proxy.ws(req, res, {
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
  } else {
    // WebSocket이 아닌 일반 HTTP 요청 처리
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
}

// WebSocket 업그레이드 이벤트 핸들링
proxy.on('upgrade', (req, socket, head) => {
  // WebSocket 업그레이드 요청을 proxy.ws()로 전달
  proxy.ws(req, socket, head);
});
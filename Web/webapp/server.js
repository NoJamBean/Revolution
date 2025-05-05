// server.js
import next from 'next';
import express from 'express';
import { createProxyServer } from 'http-proxy';

const dev = process.env.NODE_ENV !== 'production';
const app = next({ dev });
const handle = app.getRequestHandler();
const proxy = createProxyServer({
  changeOrigin: true,
  ws: true,
});

await app.prepare();
const server = express();

// 1) WebSocket 업그레이드 (upgrade 이벤트)
server.on('upgrade', (req, socket, head) => {
  if (req.url.startsWith('/ws')) {
    proxy.ws(req, socket, head, {
      target: 'http://alb.backend.internal/ws',
    });
  }
});

// 2) /api/log 은 Next.js API
server.all('/api/log', (req, res) => {
  return handle(req, res);
});

// 3) 그 외 모든 /api/* 요청은 ALB 백엔드로 프록시
server.all('/api/:path*', (req, res) => {
  proxy.web(req, res, {
    target: 'http://alb.backend.internal',   // path 포함 자동 매핑됨
  });
});

// 4) HTTP 폴링 등 /ws* 요청도 ALB
server.all('/ws*', (req, res) => {
  proxy.web(req, res, {
    target: 'http://alb.backend.internal/ws',
  });
});

// 5) 그 외 Next.js 페이지·API 정적·SSR
server.all('*', (req, res) => {
  return handle(req, res);
});

server.listen(3000, () => {
  console.log('> Custom server ready on http://localhost:3000');
});
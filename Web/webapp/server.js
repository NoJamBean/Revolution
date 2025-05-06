// server.js
import next from 'next';
import express from 'express';
import http from 'http';
import { createProxyServer } from 'http-proxy';

const dev = process.env.NODE_ENV !== 'production';
const nextApp = next({ dev });
await nextApp.prepare();

const handle = nextApp.getRequestHandler();
const app = express();
const proxy = createProxyServer({ changeOrigin: true, ws: true });

// 1) Next.js API: /api/log
app.all('/api/log', (req, res) => handle(req, res));

// 2) 그 외 /api/* → ALB API 백엔드
app.all('/api/:path*', (req, res) => {
  proxy.web(req, res, { target: 'http://alb.backend.internal' });
});

// 3) HTTP 폴링 등 /ws* → ALB WS 백엔드
app.all('/ws*', (req, res) => {
  proxy.web(req, res, { target: 'http://alb.backend.internal/ws' });
});

// 4) 나머지 Next.js 페이지·정적·SSR
app.all('*', (req, res) => handle(req, res));

// 5) Express 앱을 HTTP 서버로 감싸기
const server = http.createServer(app);

// 6) HTTP 서버에 upgrade 리스너 등록
server.on('upgrade', (req, socket, head) => {
  if (req.url.startsWith('/ws')) {
    proxy.ws(req, socket, head, {
      target: 'http://alb.backend.internal/ws',
    });
  }
});

// 7) 포트 열기
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
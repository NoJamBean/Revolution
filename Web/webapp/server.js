// server.js
const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const { createProxyServer } = require('http-proxy');
const next = require('next');
const http = require('http');

const dev = process.env.NODE_ENV !== 'production';
const app = next({ dev });
const handle = app.getRequestHandler();

const expressApp = express();

// ✅ 1. API 프록시: /api → AWS internal ALB
expressApp.use(
  '/api',
  createProxyMiddleware({
    target: 'http://alb.backend.internal',
    changeOrigin: true,
    pathRewrite: { '^/api': '/api' },
    onProxyReq: (proxyReq, req, res) => {
      proxyReq.setHeader('Host', 'alb.backend.internal');
      proxyReq.setHeader('X-Real-IP', req.socket.remoteAddress || '');
      proxyReq.setHeader('X-Forwarded-For', req.socket.remoteAddress || '');
      proxyReq.setHeader(
        'X-Forwarded-Proto',
        req.headers['x-forwarded-proto'] || 'http'
      );
    },
  })
);

// ✅ 2. WebSocket 프록시: /ws → AWS internal WebSocket 서버
const wsProxy = createProxyServer({
  target: 'http://alb.backend.internal/ws',
  changeOrigin: true,
  ws: true,
  headers: {
    Host: 'alb.backend.internal',
  },
});

// ✅ 3. 나머지 Next.js 요청 처리
expressApp.all('*', (req, res) => handle(req, res));

// ✅ 4. 서버 + WS 핸들링
const server = http.createServer(expressApp);

server.on('upgrade', (req, socket, head) => {
  if (req.url.startsWith('/ws')) {
    wsProxy.ws(req, socket, head);
  }
});

server.listen(3000, () => {
  console.log('🚀 서버 실행됨: http://localhost:3000');
});

import next from 'next';
import express from 'express';
import http from 'http';
import httpProxy from 'http-proxy';
import bodyParser from 'body-parser';

const dev = process.env.NODE_ENV !== 'production';
const PORT = process.env.PORT || 3000;

const nextApp = next({ dev });
const handle = nextApp.getRequestHandler();

const proxy = httpProxy.createProxyServer({
  changeOrigin: true,
  ws: true,
});

nextApp.prepare().then(() => {
  const app = express();

  // ✅ /api 경로에서 log만 Next.js 처리 (body-parser 적용)
  app.use('/api/log', bodyParser.json(), bodyParser.urlencoded({ extended: true }));
  app.all('/api/log', (req, res) => {
    return handle(req, res);
  });

  // ✅ 그 외 /api는 프록시 (body-parser 없이)
  app.use('/api', (req, res) => {
    proxy.web(req, res, {
      target: 'http://alb.backend.internal/api',
    }, (err) => {
      console.error('API proxy error:', err.message);
      res.status(502).send('Bad Gateway');
    });
  });

  // ✅ WebSocket 프록시
  app.use('/ws', (req, res) => {
    proxy.web(req, res, {
      target: 'http://alb.backend.internal/ws',
    }, (err) => {
      console.error('WS proxy error:', err.message);
      res.status(502).send('Bad Gateway');
    });
  });

  // ✅ Next.js 라우트 처리
  const server = http.createServer((req, res) => {
    app(req, res, () => {
      handle(req, res);
    });
  });

  // ✅ WebSocket Upgrade 처리
  server.on('upgrade', (req, socket, head) => {
    if (req.url.startsWith('/ws')) {
      proxy.ws(req, socket, head, {
        target: 'http://alb.backend.internal/ws',
      });
    }
  });

  server.listen(PORT, () => {
    console.log(`🚀 Server running on http://localhost:${PORT}`);
  });
});


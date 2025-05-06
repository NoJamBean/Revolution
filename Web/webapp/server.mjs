import next from 'next';
import express from 'express';
import http from 'http';
import httpProxy from 'http-proxy';

const dev = process.env.NODE_ENV !== 'production';
const PORT = process.env.PORT || 3000;

const nextApp = next({ dev });
const handle = nextApp.getRequestHandler();

const proxy = httpProxy.createProxyServer({
  changeOrigin: true,
  ws: true
});

proxy.on('proxyReq', (proxyReq, req, res, options) => {
  console.log(`[proxyReq] ${proxyReq.method} ${options.target}${req.url}`);
});

nextApp.prepare().then(() => {
  const app = express();

  app.use('/api', (req, res, next) => {
    // log만 제외하고 나머지는 프록시 처리
    if (req.url.startsWith('/log')) return next();
    proxy.web(req, res, { target: 'http://alb.backend.internal/api' }, (err) => {
      console.error('API proxy error:', err.message);
      res.status(502).send('Bad Gateway');
    });
  });

  app.use('/ws', (req, res) => {
    proxy.web(req, res, {
      target: 'http://alb.backend.internal/ws',
      ignorePath: false,
      prependPath: false,
    }, (err) => {
      console.error('WS proxy error:', err.message);
      res.status(502).send('Bad Gateway');
    });
  });

  // 나머지 요청은 Next.js가 처리
  const server = http.createServer((req, res) => {
    if (req.url?.startsWith('/api/log')) {
      // ✅ API route 직접 처리
      return handle(req, res);
    } else {
      app(req, res); // Express로 넘김
    }
  });

  server.on('upgrade', (req, socket, head) => {
    if (req.url.startsWith('/ws')) {
      proxy.ws(req, socket, head, {
        target: 'http://alb.backend.internal/ws',
        ignorePath: false,
        prependPath: false,
      });
    }
  });

  server.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
});

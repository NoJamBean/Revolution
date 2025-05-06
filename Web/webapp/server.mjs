import next from 'next';
import express from 'express';
import http from 'http';
import httpProxy from 'http-proxy';
const { createProxyServer } = httpProxy;

const dev = process.env.NODE_ENV !== 'production';
const PORT = process.env.PORT || 3000;

async function main() {
  const nextApp = next({ dev });
  await nextApp.prepare();

  const handle = nextApp.getRequestHandler();
  const app = express();
  const proxy = createProxyServer({ changeOrigin: true, ws: true });

  // API 라우팅
  app.all('/api/log', (req, res) => handle(req, res));

  app.use('/api', (req, res) => {
    proxy.web(req, res, {
      target: 'http://alb.backend.internal',
      prependPath: false,
    }, (err) => {
      console.error('API proxy error:', err.message);
      res.status(502).send('Bad Gateway');
    });
  });

  app.use('/ws', (req, res) => {
    proxy.web(req, res, {
      target: 'http://alb.backend.internal',
      prependPath: false,
    }, (err) => {
      console.error('WS proxy error:', err.message);
      res.status(502).send('Bad Gateway');
    });
  });

  app.use((req, res) => handle(req, res));

  const server = http.createServer(app);

  server.on('upgrade', (req, socket, head) => {
    if (req.url.startsWith('/ws')) {
      proxy.ws(req, socket, head, {
        target: 'http://alb.backend.internal',
      });
    }
  });

  server.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}

main().catch((err) => {
  console.error('Startup failed:', err);
  process.exit(1);
});
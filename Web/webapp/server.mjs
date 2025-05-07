nextApp.prepare().then(() => {
  const app = express();

  app.use('/api', (req, res, next) => {
    if (req.url.startsWith('/log')) return next(); 

    proxy.web(req, res, { target: 'http://alb.backend.internal/api' }, (err) => {
      console.error('API proxy error:', err.message);
      res.status(502).send('Bad Gateway');
    });
  });

  app.use('/ws', (req, res) => {
    proxy.web(req, res, {
      target: 'http://alb.backend.internal/ws',
    }, (err) => {
      console.error('WS proxy error:', err.message);
      res.status(502).send('Bad Gateway');
    });
  });

  app.use(bodyParser.json());
  app.use(bodyParser.urlencoded({ extended: true }));

  const server = http.createServer((req, res) => {
    if (req.url?.startsWith('/api/log')) {
      return handle(req, res); 
    } else {
      app(req, res, () => {
        handle(req, res);
      });
    }
  });

  // WebSocket 업그레이드 처리
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

import next from 'next';
import express from 'express';
import http from 'http';
import httpProxy from 'http-proxy';
import bodyParser from 'body-parser';
import { uploadToS3 } from './utils/s3uploader.js'; // S3 업로더 경로 확인

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

  app.use((req, res, next) => {
    res.on('finish', () => {
      const candidateIP = Array.isArray(req.headers['x-forwarded-for'])
      ? req.headers['x-forwarded-for'][0]
      : typeof req.headers['x-forwarded-for'] === 'string'
      ? req.headers['x-forwarded-for']
      : typeof req.socket.remoteAddress === 'string'
      ? req.socket.remoteAddress
      : '';

      const sourceIPAddress = candidateIP
      .split(',')[0]
      .replace(/:\d+$/, '');

      const log = {
        eventSource: 'webapp.example.com',
        awsRegion: 'ap-northeast-2',
        eventTime: new Date().toISOString(),
        eventName: 'HttpAccess',
        requestParameters: {
          httpMethod: req.method,
          requestPath: req.originalUrl,
          statusCode: res.statusCode,
        },
        sourceIPAddress: sourceIPAddress,
        userAgent: req.headers['user-agent'] || '',
      };
  
      uploadToS3(log).catch((err) =>
        console.error('[❌ S3 로그 업로드 실패]', err.message)
      );
    });
  
    next();
  });

  app.use('/api', (req, res) => {
    proxy.web(req, res, {
      target: 'http://alb.backend.internal/api',
      headers: {
        ...req.headers,
      },
    }, (err) => {
      console.error('API proxy error:', err.message);
      res.status(502).send('Bad Gateway');
    });
  });

  app.use('/ws', (req, res) => {
    proxy.web(req, res, {
      target: 'http://alb.backend.internal/ws',
      headers: {
        ...req.headers,
      },
    }, (err) => {
      console.error('WS proxy error:', err.message);
      res.status(502).send('Bad Gateway');
    });
  });

  const server = http.createServer((req, res) => {
    if (req.url?.startsWith('/api/log')) {
      bodyParser.json()(req, res, () => {
        bodyParser.urlencoded({ extended: true })(req, res, () => {
          handle(req, res);
        });
      });
    } else {
      app(req, res, () => {
        handle(req, res);
      });
    }
  });

  server.on('upgrade', (req, socket, head) => {
    if (req.url.startsWith('/ws')) {
      proxy.ws(req, socket, head, {
        target: 'http://alb.backend.internal/ws',
        headers: {
          ...req.headers,
        },
      });
    }
  });

  server.listen(PORT, () => {
    console.log(`🚀 Server running on http://localhost:${PORT}`);
  });
});

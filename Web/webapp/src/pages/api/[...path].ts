// pages/api/[...path].ts
import { createProxyMiddleware } from 'http-proxy-middleware';
import type { NextApiRequest, NextApiResponse } from 'next';

export const config = {
  api: { bodyParser: false },
};

const proxy = createProxyMiddleware({
  target: 'http://alb.backend.internal',
  changeOrigin: true,
  pathRewrite: {
    '^/api': '/api',
  },
  onProxyReq(proxyReq: any, req: any, res: any) {
    proxyReq.setHeader('Host', 'alb.backend.internal');
    proxyReq.setHeader('X-Real-IP', req.socket.remoteAddress || '');
    proxyReq.setHeader('X-Forwarded-For', req.socket.remoteAddress || '');
    proxyReq.setHeader(
      'X-Forwarded-Proto',
      req.headers['x-forwarded-proto'] || 'http'
    );
  },
} as any);

export default function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.url?.startsWith('/api/log')) {
    res.status(404).end(); // log.ts가 처리
    return;
  }

  return new Promise((resolve, reject) => {
    proxy(req as any, res as any, (err) => {
      if (err) reject(err);
      else resolve(true);
    });
  });
}

/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: false,
  compiler: {
    emotion: true,
  },

  async rewrites() {
    return [
      {
        source: '/ws',        // 클라이언트에서 /ws 로 요청하면
        destination: '/api/ws' // 내부적으로 /api/ws 로 포워딩
      }
    ];
  },
};

export default nextConfig;

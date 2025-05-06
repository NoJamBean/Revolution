/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: false,
  compiler: {
    emotion: true,
  },

  // async rewrites() {
  //   return [
  //     {
  //       source: '/ws/:path*',
  //       destination: '/api/ws/:path*',
  //     },
  //   ];
  // },
};

export default nextConfig;

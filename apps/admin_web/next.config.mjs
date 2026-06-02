/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  output: 'export',
  basePath: '/foodily',
  assetPrefix: '/foodily/',
  trailingSlash: true,
  images: {
    unoptimized: true,
  },
};

export default nextConfig;

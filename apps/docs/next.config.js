import { setupDevPlatform } from '@cloudflare/next-on-pages/next-dev';

/** @type {import('next').NextConfig} */
const nextConfig = {};

console.log('process.env.NODE_ENV:', process.env.NODE_ENV)
console.log('process.env.NODE_VERSION:', process.env.NODE_VERSION)

// Here we use the @cloudflare/next-on-pages next-dev module to allow us to use bindings during local development
// (when running the application with `next dev`), for more information see:
// https://github.com/cloudflare/next-on-pages/blob/main/internal-packages/next-dev/README.md
if (process.env.NODE_ENV === 'development') {
    await setupDevPlatform();
}

export default nextConfig;

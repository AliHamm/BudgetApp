import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  async redirects() {
    return [
      { source: "/tour", destination: "/", permanent: false },
      { source: "/tour/:path*", destination: "/", permanent: false },
    ];
  },
};

export default nextConfig;

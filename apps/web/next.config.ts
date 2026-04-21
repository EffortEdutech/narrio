import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  transpilePackages: ["@narrio/api", "@narrio/db", "@narrio/ui"]
};

export default nextConfig;

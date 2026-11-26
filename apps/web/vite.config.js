import { defineConfig, loadEnv } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig(({ mode }) => {
  const { CORE_DEV_ORIGIN } = loadEnv(mode, process.cwd(), "CORE_DEV_ORIGIN");
  const target = CORE_DEV_ORIGIN || "http://localhost:3000";
  return {
    plugins: [react()],
    server: {
      port: 5173,
      strictPort: true,
      proxy: {
        "/api/v1": { target, changeOrigin: true },
        "/share": { target, changeOrigin: true },
      },
    },
  };
});

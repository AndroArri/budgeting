import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";
import path from "path";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      "@assets": path.resolve(__dirname, "./src/assets"),
      "@components": path.resolve(__dirname, "/src/components"),
      "@services": path.resolve(__dirname, "/src/services"),
      "@types": path.resolve(__dirname, "/src/types"),
      "@": path.resolve(__dirname, "/src"),
      "@views": path.resolve(__dirname, "/src/views"),
    },
  },
});

import { resolve, basename } from "path";
import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";
import vuetify from "vite-plugin-vuetify";
import {
  isJavascriptFile,
  isCssFile,
  isImageFile,
  isFontFile,
} from "./dev/changeFileNameVitePlugin.mjs";
// import { restartRedmineAfterBuild } from "./dev/restartRedmineAfterBuild.mjs";
// import { copyRubyFilesAfterBuild } from "./dev/copyRubyFilesAfterBuild.mjs";
import UnheadVite from "@unhead/addons/vite";
import { nodePolyfills } from "vite-plugin-node-polyfills";

import type { UserConfig } from "vite";

const BASE_DIR = resolve(__dirname, "..");
const SRC_BASE_DIR = resolve(BASE_DIR, "src");

export default defineConfig(async ({ mode }) => {
  return {
    appType: "spa",
    base: "/plugin_assets/friday/",
    plugins: [
      nodePolyfills({
        include: ["crypto", "stream", "vm"],
      }),
      vue({
        isProduction: mode === "production",
        features: {
          prodDevtools: mode !== "production",
        },
      }),
      vuetify({
        styles: {
          configFile: "./assets/stylesheets/vuetify.scss",
        },
      }),
      // copyRubyFilesAfterBuild(),
      // restartRedmineAfterBuild(),
      UnheadVite(),
    ],
    define: {
      "process.env": {},
    },
    root: resolve(__dirname, "src"),
    resolve: {
      alias: {
        "@": resolve(__dirname, "src"),
      },
    },
    publicDir: resolve(__dirname, "src", "public"),
    build: {
      manifest: true,
      outDir: resolve(__dirname, "plugins", "friday"),
      chunkSizeWarningLimit: 1024 * 10,
      emptyOutDir: true,
      sourcemap: false,
      minify: mode === "production",
      rollupOptions: {
        input: {
          "javascripts/friday": resolve(
            __dirname,
            "src",
            "assets",
            "javascripts",
            "friday.ts",
          ),
        },
        output: {
          entryFileNames: "assets/[name].js",
          chunkFileNames: "assets/javascripts/[name]-[hash].js",
          assetFileNames(chunkInfo) {
            let base = `assets/`;
            const name =
              chunkInfo.name || chunkInfo.originalFileName || "unknown";
            if (isJavascriptFile(name)) {
              base += `javascripts`;
            } else if (isCssFile(name)) {
              base += `stylesheets`;
            } else if (isImageFile(name)) {
              base += `images`;
            } else if (isFontFile(name)) {
              base += `fonts`;
            } else {
              base += `other`;
            }
            if (
              chunkInfo.type === "asset" &&
              "string" === typeof chunkInfo.name &&
              chunkInfo.name.includes("friday")
            ) {
              return `${base}/[name][extname]`;
            } else {
              return `${base}/[name]-[hash][extname]`;
            }
          },
        },
      },
    },
    experimental: {
      renderBuiltUrl(filename) {
        const filePath = resolve(SRC_BASE_DIR, filename);
        const fileBaseName = basename(filePath);
        let base = `/plugin_assets/friday/`;
        if (isJavascriptFile(fileBaseName)) {
          base += `javascripts`;
        } else if (isCssFile(fileBaseName)) {
          base += `stylesheets`;
        } else if (isImageFile(fileBaseName)) {
          base += `images`;
        } else if (isFontFile(fileBaseName)) {
          base += `fonts`;
        } else {
          base += `other`;
        }
        base += `/${fileBaseName}`;
        return base;
      },
    },
    ssr: {
      noExternal: ["@jakguru/vueprint"],
    },
    optimizeDeps: {
      exclude: ["fsevents", "@nuxt/kit"],
    },
    server: {
      host: "0.0.0.0",
      port: 8111,
      strictPort: true,
      origin: "http://127.0.0.1:8111",
    },
    css: {
      preprocessorOptions: {
        scss: {
          api: "modern-compiler",
        },
      },
    },
  } as UserConfig;
});

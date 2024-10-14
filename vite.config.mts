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
import { restartRedmineAfterBuild } from "./dev/restartRedmineAfterBuild.mjs";
import { copyRubyFilesAfterBuild } from "./dev/copyRubyFilesAfterBuild.mjs";
import UnheadVite from "@unhead/addons/vite";
import { nodePolyfills } from "vite-plugin-node-polyfills";

import type { UserConfig } from "vite";

const BASE_DIR = resolve(__dirname, "..");
const SRC_BASE_DIR = resolve(BASE_DIR, "src");

export default defineConfig(async ({ mode }) => {
  return {
    appType: "spa",
    base: "/plugin_assets/greenmine/",
    plugins: [
      nodePolyfills({
        include: ["crypto", "stream", "vm"],
      }),
      vue(),
      vuetify({
        styles: {
          configFile: "./assets/stylesheets/vuetify.scss",
        },
      }),
      copyRubyFilesAfterBuild(),
      restartRedmineAfterBuild(),
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
    build: {
      outDir: resolve(__dirname, "plugins", "greenmine"),
      chunkSizeWarningLimit: 1024 * 10,
      emptyOutDir: true,
      sourcemap: false,
      minify: mode === "production",
      rollupOptions: {
        input: {
          "javascripts/greenmine": resolve(
            __dirname,
            "src",
            "assets",
            "javascripts",
            "greenmine.ts",
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
              chunkInfo.name.includes("greenmine")
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
        let base = `/plugin_assets/greenmine/`;
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
  } as UserConfig;
});

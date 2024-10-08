import { resolve, basename, dirname } from "path";
import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";
import { readdir } from "fs/promises";
import { statSync } from "fs";
import {
  isJavascriptFile,
  isCssFile,
  isImageFile,
  isFontFile,
} from "./dev/changeFileNameVitePlugin.mjs";
import { viteStaticCopy } from "vite-plugin-static-copy";
import { watchExtraFiles } from "./dev/watchExtraFiles.mjs";
import { restartRedmineAfterBuild } from "./dev/restartRedmineAfterBuild.mjs";

import type { UserConfig } from "vite";

const BASE_DIR = resolve(__dirname, "..");
const SRC_BASE_DIR = resolve(BASE_DIR, "src");

interface StaticCopyTarget {
  src: string;
  dest: string;
}

const getStaticCopyTargets = async (): Promise<StaticCopyTarget[]> => {
  const files = new Set<string>();
  const readFiles = async (dir: string) => {
    const entries = await readdir(dir)
      .then((entries) => entries.map((entry) => resolve(dir, entry)))
      .catch(() => []);
    for (const entry of entries) {
      const stat = statSync(entry);
      if (stat.isDirectory()) {
        await readFiles(entry);
      } else {
        files.add(entry);
      }
    }
  };
  await readFiles(resolve(__dirname, "src-ruby"));
  return Array.from(files).map((file) => {
    return {
      src: file,
      dest: dirname(file).replace(resolve(__dirname, "src-ruby"), "."),
    };
  });
};

export default defineConfig(async () => {
  return {
    appType: "spa",
    base: "/plugin_assets/greenmine/",
    plugins: [
      vue(),
      viteStaticCopy({
        targets: await getStaticCopyTargets(),
      }),
      watchExtraFiles([resolve(__dirname, "src-ruby")]),
      restartRedmineAfterBuild(),
    ],
    define: {
      "process.env": {},
    },
    root: resolve(__dirname, "src"),
    resolve: {
      alias: {
        "@": resolve(__dirname, "src"),
        "vue-i18n": resolve(
          __dirname,
          "node_modules",
          "vue-i18n",
          "dist",
          "vue-i18n.esm-bundler.js",
        ),
      },
    },
    build: {
      outDir: resolve(__dirname, "plugins", "greenmine"),
      chunkSizeWarningLimit: 1024 * 10,
      emptyOutDir: true,
      sourcemap: true,
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
  } as UserConfig;
});

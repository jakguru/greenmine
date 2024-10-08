import { resolve, basename } from "path";
import type { Plugin } from "vite";

const BASE_DIR = resolve(__dirname, "..");
const SRC_BASE_DIR = resolve(BASE_DIR, "src");

export const isJavascriptFile = (name: string) =>
  /\.js(\.map)?(\?.*)?$/gm.test(name);
export const isCssFile = (name: string) => /\.css(\.map)?(\?.*)?$/gm.test(name);
export const isImageFile = (name: string) =>
  /\.(png|jpe?g|gif|svg)(\?.*)?$/gm.test(name);
export const isFontFile = (name: string) =>
  /\.(woff2?|eot|ttf|otf)(\?.*)?$/gm.test(name);

export const changeFileNameVitePlugin = (): Plugin => {
  return {
    name: "change-file-name",
    enforce: "post",
    generateBundle(_options, bundle) {
      const htmlFiles = new Set<string>();
      const updates = new Map<string, string>();
      for (const entryKey in bundle) {
        const { fileName } = bundle[entryKey];
        if (fileName && fileName.endsWith(".html")) {
          bundle[entryKey].fileName = fileName + ".erb";
          htmlFiles.add(entryKey);
        } else {
          // these are assets and need to be sorted into their specific folders
          const filePath = resolve(SRC_BASE_DIR, entryKey);
          const fileBaseName = basename(filePath);
          if (isJavascriptFile(fileBaseName)) {
            bundle[entryKey].fileName = `assets/javascripts/${fileBaseName}`;
          } else if (isCssFile(fileBaseName)) {
            bundle[entryKey].fileName = `assets/stylesheets/${fileBaseName}`;
          } else if (isImageFile(fileBaseName)) {
            bundle[entryKey].fileName = `assets/images/${fileBaseName}`;
          } else if (isFontFile(fileBaseName)) {
            bundle[entryKey].fileName = `assets/fonts/${fileBaseName}`;
          } else {
            bundle[entryKey].fileName = `assets/other/${fileBaseName}`;
          }
          updates.set(fileName, bundle[entryKey].fileName);
        }
      }
      htmlFiles.forEach((htmlFile) => {
        updates.forEach((newFileName, oldFileName) => {
          // @ts-expect-error the types are wrong here
          bundle[htmlFile].source = bundle[htmlFile].source.replace(
            new RegExp(oldFileName, "g"),
            newFileName.replace("assets/", ""),
          );
        });
      });
    },
  };
};

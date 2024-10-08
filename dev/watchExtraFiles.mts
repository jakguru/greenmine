import { resolve } from "path";
import type { Plugin } from "vite";

const BASE_DIR = resolve(__dirname, "..");

export const watchExtraFiles = (paths: Array<string>): Plugin => {
  return {
    name: "watch-extra-files",
    buildStart() {
      paths.forEach((path) => {
        if (!path.startsWith("/")) {
          path = resolve(BASE_DIR, path);
        }
        // const stat = statSync(path);
        // if (stat.isDirectory()) {
        //   this.addWatchFile(`${path}/**`);
        // } else {
        //   this.addWatchFile(path);
        // }
        this.addWatchFile(path);
      });
    },
  };
};

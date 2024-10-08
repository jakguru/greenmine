import { execa } from "execa";
import { resolve } from "path";
import type { Plugin } from "vite";

const cwd = resolve(__dirname, "..");

export const restartRedmineAfterBuild = (): Plugin => {
  return {
    name: "restart-redmine-after-build",
    writeBundle() {
      if (true === this.meta.watchMode) {
        console.log("Restarting Redmine...");
        execa("docker", ["compose", "restart", "redmine"], {
          cwd,
          stdio: "inherit",
          reject: false,
        });
      }
    },
  };
};

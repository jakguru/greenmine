import { execa } from "execa";
import { resolve } from "path";
import { copyFileSync } from "fs";

import type { Subprocess } from "execa";

const cwd = resolve(__dirname, "..");
const nodemon = require("nodemon");
const color = require("cli-color");
const { env } = process;

const srcRubyDir = resolve(cwd, "src-ruby");
const destRubyDir = resolve(cwd, "plugins", "greenmine");

const nodemonConfig = {
  watch: ["dev/**/*", "src-ruby/**/*", "package.json", "vite.config.mts"],
  ext: "ts,mts,json,env,scss,vue,md,yml,rb,erb",
  ignore: ["node_modules"],
  exec: "npx jiti bin/noop.ts",
  delay: "2500",
};

let subprocess: Subprocess | undefined;
let abortController: AbortController | undefined;

const cleanup = async () => {
  if (subprocess) {
    await subprocess.kill();
  }
  if (abortController) {
    abortController.abort();
  }
};

process
  .on("unhandledRejection", (reason, p) => {
    console.error(reason, "Unhandled Rejection at Promise", p);
  })
  .on("uncaughtException", (err) => {
    console.error(err.stack);
    cleanup().finally(() => process.exit(1));
  })
  .on("SIGINT", () => {
    cleanup().finally(() => process.exit(255));
  })
  .on("SIGTERM", () => {
    cleanup().finally(() => process.exit(255));
  });

const doStart = async (force: boolean = false) => {
  if (subprocess && !force) {
    return;
  }
  if (abortController) {
    if (abortController.signal.aborted) {
      return;
    }
    abortController.abort();
  }
  abortController = new AbortController();
  if (!abortController.signal.aborted) {
    await new Promise((resolve) => setTimeout(resolve, 500));
  }
  if (!abortController.signal.aborted) {
    subprocess = execa(
      "npx",
      ["vite", "build", "--mode", "development", "--watch"],
      {
        cwd,
        stdio: "inherit",
        reject: false,
        cancelSignal: abortController.signal,
        env: {
          ...(env as Record<string, string>),
          NODE_TLS_REJECT_UNAUTHORIZED: "1",
        },
      },
    );
    subprocess.on("exit", (code) => {
      if (code === 0) {
        console.log(color.green("Server process exited successfully"));
      } else if (null !== code) {
        console.log(
          color.red(`Server process exited with an error code: ${code}`),
        );
      } else {
        console.log(color.red("Server process was killed"));
      }
    });
  }
};

const doRestart = async (needsSubProcessRestart: boolean) => {
  if (needsSubProcessRestart) {
    if (subprocess) {
      await subprocess.kill();
    }
    subprocess = undefined;
    await doStart(true);
  }
  if (!abortController || !abortController.signal.aborted) {
    await execa("docker", ["compose", "restart", "redmine"], {
      cwd,
      cancelSignal: abortController ? abortController.signal : undefined,
      stdio: "inherit",
      reject: false,
      env,
    });
  }
};

nodemon(nodemonConfig);
let timeout: NodeJS.Timeout | undefined;
nodemon
  .on("start", function () {
    console.log(color.green("Dev Process has started"));
    doStart();
  })
  .on("quit", function () {
    console.log(color.red("Dev Process has quit"));
    process.exit();
  })
  .on("restart", function (files: string[]) {
    console.log("App restarted due to: ", files);
    let needsSubProcessRestart = false;
    for (const file of files) {
      if (file.startsWith(srcRubyDir)) {
        const destFile = file.replace(srcRubyDir, destRubyDir);
        console.log(`Copying ${file} to ${destFile}`);
        try {
          copyFileSync(file, destFile);
        } catch (e) {
          console.error(e);
        }
      } else {
        needsSubProcessRestart = true;
      }
    }
    clearTimeout(timeout);
    timeout = setTimeout(() => doRestart(needsSubProcessRestart), 1000);
  });

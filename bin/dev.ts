import { execa } from "execa";
import { resolve } from "path";

import type { Subprocess } from "execa";

const cwd = resolve(__dirname, "..");
const nodemon = require("nodemon");
const color = require("cli-color");
const { env } = process;

const nodemonConfig = {
  watch: [
    "src/**/*",
    "dev/**/*",
    "src-ruby/**/*",
    "package.json",
    "vite.config.mts",
  ],
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

const doStart = async () => {
  if (subprocess) {
    await subprocess.kill();
  }
  if (abortController) {
    if (abortController.signal.aborted) {
      return;
    }
    abortController.abort();
  }
  abortController = new AbortController();
  if (!abortController.signal.aborted) {
    await execa("npx", ["vite", "build", "--mode", "development"], {
      cwd,
      cancelSignal: abortController.signal,
      stdio: "inherit",
      reject: false,
      env,
    });
  }
  if (!abortController.signal.aborted) {
    await new Promise((resolve) => setTimeout(resolve, 500));
  }
  if (!abortController.signal.aborted) {
    await execa("docker", ["compose", "restart", "redmine"], {
      cwd,
      cancelSignal: abortController.signal,
      stdio: "inherit",
      reject: false,
      env,
    });
  }
  // if (!abortController.signal.aborted) {
  //   subprocess = execa("node", ["index.mjs", ...cmdArgs], {
  //     cwd: resolve(cwd, "dist"),
  //     stdio: "inherit",
  //     reject: false,
  //     cancelSignal: abortController.signal,
  //     env: {
  //       ...(env.all(true) as Record<string, string>),
  //       NODE_TLS_REJECT_UNAUTHORIZED: "1",
  //     },
  //   });
  //   subprocess.on("exit", (code) => {
  //     if (code === 0) {
  //       console.log(color.green("Server process exited successfully"));
  //     } else {
  //       console.log(
  //         color.red(`Server process exited with an error code: ${code}`),
  //       );
  //     }
  //   });
  // }
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
    clearTimeout(timeout);
    timeout = setTimeout(() => doStart(), 1000);
  });

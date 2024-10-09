import { resolve, dirname } from "path";
import { readdir, copyFile, mkdir } from "fs/promises";
import { statSync, existsSync } from "fs";
import type { Plugin } from "vite";

const cwd = resolve(__dirname, "..");

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
  await readFiles(resolve(cwd, "src-ruby"));
  return Array.from(files).map((file) => {
    return {
      src: file,
      dest: file.replace(
        resolve(cwd, "src-ruby"),
        resolve(cwd, "plugins", "greenmine"),
      ),
    };
  });
};

export const copyRubyFilesAfterBuild = (): Plugin => {
  return {
    name: "copy-ruby-files-after-build",
    async writeBundle() {
      const toCopy = await getStaticCopyTargets();
      for (const { src, dest } of toCopy) {
        console.log(`Copying ${src} to ${dest}`);
        const destDir = dirname(dest);
        const exists = existsSync(destDir);
        if (!exists) {
          console.log(`Creating directory ${destDir}`);
          await mkdir(destDir, { recursive: true });
        }
        try {
          await copyFile(src, dest);
        } catch (e) {
          console.error(e);
        }
      }
    },
  };
};

import { join } from "path";
import { writeFile } from "fs/promises";
import { favicons } from "favicons";

const getLocalPath = (path: string) => join(__dirname, path);

const source = getLocalPath("../src/assets/icon.svg");
const destination = getLocalPath("../src/public");
const config = {
  appName: "Friday",
  appShortName: "Friday",
  start_url: "/",
  appDescription:
    "Welcome to Friday: your favorite day of the week! Say goodbye to the convoluted workflows and hello to intuitive, efficient, and no-nonsense project and product management. Friday works the way you do—cutting through the chaos and delivering a streamlined, developer-first experience. It’s as flexible as your code and as reliable as your coffee. With Friday, every day feels like a win—except maybe actual Monday!",
  developerName: "Jak Guru",
  developerURL: "https://github.com/jakguru",
  background: "#282F4C",
  theme_color: "#00854d",
  appleStatusBarStyle: "default",
  display: "browser",
  orientation: "any",
  preferRelatedApplications: false,
  version: "1.0",
  manifestMaskable: [
    getLocalPath("../src/assets/icon.svg"),
    getLocalPath("../src/assets/icon-black.svg"),
    getLocalPath("../src/assets/icon-white.svg"),
  ],
  icons: {
    android: true,
    appleIcon: true,
    appleStartup: true,
    favicons: true,
    windows: true,
    yandex: true,
  },
  shortcuts: [],
};

const run = async () => {
  console.log("Starting to generate favicons");
  const response = await favicons(source, config);
  console.log("Favicons generated successfully");
  console.log("Writing Image Files");
  await Promise.all(
    response.images.map(
      async (image) =>
        await writeFile(join(destination, image.name), image.contents),
    ),
  );
  console.log("Image Files written successfully");
  console.log("Writing Non-Image Files");
  await Promise.all(
    response.files.map(
      async (file) =>
        await writeFile(join(destination, file.name), file.contents),
    ),
  );
  console.log("Non-Image Files written successfully");
  console.log("Favicons generated successfully");
};

run();

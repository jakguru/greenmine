import { createHead } from "@unhead/vue";
import { InferSeoMetaPlugin } from "@unhead/addons";

export const head = createHead({
  plugins: [InferSeoMetaPlugin()],
});

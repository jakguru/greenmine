import { useHead } from "@unhead/vue";
import { i18n } from "@/plugins/i18n";

import type { RouteLocationNormalizedGeneric } from "vue-router";

export const updateHead = (
  to: RouteLocationNormalizedGeneric,
  appData: any,
) => {
  const title =
    "object" === typeof to.meta &&
    null !== to.meta &&
    "string" === typeof to.meta.title
      ? i18n.global.t(to.meta.title, {
          params: to.params,
          query: to.query,
          hash: to.hash,
        })
      : (appData.name as string);
  const titleTemplate = title === appData.name ? null : `%s - ${appData.name}`;
  const options = {
    title,
    titleTemplate,
  };
  useHead(options);
};

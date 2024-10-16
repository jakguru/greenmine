import { getDebugger } from "@jakguru/vueprint/utilities/debug";
import type { ApiService } from "@jakguru/vueprint";

const debug = getDebugger("Friday:api");

export const redmineizeApi = (api?: ApiService) => {
  if (!api) {
    return;
  }
  api.defaults.validateStatus = () => true;
  api.defaults.withCredentials = true;
  api.defaults.headers.common["X-Requested-With"] = "XMLHttpRequest";
  api.interceptors.request.use(
    (config) => {
      if (
        document &&
        config &&
        config.method &&
        ["POST", "PUT", "PATCH"].includes(config.method.toUpperCase())
      ) {
        const csrfTokenMeta = document.querySelector('meta[name="csrf-token"]');
        const token = csrfTokenMeta
          ? csrfTokenMeta.getAttribute("content") || ""
          : "";
        config.headers["X-CSRF-Token"] = token;
      }
      return config;
    },
    (error) => Promise.reject(error),
  );
  debug("Redmineized API");
};

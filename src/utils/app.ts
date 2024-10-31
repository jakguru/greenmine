import { computed, ref, inject } from "vue";
import { getDebugger } from "@jakguru/vueprint/utilities/debug";
import { i18n } from "@/plugins/i18n";
import { useAppDataStore } from "@/stores/appData";
import { useRouteDataStore } from "@/stores/routeData";
import { useTheme } from "vuetify";
import type Joi from "joi";

import {
  ApiService,
  LocalStorageService,
  ToastService,
} from "@jakguru/vueprint";
import type { RouteLocationNormalizedGeneric } from "vue-router";
import type { Ref, ComputedRef } from "vue";

export const appDebug = getDebugger("Friday:app", "#62B682", "#FFFFFF");

export const loadAppData = async (
  ls: LocalStorageService | undefined,
  api: ApiService | undefined,
  _force: boolean = false,
) => {
  if (!ls || !api) {
    return;
  }
  await ls.promise;
  const store = useAppDataStore();
  const { status, data } = await api.get("/ui/data/app");
  if (status === 200) {
    ls.set("app", data);
    store.set(data);
    appDebug("App data loaded from API and saved to local storage");
  } else {
    appDebug("Failed to load app data from API");
  }
};

export const loadRouteData = async (
  route: RouteLocationNormalizedGeneric,
  api: ApiService | undefined,
  toast: ToastService | undefined,
) => {
  if (!api) {
    return false;
  }
  const { status, headers, data } = await api.get(route.fullPath);
  if (!headers["content-type"].includes("json")) {
    if (toast) {
      toast.fire({
        icon: "error",
        title: i18n.global.t("errors.response.not_json.title"),
        text: i18n.global.t("errors.response.not_json.text"),
      });
      return false;
    }
    return false;
  } else if (status < 200 || status >= 300) {
    if (toast) {
      toast.fire({
        icon: "error",
        title: i18n.global.t("errors.response.error.title", { status }),
        text: i18n.global.t("errors.response.error.text", { status }),
      });
      return false;
    }
    return false;
  }
  return data;
};

export interface AsyncActionMethod<T = unknown> {
  (): Promise<T>;
}

export class AsyncAction<
  T extends AsyncActionMethod = AsyncActionMethod<unknown>,
> {
  readonly #method: T;
  readonly #loading: Ref<boolean>;

  constructor(method: T) {
    this.#method = method;
    this.#loading = ref(false);
  }

  get loading(): ComputedRef<boolean> {
    return computed(() => this.#loading.value);
  }

  async call(): Promise<Awaited<ReturnType<T>>> {
    this.#loading.value = true;
    try {
      // @ts-expect-error - I don't know how to fix this
      return await this.#method(...arguments);
    } finally {
      this.#loading.value = false;
    }
  }
}

export const useAppData = () => {
  const ls = inject<LocalStorageService>("ls");
  return computed(() => {
    if (ls && ls.value) {
      return ls.value.app;
    } else {
      return {
        name: "Friday",
        i18n: i18n.global.locale,
        identity: {
          authenticated: false,
          identity: null,
        },
        settings: {
          loginRequired: false,
          gravatarEnabled: false,
          selfRegistrationEnabled: true,
        },
        queries: {
          projects: {
            operators: {
              list: ["=", "!"],
              list_with_history: ["=", "!", "ev", "!ev", "cf"],
              list_status: ["o", "=", "!", "ev", "!ev", "cf", "c", "*"],
              list_optional: ["=", "!", "!*", "*"],
              list_optional_with_history: [
                "=",
                "!",
                "ev",
                "!ev",
                "cf",
                "!*",
                "*",
              ],
              list_subprojects: ["*", "!*", "=", "!"],
              date: [
                "=",
                ">=",
                "<=",
                "><",
                "<t+",
                ">t+",
                "><t+",
                "t+",
                "nd",
                "t",
                "ld",
                "nw",
                "w",
                "lw",
                "l2w",
                "nm",
                "m",
                "lm",
                "y",
                ">t-",
                "<t-",
                "><t-",
                "t-",
                "!*",
                "*",
              ],
              date_past: [
                "=",
                ">=",
                "<=",
                "><",
                ">t-",
                "<t-",
                "><t-",
                "t-",
                "t",
                "ld",
                "w",
                "lw",
                "l2w",
                "m",
                "lm",
                "y",
                "!*",
                "*",
              ],
              string: ["~", "*~", "=", "!~", "!", "^", "$", "!*", "*"],
              text: ["~", "*~", "!~", "^", "$", "!*", "*"],
              search: ["~", "*~", "!~"],
              integer: ["=", ">=", "<=", "><", "!*", "*"],
              float: ["=", ">=", "<=", "><", "!*", "*"],
              relation: ["=", "!", "=p", "=!p", "!p", "*o", "!o", "!*", "*"],
              tree: ["=", "~", "!*", "*"],
            },
          },
        },
        projects: {
          active: [],
          bookmarked: [],
          recent: [],
        },
        fetchedAt: "",
      };
    }
  });
};

export const useSystemAppBarColor = () => {
  const theme = useTheme();
  return computed(() =>
    theme.current.value.dark ? "background" : "background",
  );
};

export const useSystemSurfaceColor = () => {
  const theme = useTheme();
  return computed(() =>
    theme.current.value.dark ? "surface-darken-1" : "surface-darken-1",
  );
};

export const useSystemAccentColor = () => {
  const theme = useTheme();
  return computed(() =>
    theme.current.value.dark ? "accent-darken-2" : "accent-darken-1",
  );
};

export const matchesSchema = <T = unknown>(
  data: unknown,
  schema: Joi.Schema,
  debug: boolean = false,
) => {
  try {
    const { value, error } = schema.validate(data);
    if (error) {
      if (debug) {
        appDebug("Schema validation failed", error);
      }
      return false;
    } else {
      return value as T;
    }
  } catch {
    return false;
  }
};

export const cloneObject = <T = unknown>(obj: T): T => {
  return JSON.parse(JSON.stringify(obj));
};

export const checkObjectEquality = <T = unknown>(a: T, b: T): boolean => {
  const clonedA = cloneObject(a);
  const clonedB = cloneObject(b);
  return JSON.stringify(clonedA) === JSON.stringify(clonedB);
};

export const useReloadRouteData = (
  route: RouteLocationNormalizedGeneric,
  api: ApiService | undefined,
  toast: ToastService | undefined,
) => {
  const routeDataStore = useRouteDataStore();
  return new AsyncAction(async () => {
    appDebug("Reloading route data");
    const data = await loadRouteData(route, api, toast);
    routeDataStore.set(data);
    appDebug("Route data reloaded");
  });
};

export const useReloadAppData = (
  ls: LocalStorageService | undefined,
  api: ApiService | undefined,
) => {
  return new AsyncAction(async () => {
    appDebug("Reloading app data");
    await loadAppData(ls, api);
    appDebug("App data reloaded");
  });
};

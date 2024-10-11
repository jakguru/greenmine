import { computed, ref } from "vue";
import { getDebugger } from "@jakguru/vueprint/utilities/debug";
import { i18n } from "@/plugins/i18n";

import type {
  ApiService,
  LocalStorageService,
  ToastService,
} from "@jakguru/vueprint";
import type { RouteLocationNormalizedGeneric } from "vue-router";
import type { Ref, ComputedRef } from "vue";

export const appDebug = getDebugger("Greenmine:app", "#62B682", "#FFFFFF");

export const loadAppData = async (
  ls: LocalStorageService | undefined,
  api: ApiService | undefined,
  _force: boolean = false,
) => {
  if (!ls || !api) {
    return;
  }
  await ls.promise;
  const { status, data } = await api.get("/ui/data/app");
  if (status === 200) {
    ls.set("app", data);
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

import { getDebugger } from "@jakguru/vueprint/utilities/debug";

import type { ApiService, LocalStorageService } from "@jakguru/vueprint";

export const appDebug = getDebugger("Greenmine:app", "#62B682", "#FFFFFF");

export const loadAppData = async (
  ls: LocalStorageService | undefined,
  api: ApiService | undefined,
) => {
  if (!ls || !api) {
    return;
  }
  const fromLocalStorage = ls.get("app");
  if (!fromLocalStorage) {
    const { status, data } = await api.get("/ui/data/app");
    if (status === 200) {
      ls.set("app", data);
    }
  }
};

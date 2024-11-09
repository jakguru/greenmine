import { defineStore } from "pinia";
import { DateTime } from "luxon";

interface RouteData extends Record<string, unknown> {
  key: string;
}

export const useRouteDataStore = defineStore("routeData", {
  state: () => ({
    data: {} as RouteData,
    loading: false,
    cache: {} as RouteData,
  }),
  actions: {
    set(data: Record<string, unknown>) {
      this.data = { ...data, key: DateTime.now().toISO() };
    },
    store(data: Record<string, unknown>) {
      this.cache = { ...data, key: DateTime.now().toISO() };
    },
    isLoading(is: boolean) {
      this.loading = is;
    },
    clear() {
      this.data = {
        key: DateTime.now().toISO(),
      };
    },
  },
});

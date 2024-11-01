import { defineStore } from "pinia";

export const useRouteDataStore = defineStore("routeData", {
  state: () => ({
    data: {} as Record<string, unknown>,
    loading: false,
    cache: {} as Record<string, unknown>,
  }),
  actions: {
    set(data: Record<string, unknown>) {
      this.data = data;
    },
    store(data: Record<string, unknown>) {
      this.cache = data;
    },
    isLoading(is: boolean) {
      this.loading = is;
    },
    clear() {
      this.data = {};
    },
  },
});

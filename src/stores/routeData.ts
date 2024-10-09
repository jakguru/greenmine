import { defineStore } from "pinia";

export const useRouteDataStore = defineStore("routeData", {
  state: () => ({ data: {} as Record<string, unknown> }),
  actions: {
    set(data: Record<string, unknown>) {
      this.data = data;
    },
    clear() {
      this.data = {};
    },
  },
});

import { defineStore } from "pinia";
import { useRoute } from "vue-router";
import { updateHead } from "@/utils/head";

export const useAppDataStore = defineStore("appData", {
  state: () => ({ data: {} as Record<string, unknown> }),
  actions: {
    set(data: Record<string, unknown>) {
      this.data = data;
      const route = useRoute();
      if (route) {
        updateHead({ ...route }, data);
      }
    },
    clear() {
      this.data = {};
    },
  },
});

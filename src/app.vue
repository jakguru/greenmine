<template>
  <v-app v-if="complete">
    <v-system-bar app :color="systemBarColor">
      <ThemeToggle class="ml-auto" />
    </v-system-bar>
    <v-app-bar app color="primary"></v-app-bar>
    <v-main>
      <router-view />
    </v-main>
  </v-app>
</template>

<script lang="ts">
import { defineComponent, computed, inject } from "vue";
import { useTheme } from "vuetify";
import { useVueprint } from "@jakguru/vueprint/utilities";
import { redmineizeApi } from "@/assets/javascripts/utils/api";
import { ThemeToggle } from "@/components/theme";
// import type { LocalStorageService } from "@jakguru/vueprint";
import type { ApiService } from "@jakguru/vueprint";

export default defineComponent({
  name: "GreenmineApp",
  components: {
    ThemeToggle,
  },
  setup() {
    const { mounted, booted, ready } = useVueprint({}, true);
    const { current } = useTheme();
    // const ls = inject<LocalStorageService>("ls");
    const api = inject<ApiService>("api");
    const complete = computed(
      () => mounted.value && booted.value && ready.value,
    );
    const systemBarColor = computed(() =>
      current.value.dark ? "primary-lighten-2" : "primary-darken-2",
    );
    redmineizeApi(api);
    return {
      complete,
      systemBarColor,
    };
  },
});
</script>

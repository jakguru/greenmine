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
import { defineComponent, computed, inject, onMounted } from "vue";
import { useTheme } from "vuetify";
import { useVueprint } from "@jakguru/vueprint/utilities";
import { redmineizeApi } from "@/assets/javascripts/utils/api";
import { initializeLocale } from "@/assets/javascripts/utils/i18n";
import { ThemeToggle } from "@/components/theme";
import type {
  LocalStorageService,
  ApiService,
  BusService,
} from "@jakguru/vueprint";

export default defineComponent({
  name: "GreenmineApp",
  components: {
    ThemeToggle,
  },
  setup() {
    const { mounted, booted, ready } = useVueprint({}, true);
    const theme = useTheme();
    const ls = inject<LocalStorageService>("ls");
    const api = inject<ApiService>("api");
    const bus = inject<BusService>("bus");
    const complete = computed(
      () => mounted.value && booted.value && ready.value,
    );
    const systemBarColor = computed(() =>
      theme.current.value.dark ? "primary-lighten-2" : "primary-darken-2",
    );
    redmineizeApi(api);
    const onThemeChanged = (ct: string) => {
      if (theme && ct) {
        theme.global.name.value = ct;
      }
    };
    onMounted(() => {
      initializeLocale();
      if (ls) {
        const ct = ls.get("theme");
        if (theme && ct) {
          theme.global.name.value = ct;
        }
      }
      if (bus) {
        bus.on("theme:changed", onThemeChanged, { crossTab: true });
      }
    });
    return {
      complete,
      systemBarColor,
    };
  },
});
</script>

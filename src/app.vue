<template>
  <v-app v-if="complete">
    <v-system-bar app :color="systemBarColor">
      <ThemeToggle class="ml-auto" />
    </v-system-bar>
    <v-app-bar app color="primary"></v-app-bar>
    <v-main>
      <router-view v-if="loaded" />
      <v-overlay
        :model-value="overlay"
        class="align-center justify-center"
        persistent
      >
        <v-progress-circular
          color="primary"
          size="64"
          indeterminate
        ></v-progress-circular>
      </v-overlay>
    </v-main>
  </v-app>
</template>

<script lang="ts">
import { defineComponent, computed, inject, ref } from "vue";
import { useTheme } from "vuetify";
import { useVueprint } from "@jakguru/vueprint/utilities";
import { initializeLocale } from "@/assets/javascripts/utils/i18n";
import { redmineizeApi } from "@/assets/javascripts/utils/api";
import { appDebug, loadAppData } from "@/assets/javascripts/utils/app";
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
    const theme = useTheme();
    const ls = inject<LocalStorageService>("ls");
    const api = inject<ApiService>("api");
    const bus = inject<BusService>("bus");
    const onThemeChanged = (ct: string) => {
      if (theme && ct) {
        theme.global.name.value = ct;
      }
    };
    initializeLocale();
    if (ls) {
      ls.promise.then(() => {
        const ct = ls.get("theme");
        if (theme && ct) {
          theme.global.name.value = ct;
        } else {
          if (!theme) {
            appDebug("Vuetify theme not found");
          }
          if (!ct) {
            appDebug("Theme not found in LocalStorage");
          }
        }
      });
    }
    const { mounted, booted, ready } = useVueprint(
      {
        onBooted: {
          onTrue: () => {
            appDebug("Booted");
            if (bus) {
              bus.on("theme:changed", onThemeChanged, { crossTab: true });
            }
          },
          onFalse: () => {
            if (bus) {
              bus.off("theme:changed", onThemeChanged);
            }
          },
        },
      },
      true,
    );
    const complete = computed(
      () => mounted.value && booted.value && ready.value,
    );
    const systemBarColor = computed(() =>
      theme.current.value.dark ? "primary-lighten-2" : "primary-darken-2",
    );
    redmineizeApi(api);
    const loaded = ref(false);
    const overlay = computed(() => !loaded.value);
    loadAppData(ls, api)
      .catch(() => {})
      .finally(() => {
        loaded.value = true;
      });
    return {
      complete,
      systemBarColor,
      loaded,
      overlay,
    };
  },
});
</script>

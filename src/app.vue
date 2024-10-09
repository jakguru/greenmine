<template>
  <v-app v-if="complete">
    <v-system-bar app :color="systemBarColor">
      <ThemeToggle class="ml-auto" />
    </v-system-bar>
    <v-app-bar app density="compact" extended color="primary">
      <template #default>
        <v-toolbar-title class="site-name">{{ appData.name }}</v-toolbar-title>
      </template>
    </v-app-bar>
    <v-main>
      <router-view v-if="loaded" />
      <v-overlay
        :model-value="overlay"
        class="align-center justify-center"
        persistent
        scrim="background"
        opacity="1"
        no-click-animation
      >
        <v-progress-circular
          color="primary"
          size="64"
          indeterminate
        ></v-progress-circular>
      </v-overlay>
    </v-main>
    <v-footer app :color="systemBarColor" class="py-0">
      <v-toolbar-items class="h-100 ml-auto">
        <v-btn
          icon
          :loading="routeDataLoading"
          density="compact"
          @click="reloadRouteData"
        >
          <v-icon size="18">mdi-refresh</v-icon>
        </v-btn>
      </v-toolbar-items>
    </v-footer>
  </v-app>
</template>

<script lang="ts">
import { defineComponent, computed, inject, ref, onMounted } from "vue";
import { useTheme } from "vuetify";
import { useVueprint } from "@jakguru/vueprint/utilities";
import { initializeLocale } from "@/utils/i18n";
import { redmineizeApi } from "@/utils/api";
import { appDebug, loadAppData, loadRouteData, AsyncAction } from "@/utils/app";
import { ThemeToggle } from "@/components/theme";
import { useRoute } from "vue-router";
import type {
  LocalStorageService,
  ApiService,
  BusService,
  ToastService,
} from "@jakguru/vueprint";
import { i18n } from "@/plugins/i18n";

export default defineComponent({
  name: "GreenmineApp",
  components: {
    ThemeToggle,
  },
  setup() {
    const theme = useTheme();
    const route = useRoute();
    const ls = inject<LocalStorageService>("ls");
    const api = inject<ApiService>("api");
    const bus = inject<BusService>("bus");
    const toast = inject<ToastService>("toast");
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
    const appData = computed(() => {
      if (ls && ls.value) {
        return ls.value.app;
      } else {
        return {
          name: "Greenmine",
          i18n: i18n.global.locale.value,
          identity: {
            authenticated: false,
            identity: null,
          },
          settings: {
            loginRequired: false,
            gravatarEnabled: false,
          },
          fetchedAt: "",
        };
      }
    });
    const reloadRouteData = new AsyncAction(async () => {
      appDebug("Reloading route data");
      await loadRouteData(route, api, toast);
      appDebug("Route data reloaded");
    });
    onMounted(() => {
      loadAppData(ls, api)
        .catch(() => {})
        .finally(() => {
          loaded.value = true;
        });
    });
    return {
      complete,
      systemBarColor,
      loaded,
      overlay,
      appData,
      routeDataLoading: reloadRouteData.loading,
      reloadRouteData: () => reloadRouteData.call(),
    };
  },
});
</script>

<style lang="scss">
#greenmine-app {
  .site-name {
    font-size: 24px;
    font-weight: 700;
  }
}
</style>

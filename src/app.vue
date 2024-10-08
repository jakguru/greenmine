<template>
  <v-app v-if="complete">
    <v-app-bar app density="compact" :color="systemBarColor">
      <template #default>
        <v-menu>
          <template #activator="{ props }">
            <v-btn
              icon="mdi-dots-grid"
              density="compact"
              v-bind="props"
              class="ml-4"
            />
          </template>
          <PartialMenu :color="systemSurfaceColor" />
        </v-menu>
        <v-toolbar-title class="site-name">{{ appData.name }}</v-toolbar-title>
        <v-toolbar-items>
          <v-btn icon="mdi-magnify" @click="showSearch = !showSearch" />
          <v-divider vertical />
          <template v-if="appData.identity.authenticated">
            <div>Authenticated</div>
          </template>
          <template v-else>
            <v-btn variant="text" :to="{ name: 'login' }">
              {{ $t("actions.login") }}
            </v-btn>
            <v-btn
              v-if="appData.settings.selfRegistrationEnabled"
              variant="text"
              :to="{ name: 'account-register' }"
            >
              {{ $t("actions.register") }}
            </v-btn>
          </template>
          <v-divider vertical />
          <v-menu :close-on-content-click="false">
            <template #activator="{ props }">
              <v-btn icon="mdi-dots-vertical" v-bind="props" />
            </template>
            <v-card :color="systemSurfaceColor" width="320">
              <v-list-item :title="$t('theme.base.colorScheme')">
                <template #append>
                  <ThemeToggle />
                </template>
              </v-list-item>
            </v-card>
          </v-menu>
        </v-toolbar-items>
      </template>
    </v-app-bar>
    <v-main>
      <router-view v-if="loaded" v-slot="{ Component }">
        <component :is="Component" v-bind="routeData" />
      </router-view>
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
    <v-footer app :color="systemBarColor">
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
    <v-fab
      v-if="showDebug"
      app
      icon
      right
      bottom
      color="red"
      dark
      :loading="appDataLoading"
      @click="reloadAppData"
    >
      <v-icon>mdi-bug</v-icon>
    </v-fab>
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
import { useRouteDataStore } from "@/stores/routeData";
import { PartialMenu } from "@/partials";
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
    PartialMenu,
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
      theme.current.value.dark ? "primary-darken-2" : "primary-lighten-2",
    );
    const systemSurfaceColor = computed(() =>
      theme.current.value.dark ? "primary-darken-1" : "primary-lighten-1",
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
          i18n: i18n.global.locale,
          identity: {
            authenticated: false,
            identity: null,
          },
          settings: {
            loginRequired: false,
            gravatarEnabled: false,
            selfRegistrationEnabled: true,
          },
          fetchedAt: "",
        };
      }
    });
    const routeDataStore = useRouteDataStore();
    const routeData = computed(() => routeDataStore.data);
    const reloadRouteData = new AsyncAction(async () => {
      appDebug("Reloading route data");
      const data = await loadRouteData(route, api, toast);
      routeDataStore.set(data);
      appDebug("Route data reloaded");
    });
    const reloadAppData = new AsyncAction(async () => {
      appDebug("Reloading app data");
      await loadAppData(ls, api, true);
      appDebug("App data reloaded");
    });
    onMounted(() => {
      loadAppData(ls, api)
        .catch(() => {})
        .finally(() => {
          loaded.value = true;
        });
    });
    const showDebug = import.meta.env.MODE === "development";
    const showSearch = ref(false);
    return {
      complete,
      systemBarColor,
      systemSurfaceColor,
      loaded,
      overlay,
      appData,
      routeDataLoading: reloadRouteData.loading,
      reloadRouteData: () => reloadRouteData.call(),
      routeData,
      showDebug,
      appDataLoading: reloadAppData.loading,
      reloadAppData: () => reloadAppData.call(),
      showSearch,
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

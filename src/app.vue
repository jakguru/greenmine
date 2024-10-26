<template>
  <v-app v-if="complete">
    <v-app-bar
      app
      density="compact"
      :color="systemBarColor"
      :flat="!isMobile || (isMobile && !showMobileNav)"
    >
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
          <GlobalSearchField
            v-if="isNotMobile"
            v-model:search="globalSearchVal"
            class="h-100"
            style="min-width: 180px"
          />
          <v-menu
            v-if="isNotMobile"
            v-model="showProjectJumper"
            :close-on-content-click="false"
          >
            <template #activator="{ props }">
              <v-btn icon="mdi-dots-vertical" v-bind="props" />
            </template>
            <PartialProjectsJumper
              v-model:search="projectSearchVal"
              :system-surface-color="systemSurfaceColor"
              :app-data="appData"
              @submit:search="onProjectJumperSubmit"
            />
          </v-menu>
          <template v-if="appData.identity.authenticated">
            <AuthenticatedMenu />
          </template>
          <template v-else-if="isNotMobile">
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
          <v-menu v-if="isNotMobile" :close-on-content-click="false">
            <template #activator="{ props }">
              <v-btn icon="mdi-cog" v-bind="props" />
            </template>
            <v-card :color="systemSurfaceColor" width="320">
              <v-list-subheader class="px-3">{{
                $t("labels.settings.browser")
              }}</v-list-subheader>
              <v-list-item
                prepend-icon="mdi-palette"
                :title="$t('theme.base.colorScheme')"
              >
                <template #append>
                  <ThemeToggle />
                </template>
              </v-list-item>
              <template
                v-if="
                  appData.identity.authenticated &&
                  appData.identity.identity.admin
                "
              >
                <v-divider />
                <v-list-subheader class="px-3">{{
                  $t("labels.settings.application", {
                    name: appData.name,
                  })
                }}</v-list-subheader>
                <template
                  v-for="(item, i) in administrationNav"
                  :key="`admin-nav-item-nonmobile-${i}`"
                >
                  <v-list-item
                    v-bind="item"
                    :id="`admin-nav-item-nonmobile-${i}`"
                  />
                </template>
              </template>
            </v-card>
          </v-menu>
          <v-btn
            v-if="isMobile"
            :icon="showMobileNav ? 'mdi-menu-close' : 'mdi-menu-open'"
            @click="showMobileNav = !showMobileNav"
          />
        </v-toolbar-items>
      </template>
    </v-app-bar>
    <v-navigation-drawer
      v-if="isMobile"
      v-model="showMobileNav"
      app
      :color="systemBarColor"
      location="end"
    >
      <v-list-item>
        <GlobalSearchField v-model:search="globalSearchVal" />
      </v-list-item>
      <v-divider />
      <v-menu v-model="showProjectJumper" :close-on-content-click="false">
        <template #activator="{ props }">
          <v-list-item v-bind="props">
            <template #append>
              <v-icon>mdi-menu-down</v-icon>
            </template>
            <v-list-item-title>{{
              $t("labels.jumper.title")
            }}</v-list-item-title>
          </v-list-item>
        </template>
        <PartialProjectsJumper
          v-model:search="projectSearchVal"
          :system-surface-color="systemSurfaceColor"
          :app-data="appData"
          @submit:search="onProjectJumperSubmit"
        />
      </v-menu>
      <v-divider />
      <template v-if="!appData.identity.authenticated">
        <v-list-item :to="{ name: 'login' }" :title="$t('actions.login')" />
        <v-list-item
          v-if="appData.settings.selfRegistrationEnabled"
          :to="{ name: 'account-register' }"
          :title="$t('actions.register')"
        />
        <v-divider />
      </template>
      <v-list-subheader class="px-3">{{
        $t("labels.settings.browser")
      }}</v-list-subheader>
      <v-list-item
        prepend-icon="mdi-palette"
        :title="$t('theme.base.colorScheme')"
      >
        <template #append>
          <ThemeToggle />
        </template>
      </v-list-item>
      <template
        v-if="appData.identity.authenticated && appData.identity.identity.admin"
      >
        <v-divider />
        <v-list-subheader class="px-3">{{
          $t("labels.settings.application", {
            name: appData.name,
          })
        }}</v-list-subheader>
        <template
          v-for="(item, i) in administrationNav"
          :key="`admin-nav-item-mobile-${i}`"
        >
          <v-list-item v-bind="item" :id="`admin-nav-item-mobile-${i}`" />
        </template>
      </template>
    </v-navigation-drawer>
    <v-main>
      <router-view v-if="loaded && !isTransitioning" v-slot="{ Component }">
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
    <!-- <v-fab
      v-if="showDebug"
      app
      icon
      location="top right"
      color="red"
      dark
      size="small"
      :loading="appDataLoading"
      @click="reloadAppData"
    >
      <v-icon>mdi-bug</v-icon>
    </v-fab> -->
  </v-app>
</template>

<script lang="ts">
import { defineComponent, computed, inject, ref, onMounted, watch } from "vue";
import { useTheme, useDisplay } from "vuetify";
import { useVueprint } from "@jakguru/vueprint/utilities";
import { initializeLocale, useI18n } from "@/utils/i18n";
import { redmineizeApi } from "@/utils/api";
import {
  appDebug,
  loadAppData,
  loadRouteData,
  AsyncAction,
  useAppData,
  useSystemAppBarColor,
  useSystemSurfaceColor,
} from "@/utils/app";
import { ThemeToggle } from "@/components/theme";
import { useRoute, useRouter } from "vue-router";
import { useRouteDataStore } from "@/stores/routeData";
import { PartialMenu, PartialProjectsJumper } from "@/partials";
import { GlobalSearchField } from "@/components/menu";
import { updateHead } from "@/utils/head";
import { AuthenticatedMenu } from "@/components/authenticated-menu";
import type {
  LocalStorageService,
  ApiService,
  BusService,
  ToastService,
} from "@jakguru/vueprint";

export default defineComponent({
  name: "FridayApp",
  components: {
    ThemeToggle,
    PartialMenu,
    PartialProjectsJumper,
    GlobalSearchField,
    AuthenticatedMenu,
  },
  setup() {
    const theme = useTheme();
    const route = useRoute();
    const router = useRouter();
    const { mobile: isMobile } = useDisplay();
    const isNotMobile = computed(() => !isMobile.value);
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
    const { t } = useI18n();
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
    const systemBarColor = useSystemAppBarColor();
    const systemSurfaceColor = useSystemSurfaceColor();
    redmineizeApi(api);
    const loaded = ref(false);
    const appData = useAppData();
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
          updateHead({ ...route }, appData.value);
        });
    });
    watch(
      () => route,
      () => {
        updateHead({ ...route }, appData.value);
      },
    );
    watch(route, () => {
      updateHead({ ...route }, appData.value);
    });
    const showDebug = import.meta.env.MODE === "development";
    const showSearch = ref(false);
    const showProjectJumper = ref(false);
    const onProjectJumperSubmit = () => {
      showProjectJumper.value = false;
    };
    const projectSearchVal = ref("");
    const globalSearchVal = ref("");
    const showMobileNav = ref(false);
    const administrationNav = computed(() => [
      {
        title: t("pages.admin-projects.title"),
        prependIcon: "mdi-code-block-braces",
        to: { name: "admin-projects" },
      },
      {
        title: t("pages.users.admin.title"),
        prependIcon: "mdi-account-multiple",
        to: { name: "users" },
      },
      {
        title: t("pages.groups.admin.title"),
        prependIcon: "mdi-account-group",
        to: { name: "groups" },
      },
      {
        title: t("pages.roles.admin.title"),
        prependIcon: "mdi-badge-account",
        to: { name: "roles" },
      },
      {
        title: t("pages.trackers.admin.title"),
        prependIcon: "mdi-note-multiple",
        to: { name: "trackers" },
      },
      {
        title: t("pages.issue-statuses.admin.title"),
        prependIcon: "mdi-note-check",
        to: { name: "issue-statuses" },
      },
      {
        title: t("pages.workflows.admin.title"),
        prependIcon: "mdi-arrow-decision",
        to: { name: "workflows" },
      },
      {
        title: t("pages.custom-fields.admin.title"),
        prependIcon: "mdi-form-textbox",
        to: { name: "custom-fields" },
      },
      {
        title: t("pages.enumerations.admin.title"),
        prependIcon: "mdi-list-box",
        to: { name: "enumerations" },
      },
      {
        title: t("pages.settings.admin.title"),
        prependIcon: "mdi-folder-cog",
        to: { name: "settings" },
      },
      {
        title: t("pages.auth-sources.admin.title"),
        prependIcon: "mdi-shield-account-variant",
        to: { name: "auth-sources" },
      },
      {
        title: t("pages.admin-plugins.title"),
        prependIcon: "mdi-puzzle",
        to: { name: "admin-plugins" },
      },
      {
        title: t("pages.admin-info.title"),
        prependIcon: "mdi-information",
        to: { name: "admin-info" },
      },
      {
        title: t("pages.admin.menu.title"),
        prependIcon: "mdi-cog",
        to: { name: "admin" },
      },
    ]);
    const isTransitioning = ref(false);
    const overlay = computed(() => !loaded.value || isTransitioning.value);
    router.beforeEach((to, from) => {
      if (to.name !== from.name) {
        isTransitioning.value = true;
      }
    });
    router.afterEach(() => {
      isTransitioning.value = false;
    });
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
      showProjectJumper,
      onProjectJumperSubmit,
      isMobile,
      isNotMobile,
      showMobileNav,
      projectSearchVal,
      globalSearchVal,
      administrationNav,
      isTransitioning,
    };
  },
});
</script>

<style lang="scss">
#friday-app {
  .site-name {
    font-size: 24px;
    font-weight: 700;
  }
}
</style>

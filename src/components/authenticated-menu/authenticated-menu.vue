<template>
  <v-menu v-model="showAuthMenu" :close-on-content-click="false">
    <template #activator="{ props }">
      <v-btn icon v-bind="props">
        <v-avatar :color="systemSurfaceColor" size="32">
          <span class="font-weight-bold">{{ avatarLetters }}</span>
        </v-avatar>
      </v-btn>
    </template>
    <v-card :color="systemAppBarColor" width="320" min-height="100">
      <v-list-item>
        <template #prepend>
          <v-avatar :color="systemSurfaceColor" size="32">
            <span class="font-weight-bold">{{ avatarLetters }}</span>
          </v-avatar>
        </template>
        <v-list-item-subtitle>
          <small>{{ $t("labels.loggedInAs") }}</small>
        </v-list-item-subtitle>
        <v-list-item-title>
          <RouterLink :to="userRoute" class="font-weight-bold">
            {{ appData.identity.identity.login }}
          </RouterLink>
        </v-list-item-title>
        <template #append>
          <v-btn
            icon="mdi-logout"
            :to="logoutRoute"
            size="x-small"
            variant="flat"
            color="accent"
          />
        </template>
      </v-list-item>
      <v-divider />
      <template v-for="(item, i) in navItems" :key="`nav-item-${i}`">
        <v-list-item v-bind="item" />
      </template>
    </v-card>
  </v-menu>
</template>

<script lang="ts">
import { defineComponent, ref, computed } from "vue";
import { useI18n } from "vue-i18n";
import {
  useAppData,
  useSystemAppBarColor,
  useSystemSurfaceColor,
} from "@/utils/app";
import { RouterLink, useRouter } from "vue-router";

export default defineComponent({
  name: "AuthenticatedMenu",
  compoments: {
    RouterLink,
  },
  setup() {
    const { t } = useI18n({ useScope: "global" });
    const router = useRouter();
    const appData = useAppData();
    const showAuthMenu = ref(false);
    router.afterEach(() => {
      showAuthMenu.value = false;
    });
    const systemAppBarColor = useSystemAppBarColor();
    const systemSurfaceColor = useSystemSurfaceColor();
    const avatarLetters = computed(() => {
      if (appData.value.settings.gravatarEnabled) {
        return "";
      } else {
        return [
          appData.value.identity.identity.firstname,
          appData.value.identity.identity.lastname,
        ]
          .filter((v) => "string" === typeof v)
          .map((v) => v[0].toUpperCase().trim())
          .join("");
      }
    });
    const userRoute = computed(() => ({
      name: "users-id",
      params: { id: appData.value.identity.identity.id },
    }));
    const logoutRoute = computed(() => ({
      name: "logout",
    }));
    const navItems = computed(() => [
      {
        title: t("pages.my.title"),
        to: { name: "my" },
        prependIcon: "mdi-view-dashboard-variant",
      },
      {
        title: t("pages.my-account.title"),
        to: { name: "my-account" },
        prependIcon: "mdi-account",
      },
      {
        title: t("pages.my-password.title"),
        to: { name: "my-password" },
        prependIcon: "mdi-form-textbox-password",
      },
      {
        title: t("pages.my-api-key.title"),
        to: { name: "my-api-key" },
        prependIcon: "mdi-code-json",
      },
    ]);
    return {
      appData,
      showAuthMenu,
      systemAppBarColor,
      avatarLetters,
      systemSurfaceColor,
      userRoute,
      logoutRoute,
      navItems,
    };
  },
});
</script>

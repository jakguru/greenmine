<template>
  <v-container class="page-logout fill-height" :fluid="true">
    <v-row justify="center">
      <v-col cols="12" sm="6" md="4" lg="3" xxl="2">
        <v-card color="surface">
          <v-toolbar :color="systemAppBarColor" density="compact">
            <v-toolbar-title>{{
              $t("pages.logout.content.form.header", { name: appData.name })
            }}</v-toolbar-title>
          </v-toolbar>
          <v-divider />
          <v-card-text>
            <p>{{ $t("pages.logout.content.pleaseWaitWhileProcessing") }}</p>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script lang="ts">
import { defineComponent, computed, inject, onMounted } from "vue";
import {
  useSystemAppBarColor,
  useSystemSurfaceColor,
  loadAppData,
  useAppData,
  AsyncAction,
} from "@/utils/app";
import { useRouter } from "vue-router";

import type { PropType } from "vue";
import type { ApiService, LocalStorageService } from "@jakguru/vueprint";
export default defineComponent({
  name: "LogoutPage",
  props: {
    to: {
      type: String as PropType<string | undefined>,
      default: undefined,
    },
  },
  setup(props) {
    const router = useRouter();
    const api = inject<ApiService>("api");
    const ls = inject<LocalStorageService>("ls");
    const systemAppBarColor = useSystemAppBarColor();
    const systemSurfaceColor = useSystemSurfaceColor();
    const appData = useAppData();
    const to = computed(() => props.to);
    const backToUrl = computed(() => to.value || "/");
    const loadAppDataAsyncAction = new AsyncAction(async () => {
      await loadAppData(ls, api);
      if (backToUrl.value.startsWith("http")) {
        const url = new URL(backToUrl.value);
        router.push(url.pathname);
      } else {
        router.push(backToUrl.value);
      }
    });
    const loadingAppData = computed(() => loadAppDataAsyncAction.loading);
    onMounted(() => {
      loadAppDataAsyncAction.call();
    });
    return {
      systemAppBarColor,
      systemSurfaceColor,
      appData,
      loadingAppData,
    };
  },
});
</script>

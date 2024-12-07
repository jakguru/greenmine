<template>
  <v-sheet v-bind="wrapperProps">
    <VChart
      :option="option"
      :autoresize="true"
      :loading="loading"
      :theme="theme"
      :loading-options="loadingOptions"
    />
    <v-dialog v-bind="filterDialogBindings">
      <v-card color="surface">
        <v-toolbar color="transparent" density="compact">
          <v-toolbar-title>{{ $t("charts.filters") }}</v-toolbar-title>
          <v-toolbar-items>
            <v-btn icon="mdi-close" @click="closeFilterDialog" />
          </v-toolbar-items>
        </v-toolbar>
        <v-divider />
        <v-container></v-container>
      </v-card>
    </v-dialog>
    <v-btn
      v-show="!loading"
      color="accent"
      icon="mdi-filter"
      size="x-small"
      :style="{ position: 'absolute', bottom: '16px', right: '16px' }"
      @click="openFilterDialog"
    />
  </v-sheet>
</template>

<script lang="ts">
import {
  defineComponent,
  inject,
  computed,
  ref,
  onMounted,
  onBeforeUnmount,
  watch,
} from "vue";
import { useI18n } from "vue-i18n";
import { AsyncAction, matchesSchema, useIsDark } from "@/utils/app";
import Joi from "joi";
import qs from "qs";
import reloadIconUrl from "@/assets/images/reload.png?url";

import VChart from "vue-echarts";
import { use } from "echarts/core";
import { ThemeRiverChart } from "echarts/charts";
import {
  TooltipComponent,
  LegendComponent,
  SingleAxisComponent,
  ToolboxComponent,
} from "echarts/components";
import { SVGRenderer } from "echarts/renderers";

import type { PropType } from "vue";
import type { ApiService } from "@jakguru/vueprint";
import type { ChartDataItem } from "./index";
import type { ComposeOption } from "echarts/core";
import type { ThemeRiverSeriesOption } from "echarts/charts";
import type {
  TooltipComponentOption,
  LegendComponentOption,
  SingleAxisComponentOption,
  ToolboxComponentOption,
} from "echarts/components";

type EChartsOption = ComposeOption<
  | TooltipComponentOption
  | LegendComponentOption
  | SingleAxisComponentOption
  | ToolboxComponentOption
  | ThemeRiverSeriesOption
>;

use([
  TooltipComponent,
  LegendComponent,
  SingleAxisComponent,
  ToolboxComponent,
  ThemeRiverChart,
  SVGRenderer,
]);

export default defineComponent({
  name: "IssuesByStatusChart",
  components: {
    VChart,
  },
  props: {
    formAuthenticityToken: {
      type: String,
      required: true,
    },
    endpoint: {
      type: String as PropType<
        `http://${string}` | `https://${string}` | `/${string}`
      >,
      required: true,
    },
  },
  setup(props) {
    const { t } = useI18n({ useScope: "global" });
    const api = inject<ApiService>("api");
    const isDark = useIsDark();
    const endpoint = computed(() => props.endpoint);
    const data = ref<ChartDataItem[]>([]);
    const filters = ref<Record<string, any>>({});
    const dataSchema = Joi.array().items(
      Joi.array().items(Joi.any().required(), Joi.any().required()),
    );
    let actionAbortController: AbortController | undefined;
    const dataFetcherAction = new AsyncAction(async () => {
      if (!api) {
        return;
      }
      if (actionAbortController) {
        actionAbortController.abort();
      }
      actionAbortController = new AbortController();
      try {
        const { status, data: returned } = await api.get<ChartDataItem[]>(
          `${endpoint.value}?${qs.stringify(filters.value)}`,
          {
            signal: actionAbortController.signal,
          },
        );
        if (status === 200 && matchesSchema(returned, dataSchema)) {
          data.value = returned;
        }
      } catch {
        // noop
      }
    });
    const doLoad = () => {
      dataFetcherAction.call();
    };
    watch(
      () => filters.value,
      () => {
        doLoad();
      },
      { deep: true },
    );
    onMounted(() => {
      doLoad();
    });
    onBeforeUnmount(() => {
      if (actionAbortController) {
        actionAbortController.abort();
      }
    });
    const wrapperProps = computed(() => ({
      height: 300,
      class: [
        "friday-chart",
        "friday-issues-by-status-chart",
        "position-relative",
      ],
    }));
    const option = computed<EChartsOption>(() => ({
      useUTC: true,
      darkMode: isDark.value,
      backgroundColor: "transparent",
      toolbox: {
        feature: {
          myRefresh: {
            show: true,
            title: t("charts.actions.refresh"),
            icon: `image://${reloadIconUrl}`,
            onclick: () => {
              doLoad();
            },
          },
        },
      },
    }));
    const loadingOptions = computed(() => ({
      text: t("charts.loading"),
      color: "#00854d",
      textColor: isDark.value ? "#fff" : "#000",
      maskColor: isDark.value
        ? "rgba(24, 27, 52, 0.8)"
        : "rgba(255, 255, 255, 0.8)",
    }));
    const loading = computed(() => dataFetcherAction.loading.value);
    const theme = computed(() => (isDark.value ? "dark" : "light"));
    const showFilterDialog = ref(false);
    const filterDialogBindings = computed(() => ({
      modelValue: showFilterDialog.value,
      "onUpdate:modelValue": (value: boolean) => {
        showFilterDialog.value = value;
      },
      maxWidth: 400,
      absolute: true,
      attach: true,
      contained: true,
    }));
    const openFilterDialog = () => {
      showFilterDialog.value = true;
    };
    const closeFilterDialog = () => {
      showFilterDialog.value = false;
    };
    return {
      doLoad,
      filters,
      wrapperProps,
      option,
      loading,
      loadingOptions,
      theme,
      filterDialogBindings,
      openFilterDialog,
      closeFilterDialog,
    };
  },
});
</script>

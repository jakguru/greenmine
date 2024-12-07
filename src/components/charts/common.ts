import { inject, computed, ref, onMounted, onBeforeUnmount, watch } from "vue";
import { useI18n } from "vue-i18n";
import { AsyncAction, matchesSchema, useIsDark } from "@/utils/app";
import { DateTime } from "luxon";
import Joi from "joi";
import qs from "qs";
import reloadIconUrl from "@/assets/images/reload.png?url";
import BaseChart from "./base.vue";

import type { Ref } from "vue";
import type { ApiService } from "@jakguru/vueprint";
import type { ChartDataItem } from "./index";

export type ChartPropsType = Readonly<{
  formAuthenticityToken: string;
  endpoint: `http://${string}` | `https://${string}` | `/${string}`;
  minDateTime: string;
}>;

export { BaseChart };

export const useChartSetup = <EChartsOption extends Record<string, any>>(
  props: ChartPropsType,
  filters: Ref<Record<string, any>>,
  specificChartOptions: EChartsOption,
) => {
  const { t } = useI18n({ useScope: "global" });
  const api = inject<ApiService>("api");
  const isDark = useIsDark();
  const endpoint = computed(() => props.endpoint);
  const minDateTime = computed(() => DateTime.fromISO(props.minDateTime));
  const data = ref<ChartDataItem[]>([]);
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
    filters.value.from = minDateTime.value.toISODate();
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
      "friday-activity-summary-chart",
      "position-relative",
    ],
  }));
  const option = computed<EChartsOption>(() => {
    const base: EChartsOption = {
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
      ...specificChartOptions,
    };

    if (Array.isArray(base.series)) {
      base.series[0].data = data.value;
    } else if ("object" === typeof base.series && null !== base.series) {
      base.series.data = data.value;
    }
    return base;
  });
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
};

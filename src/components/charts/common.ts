import { inject, computed, ref, onMounted, onBeforeUnmount, watch } from "vue";
import { useI18n } from "vue-i18n";
import { AsyncAction, matchesSchema, useIsDark } from "@/utils/app";
import { DateTime } from "luxon";
import Joi from "joi";
import reloadIconUrl from "@/assets/images/reload.png?url";
import BaseChart from "./base.vue";

import type { Ref } from "vue";
import type { ApiService, CronService } from "@jakguru/vueprint";

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
  dataSchema: Joi.Schema,
) => {
  const now = ref<DateTime>(DateTime.now());
  const { t } = useI18n({ useScope: "global" });
  const api = inject<ApiService>("api");
  const cron = inject<CronService>("cron");
  const isDark = useIsDark();
  const endpoint = computed(() => props.endpoint);
  const minDateTime = computed(() => DateTime.fromISO(props.minDateTime));
  const data = ref<Record<string, unknown>>({});
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
      const { status, data: returned } = await api.post<
        Record<string, unknown>
      >(
        `${endpoint.value}`,
        {
          ...filters.value,
          authenticity_token: props.formAuthenticityToken,
        },
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
  const updateNow = () => {
    now.value = DateTime.now();
  };
  onMounted(() => {
    updateNow();
    filters.value.from = now.value.minus({ days: 10 }).toISODate();
    if (cron) {
      cron.$on("* * * * * *", updateNow);
    }
  });
  onBeforeUnmount(() => {
    if (actionAbortController) {
      actionAbortController.abort();
    }
    if (cron) {
      cron.$off("* * * * * *", updateNow);
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
      ...data.value,
    };
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
  const minDate = computed(() => minDateTime.value.toSQLDate()!);
  const maxDate = computed(() => now.value.toSQLDate()!);
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
    minDate,
    maxDate,
  };
};

export const calendarChartDataSchema = Joi.object().unknown(true);
export const themeRiverChartDataSchema = Joi.object().unknown(true);

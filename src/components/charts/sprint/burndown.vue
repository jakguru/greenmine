<template>
  <v-card height="300" variant="outlined" class="position-relative">
    <v-label class="ms-3 position-absolute" style="z-index: 3">{{
      $t("charts.burndown.title")
    }}</v-label>
    <VChart
      :option="option"
      :autoresize="true"
      :loading="loading"
      :theme="isDark ? 'dark' : 'light'"
      :loading-options="loadingOptions"
    />
    <v-sheet
      v-if="!loading"
      width="20"
      height="20"
      class="position-absolute"
      style="top: 4px; right: 4px; z-index: 5"
    >
      <v-btn icon flat :loading="loading" size="20" @click="loadBurndown">
        <v-icon size="20">mdi-refresh</v-icon>
      </v-btn>
    </v-sheet>
    <!-- <v-overlay
      :model-value="loading"
      contained
      class="align-center justify-center"
    >
      <v-progress-circular indeterminate size="64" :color="systemAccentColor" />
    </v-overlay> -->
  </v-card>
</template>

<script lang="ts">
import {
  defineComponent,
  computed,
  ref,
  inject,
  watch,
  onMounted,
  onBeforeUnmount,
} from "vue";
import { use } from "echarts/core";
import { LineChart, BarChart } from "echarts/charts";
import {
  TitleComponent,
  TooltipComponent,
  ToolboxComponent,
  LegendComponent,
  GridComponent,
  DataZoomComponent,
} from "echarts/components";
import { CanvasRenderer } from "echarts/renderers";
import { useI18n } from "vue-i18n";
import { useSystemAccentColor, useIsDark, AsyncAction } from "@/utils/app";
import { DateTime } from "luxon";
import VChart from "vue-echarts";

import type { PropType } from "vue";
import type { ComposeOption } from "echarts/core";
import type { LineSeriesOption, BarSeriesOption } from "echarts/charts";
import type {
  TitleComponentOption,
  TooltipComponentOption,
  ToolboxComponentOption,
  LegendComponentOption,
  GridComponentOption,
  DataZoomComponentOption,
} from "echarts/components";
import type { Sprint, SprintBurndown } from "@/friday";
import type { ApiService, CronService } from "@jakguru/vueprint";

use([
  TitleComponent,
  TooltipComponent,
  ToolboxComponent,
  LegendComponent,
  GridComponent,
  DataZoomComponent,
  LineChart,
  BarChart,
  CanvasRenderer,
]);

type EChartsOption = ComposeOption<
  | TitleComponentOption
  | TooltipComponentOption
  | ToolboxComponentOption
  | LegendComponentOption
  | GridComponentOption
  | DataZoomComponentOption
  | LineSeriesOption
  | BarSeriesOption
>;

export default defineComponent({
  name: "SprintBurndown",
  components: {
    VChart,
  },
  props: {
    sprint: {
      type: Object as PropType<Sprint>,
      required: true,
    },
  },
  setup(props) {
    const { t } = useI18n({ useScope: "global" });
    const api = inject<ApiService>("api");
    const cron = inject<CronService>("cron");
    const sprint = computed(() => props.sprint);
    const systemAccentColor = useSystemAccentColor();
    const isDark = useIsDark();
    const todayAsMs = ref<number>(DateTime.now().toMillis());
    const todayAsDate = ref<string>(DateTime.now().toISODate());
    const updateToday = () => {
      todayAsMs.value = DateTime.now().toMillis();
      todayAsDate.value = DateTime.now().toISODate();
    };
    const retreived = ref<SprintBurndown>({});
    let abortController: AbortController | undefined;
    const loadBurndown = new AsyncAction(async () => {
      if (!api) {
        return;
      }
      const sprintId = sprint.value.id ? sprint.value.id : 0;
      if (abortController) {
        abortController.abort();
      }
      abortController = new AbortController();
      try {
        const { status, data } = await api.get<SprintBurndown>(
          `/sprints/${sprintId}/burndown`,
          {
            signal: abortController.signal,
          },
        );
        if (status === 200) {
          retreived.value = data;
        } else {
          retreived.value = {};
        }
      } catch {
        // noop
      }
    });
    const burndownRemainingIdeal = computed(() =>
      Object.keys(retreived.value).map((date) => [
        DateTime.fromISO(date).toMillis(),
        retreived.value[date].ideal_remaining_work,
      ]),
    );
    const burndownRemainingActual = computed(() =>
      Object.keys(retreived.value).map((date) => [
        DateTime.fromISO(date).toMillis(),
        retreived.value[date].actual_remaining_work,
      ]),
    );
    const burndownWorkEstimated = computed(() =>
      Object.keys(retreived.value).map((date) => [
        DateTime.fromISO(date).toMillis(),
        retreived.value[date].estimated_work,
      ]),
    );
    const burndownWorkActual = computed(() =>
      Object.keys(retreived.value).map((date) => [
        DateTime.fromISO(date).toMillis(),
        retreived.value[date].logged_work,
      ]),
    );
    const option = computed<EChartsOption>(() => ({
      useUTC: true,
      darkMode: isDark.value,
      backgroundColor: "transparent",
      tooltip: {
        trigger: "axis",
        axisPointer: {
          type: "cross",
          crossStyle: {
            color: "#999",
          },
        },
      },
      legend: {
        data: [
          t("charts.burndown.remaining.ideal"),
          t("charts.burndown.remaining.actual"),
          t("charts.burndown.work.estimated"),
          t("charts.burndown.work.actual"),
          t("charts.burndown.today"),
        ],
        top: "center",
        right: "right",
        orient: "vertical",
        textStyle: {
          color: isDark.value ? "#fff" : "#000",
        },
      },
      grid: {
        left: "15px",
        right: "15px",
        top: "15px",
        bottom: "15px",
        containLabel: true,
      },
      xAxis: [
        {
          type: "time",
          axisPointer: {
            type: "shadow",
          },
          boundaryGap: false,
          textStyle: {
            color: isDark.value ? "#fff" : "#000",
          },
        },
      ],
      yAxis: [
        {
          type: "value",
          name: "Hours",
          min: 0,
          scale: true,
          axisLabel: {
            formatter: "{value} hr",
          },
          textStyle: {
            color: isDark.value ? "#fff" : "#000",
          },
        },
      ],
      series: [
        {
          name: t("charts.burndown.remaining.ideal"),
          type: "line",
          color: "#00c875",
          tooltip: {
            valueFormatter: function (value) {
              return value + " hr";
            },
          },
          data: burndownRemainingIdeal.value,
          markArea: {
            silent: true,
            data: [
              {
                xAxis: todayAsMs.value,
              },
              {
                xAxis: todayAsMs.value + 86400000,
              },
            ],
            itemStyle: {
              color: "rgba(255, 203, 0, 0.5)",
            },
          },
        },
        {
          name: t("charts.burndown.remaining.actual"),
          type: "line",
          color: "#df2f4a",
          tooltip: {
            valueFormatter: function (value) {
              return value + " hr";
            },
          },
          data: burndownRemainingActual.value,
        },
        {
          name: t("charts.burndown.work.estimated"),
          type: "bar",
          color: "#e484bd",
          tooltip: {
            valueFormatter: function (value) {
              return value + " hr";
            },
          },
          data: burndownWorkEstimated.value,
        },
        {
          name: t("charts.burndown.work.actual"),
          type: "bar",
          color: "#9d99b9",
          tooltip: {
            valueFormatter: function (value) {
              return value + " hr";
            },
          },
          data: burndownWorkActual.value,
        },
      ],
    }));
    const loadingOptions = computed(() => ({
      text: t("charts.burndown.loading"),
      color: "#00854d",
      textColor: isDark.value ? "#fff" : "#000",
      maskColor: isDark.value
        ? "rgba(24, 27, 52, 0.8)"
        : "rgba(255, 255, 255, 0.8)",
    }));
    const loading = computed(() => loadBurndown.loading.value);
    watch(
      () => sprint.value,
      () => loadBurndown.call(),
      { immediate: true, deep: true },
    );
    onMounted(() => {
      if (cron) {
        cron.$on("* * * * *", updateToday);
      }
    });
    onBeforeUnmount(() => {
      if (abortController) {
        abortController.abort();
      }
      if (cron) {
        cron.$off("* * * * *", updateToday);
      }
    });
    return {
      option,
      loading,
      systemAccentColor,
      loadBurndown: () => loadBurndown.call(),
      isDark,
      loadingOptions,
    };
  },
});
</script>

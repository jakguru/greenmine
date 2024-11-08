<template>
  <v-card :height="height" variant="outlined" class="position-relative">
    <v-label class="ms-3 position-absolute" style="z-index: 3">{{
      $t("charts.capacity.title")
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
import { defineComponent, computed } from "vue";
import { use } from "echarts/core";
import { HeatmapChart } from "echarts/charts";
import {
  TooltipComponent,
  GridComponent,
  VisualMapComponent,
} from "echarts/components";
import { CanvasRenderer } from "echarts/renderers";
import { useI18n } from "vue-i18n";
import { useSystemAccentColor, useIsDark } from "@/utils/app";
import { formatShortDuration } from "@/utils/formatting";
import { DateTime } from "luxon";
import VChart from "vue-echarts";

import type { PropType } from "vue";
import type { ComposeOption } from "echarts/core";
import type { HeatmapSeriesOption } from "echarts/charts";
import type {
  TooltipComponentOption,
  GridComponentOption,
  VisualMapComponentOption,
} from "echarts/components";
import type { Sprint, WorkloadAllocation } from "@/friday";

use([
  TooltipComponent,
  GridComponent,
  VisualMapComponent,
  HeatmapChart,
  CanvasRenderer,
]);

type EChartsOption = ComposeOption<
  | TooltipComponentOption
  | GridComponentOption
  | VisualMapComponentOption
  | HeatmapSeriesOption
>;

export default defineComponent({
  name: "SprintCapacity",
  components: {
    VChart,
  },
  props: {
    sprint: {
      type: Object as PropType<Sprint>,
      required: true,
    },
    workload: {
      type: Array as PropType<WorkloadAllocation[]>,
      required: true,
    },
    loading: {
      type: Boolean,
      default: false,
    },
  },
  setup(props) {
    const { t } = useI18n({ useScope: "global" });
    const workload = computed(() => props.workload);
    const systemAccentColor = useSystemAccentColor();
    const isDark = useIsDark();
    const seriesData = computed(() => {
      const dateValues: Set<string> = new Set();
      const keys: string[] = [];
      const data: [string, number, number | "-"][] = [];
      workload.value.forEach((uwl) => {
        const key = [uwl.user.firstname, uwl.user.lastname]
          .filter((v) => "string" === typeof v)
          .map((v) => v.trim())
          .filter((v) => v.length > 0)
          .join(" ")
          .trim();
        keys.push(key);
        const indexOfKey = keys.indexOf(key);
        Object.keys(uwl.daily_breakdown).map((date: string) => {
          const dt = DateTime.fromISO(date);
          const dtd = dt.toUTC().toLocaleString(DateTime.DATE_MED);
          dateValues.add(dtd);
          data.push([
            dtd,
            indexOfKey,
            0 === uwl.daily_breakdown[date].remaining_capacity
              ? "-"
              : uwl.daily_breakdown[date].remaining_capacity,
          ]);
        });
      });
      const dates: string[] = [...dateValues];
      const seriesData = data.map((d) => {
        return [dates.indexOf(d[0]), d[1], d[2]];
      });
      return { dates, keys, data: seriesData };
    });
    const option = computed<EChartsOption>(() => ({
      useUTC: true,
      darkMode: isDark.value,
      backgroundColor: "transparent",
      tooltip: {
        position: "top",
        valueFormatter: (value) => formatShortDuration(Number(value)),
      },
      grid: {
        left: "150px",
        right: "15px",
        top: "30px",
        bottom: "90px",
        containLabel: false,
      },
      xAxis: [
        {
          type: "category",
          data: seriesData.value.dates,
          axisPointer: {
            type: "shadow",
          },
          boundaryGap: true,
          textStyle: {
            color: isDark.value ? "#fff" : "#000",
          },
          splitArea: {
            show: true,
          },
          axisLabel: {
            rotate: 90,
            hideOverlap: true,
          },
        },
      ],
      yAxis: [
        {
          type: "category",
          data: seriesData.value.keys,
          textStyle: {
            color: isDark.value ? "#fff" : "#000",
          },
          splitArea: {
            show: true,
          },
          axisLabel: {
            width: 150,
            overflow: "truncate",
          },
        },
      ],
      visualMap: {
        show: false,
        min: 0,
        max: 7,
        formatter: (value) => formatShortDuration(Number(value)),
        inRange: {
          color: [
            "#D9534F",
            "#D9534F",
            "#D9534F",
            "#F0AD4E",
            "#F0AD4E",
            "#5BC0DE",
            "#5BC0DE",
            "#00854d",
          ],
        },
        outOfRange: {
          color: ["#D9534F"],
        },
      },
      series: [
        {
          name: t("charts.capacity.title"),
          type: "heatmap",
          data: seriesData.value.data,
          label: {
            show: false,
            formatter: (params) => {
              return Array.isArray(params.value) &&
                "number" === typeof params.value[2]
                ? formatShortDuration(params.value[2])
                : "";
            },
          },
        },
      ],
    }));
    const loadingOptions = computed(() => ({
      text: t("charts.capacity.loading"),
      color: "#00854d",
      textColor: isDark.value ? "#fff" : "#000",
      maskColor: isDark.value
        ? "rgba(24, 27, 52, 0.8)"
        : "rgba(255, 255, 255, 0.8)",
    }));
    const height = computed(() => workload.value.length * 30 + 120);
    return {
      option,
      systemAccentColor,
      isDark,
      loadingOptions,
      height,
    };
  },
});
</script>

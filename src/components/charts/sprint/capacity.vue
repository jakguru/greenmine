<template>
  <v-card :height="height" variant="outlined" class="position-relative">
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
import { TooltipComponent, GridComponent } from "echarts/components";
import { SVGRenderer } from "echarts/renderers";
import { useI18n } from "vue-i18n";
import { useSystemAccentColor, useIsDark } from "@/utils/app";
import { DateTime } from "luxon";
import VChart from "vue-echarts";

import type { PropType } from "vue";
import type { ComposeOption } from "echarts/core";
import type { HeatmapSeriesOption } from "echarts/charts";
import type {
  TooltipComponentOption,
  GridComponentOption,
} from "echarts/components";
import type { Sprint, WorkloadAllocation } from "@/friday";

use([TooltipComponent, GridComponent, HeatmapChart, SVGRenderer]);

type EChartsOption = ComposeOption<
  TooltipComponentOption | GridComponentOption | HeatmapSeriesOption
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
      const dates: string[] = [];
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
          dates.push(dtd);
          data.push([
            dtd,
            indexOfKey,
            0 === uwl.daily_breakdown[date].remaining_capacity
              ? "-"
              : uwl.daily_breakdown[date].remaining_capacity,
          ]);
        });
      });
      return { dates, keys, data };
    });
    const option = computed<EChartsOption>(() => ({
      useUTC: true,
      darkMode: isDark.value,
      backgroundColor: "transparent",
      tooltip: {
        position: "top",
      },
      grid: {
        left: "15px",
        right: "15px",
        top: "10%",
        bottom: "15px",
        containLabel: true,
      },
      xAxis: [
        {
          type: "category",
          values: seriesData.value.dates,
          axisPointer: {
            type: "shadow",
          },
          boundaryGap: false,
          textStyle: {
            color: isDark.value ? "#fff" : "#000",
          },
          splitArea: {
            show: true,
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
        },
      ],
      series: [
        {
          name: t("charts.capacity.title"),
          type: "heatmap",
          data: seriesData.value.data,
          label: {
            show: true,
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
    const height = computed(() => workload.value.length * 30 + 100);
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

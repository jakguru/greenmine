<template>
  <BaseChart
    :do-load="doLoad"
    :wrapper-props="wrapperProps"
    :option="option"
    :loading="loading"
    :loading-options="loadingOptions"
    :theme="theme"
    :filter-dialog-bindings="filterDialogBindings"
    :open-filter-dialog="openFilterDialog"
    :close-filter-dialog="closeFilterDialog"
  >
  </BaseChart>
</template>

<script lang="ts">
import { defineComponent, ref } from "vue";
import { useChartSetup, BaseChart } from "@/components/charts/common";

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
  name: "IssuesByTrackerChart",
  components: {
    BaseChart,
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
    minDateTime: {
      type: String,
      required: true,
    },
  },
  setup(props) {
    const filters = ref<Record<string, any>>({
      from: null,
      to: null,
    });
    return useChartSetup<EChartsOption>(props, filters, {
      tooltip: {
        trigger: "axis",
        axisPointer: {
          type: "line",
          lineStyle: {
            color: "rgba(0,0,0,0.2)",
            width: 1,
            type: "solid",
          },
        },
      },
      singleAxis: {
        top: 50,
        bottom: 50,
        axisTick: {},
        axisLabel: {},
        type: "time",
        axisPointer: {
          animation: true,
          label: {
            show: true,
          },
        },
        splitLine: {
          show: true,
          lineStyle: {
            type: "dashed",
            opacity: 0.2,
          },
        },
      },
      series: [
        {
          type: "themeRiver",
          emphasis: {
            itemStyle: {
              shadowBlur: 20,
              shadowColor: "rgba(0, 0, 0, 0.8)",
            },
          },
        },
      ],
    });
  },
});
</script>

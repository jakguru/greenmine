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
import { defineComponent, ref, computed } from "vue";
import { useChartSetup, BaseChart } from "@/components/charts/common";
import { DateTime } from "luxon";

import { use } from "echarts/core";
import { HeatmapChart } from "echarts/charts";
import {
  VisualMapComponent,
  CalendarComponent,
  ToolboxComponent,
} from "echarts/components";
import { SVGRenderer } from "echarts/renderers";

import type { PropType } from "vue";

import type { ComposeOption } from "echarts/core";
import type { HeatmapSeriesOption } from "echarts/charts";
import type {
  VisualMapComponentOption,
  CalendarComponentOption,
  ToolboxComponentOption,
} from "echarts/components";

type EChartsOption = ComposeOption<
  | VisualMapComponentOption
  | CalendarComponentOption
  | HeatmapSeriesOption
  | ToolboxComponentOption
>;

use([
  VisualMapComponent,
  CalendarComponent,
  ToolboxComponent,
  HeatmapChart,
  SVGRenderer,
]);

export default defineComponent({
  name: "ActivitySummaryChart",
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
    const calendarRange = computed(() => [
      filters.value.from || DateTime.now().minus({ months: 3 }).toSQLDate(),
      filters.value.to || DateTime.now().toSQLDate(),
    ]);
    return useChartSetup<EChartsOption>(props, filters, {
      visualMap: {
        show: false,
        min: 0,
        max: 10000,
      },
      calendar: {
        range: calendarRange.value,
        cellSize: "auto",
      },
      series: {
        type: "heatmap",
        coordinateSystem: "calendar",
      },
    });
  },
});
</script>

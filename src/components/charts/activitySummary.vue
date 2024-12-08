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
    :min-date="minDate"
    :max-date="maxDate"
  >
    <template #filters="{ loading, minDate, maxDate }">
      <v-row>
        <v-col cols="12">
          <v-text-field
            v-model="filters.from"
            :label="$t('labels.from')"
            type="date"
            hide-details
            density="compact"
            :disabled="loading"
            :clearable="!loading"
            :min="minDate"
            :max="maxDate"
          />
        </v-col>
        <v-col cols="12">
          <v-text-field
            v-model="filters.to"
            :label="$t('labels.to')"
            type="date"
            hide-details
            density="compact"
            :disabled="loading"
            :clearable="!loading"
            :min="minDate"
            :max="maxDate"
          />
        </v-col>
      </v-row>
    </template>
  </BaseChart>
</template>

<script lang="ts">
import { defineComponent, ref, computed } from "vue";
import {
  useChartSetup,
  BaseChart,
  calendarChartDataSchema,
} from "@/components/charts/common";
import { DateTime } from "luxon";

import { use } from "echarts/core";
import { HeatmapChart } from "echarts/charts";
import {
  TooltipComponent,
  VisualMapComponent,
  CalendarComponent,
  ToolboxComponent,
} from "echarts/components";
import { SVGRenderer } from "echarts/renderers";

import type { PropType } from "vue";

import type { ComposeOption } from "echarts/core";
import type { HeatmapSeriesOption } from "echarts/charts";
import type {
  TooltipComponentOption,
  VisualMapComponentOption,
  CalendarComponentOption,
  ToolboxComponentOption,
} from "echarts/components";

type EChartsOption = ComposeOption<
  | TooltipComponentOption
  | VisualMapComponentOption
  | CalendarComponentOption
  | HeatmapSeriesOption
  | ToolboxComponentOption
>;

use([
  TooltipComponent,
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
    return useChartSetup<EChartsOption>(
      props,
      filters,
      {
        tooltip: {},
        calendar: {
          range: calendarRange.value,
          cellSize: "auto",
          splitLine: {
            show: false,
          },
        },
      },
      calendarChartDataSchema,
    );
  },
});
</script>

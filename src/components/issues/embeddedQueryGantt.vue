<template>
  <v-container fluid>
    <slot name="before" />
    <v-toolbar color="transparent">
      <v-slide-group show-arrows class="mx-2">
        <v-slide-group-item v-if="showFiltersMenu">
          <QueriesPartialFilters
            v-model:model-value="value"
            :dirty="dirty"
            :submitting="submitting"
            @submit="onSubmit"
          />
        </v-slide-group-item>
        <v-slide-group-item v-if="showColumnsMenu">
          <QueriesPartialColumns
            v-model:model-value="value"
            :dirty="dirty"
            :submitting="submitting"
            @submit="onSubmit"
          />
        </v-slide-group-item>
        <v-slide-group-item v-if="showSortingMenu">
          <QueriesPartialSorting
            v-model:model-value="value"
            :dirty="dirty"
            :submitting="submitting"
            @submit="onSubmit"
          />
        </v-slide-group-item>
        <v-slide-group-item v-if="showGroupingsMenu">
          <QueriesPartialGroupings
            v-model:model-value="value"
            :dirty="dirty"
            :submitting="submitting"
            @submit="onSubmit"
          />
        </v-slide-group-item>
        <v-slide-group-item v-if="showAdditional">
          <QueriesPartialOptions
            v-model:model-value="value"
            :dirty="dirty"
            :submitting="submitting"
            @submit="onSubmit"
          />
        </v-slide-group-item>
        <v-slide-group-item>
          <v-btn
            variant="elevated"
            :color="accentColor"
            size="x-small"
            class="ma-2"
            type="submit"
            height="24px"
            :disabled="!dirty"
            :loading="submitting"
            style="position: relative; top: 1px"
          >
            <v-icon class="me-2">mdi-check</v-icon>
            {{ $t("labels.apply") }}
          </v-btn>
        </v-slide-group-item>
        <v-slide-group-item>
          <v-btn
            variant="elevated"
            :color="accentColor"
            size="x-small"
            class="ma-2"
            type="button"
            height="24px"
            :loading="submitting"
            :disabled="!dirty"
            style="position: relative; top: 1px"
            @click="onReset"
          >
            <v-icon class="me-2">mdi-restore</v-icon>
            {{ $t("labels.reset") }}
          </v-btn>
        </v-slide-group-item>
        <v-slide-group-item>
          <v-btn
            variant="elevated"
            :color="accentColor"
            size="x-small"
            class="ma-2"
            type="button"
            height="24px"
            :loading="submitting"
            style="position: relative; top: 1px"
            @click="onRefresh"
          >
            <v-icon class="me-2">mdi-refresh</v-icon>
            {{ $t("labels.refresh") }}
          </v-btn>
        </v-slide-group-item>
      </v-slide-group>
    </v-toolbar>
    <v-sheet
      id="gantt-chart"
      color="transparent"
      class="w-100 px-3"
      @contextmenu="onContextMenu"
    >
      <HighChart
        :key="chartKey"
        ref="chart"
        constructor-type="ganttChart"
        :options="chartOptions"
        deep-copy-on-update
        :callback="onChartLoaded"
      />
    </v-sheet>
  </v-container>
</template>

<script lang="ts">
import { defineComponent, computed, inject, ref, watch } from "vue";
import { useI18n } from "vue-i18n";
import { useRoute, useRouter } from "vue-router";
import { makeNewQueryPayloadFromQueryAndQueryGanttPayload } from "@/friday";
import {
  useSystemAccentColor,
  cloneObject,
  checkObjectEquality,
  loadRouteData,
  useIsDark,
} from "@/utils/app";
import {
  QueriesPartialFilters,
  QueriesPartialColumns,
  QueriesPartialSorting,
  QueriesPartialGroupings,
  QueriesPartialOptions,
} from "@/components/queries/partials";
import { useRouteDataStore } from "@/stores/routeData";
import { useGetActionMenuItems } from "@/components/queries/utils/issues";
import { Chart as HighChart } from "highcharts-vue";

import Highcharts from "highcharts";
import ganttInit from "highcharts/modules/gantt";

ganttInit(Highcharts);

import type { PropType } from "vue";
import type { ToastService, ApiService } from "@jakguru/vueprint";

import type {
  QueryResponseGanttPayload,
  QueryData,
  QueryResponseGantt,
} from "@/friday";

import type { Chart } from "highcharts";

export default defineComponent({
  name: "EmbeddedIssueQueryGantt",
  components: {
    QueriesPartialFilters,
    QueriesPartialColumns,
    QueriesPartialSorting,
    QueriesPartialGroupings,
    QueriesPartialOptions,
    HighChart,
  },
  props: {
    issues: {
      type: Object as PropType<QueryResponseGantt>,
      required: true,
    },
  },
  setup(props) {
    const toast = inject<ToastService>("toast");
    const api = inject<ApiService>("api");
    const route = useRoute();
    const router = useRouter();
    const { t } = useI18n({ useScope: "global" });
    const issues = computed(() => props.issues);
    const query = computed(() => issues.value.query);
    const value = ref<QueryData>(cloneObject(query.value));
    const payload = computed(() => issues.value.payload);
    const payloadValue = ref<QueryResponseGanttPayload>(
      cloneObject(payload.value),
    );
    const dirty = computed(
      () =>
        !checkObjectEquality(value.value, query.value) ||
        !checkObjectEquality(payloadValue.value, payload.value),
    );
    watch(
      () => query.value,
      (v) => {
        value.value = cloneObject(v);
      },
      { immediate: true, deep: true },
    );
    watch(
      () => payload.value,
      (v) => {
        payloadValue.value = cloneObject(v);
      },
      { immediate: true, deep: true },
    );
    const onReset = () => {
      value.value = cloneObject(query.value);
    };
    const submitting = ref(false);
    const onSubmit = (e?: Event) => {
      if (e) {
        e.preventDefault();
        e.stopPropagation();
      }
      if (submitting.value) {
        return;
      }
      const payload = makeNewQueryPayloadFromQueryAndQueryGanttPayload(
        value.value,
        payloadValue.value,
      );
      submitting.value = true;
      router
        // @ts-expect-error the query object's type is correct, but the router's type is not
        .push({ ...route, query: { ...route.query, ...payload } })
        .catch((e) => {
          console.warn(e);
          // noop
        })
        .finally(() => {
          submitting.value = false;
        });
    };
    const routeDataStore = useRouteDataStore();
    const onRefresh = async (e?: Event) => {
      if (e) {
        e.preventDefault();
        e.stopPropagation();
      }
      if (submitting.value) {
        return;
      }
      submitting.value = true;
      try {
        const d = await loadRouteData(route, api, toast);
        value.value = d.query;
        payloadValue.value = d.payload;
        routeDataStore.set(d);
        routeDataStore.store(d);
      } catch {
        // noop
      }
      submitting.value = false;
    };
    const showFiltersMenu = computed(() => {
      return Object.keys(query.value.filters.available).length > 0;
    });
    const showColumnsMenu = computed(() => {
      return (
        query.value.display.current === "list" &&
        query.value.columns.available.inline.length > 0
      );
    });
    const showSortingMenu = computed(() => {
      // return (
      //   query.value.columns.available.sortable &&
      //   query.value.columns.available.sortable.length > 0
      // );
      return false;
    });
    const showGroupingsMenu = computed(() => {
      return query.value.columns.available.groupable.length > 0;
    });
    // const showBlockable = computed(() => {
    //   return query.value.columns.available.block.length > 0;
    // });
    // const showTotalable = computed(() => {
    //   return query.value.columns.available.totalable.length > 0;
    // });
    const showAdditional = computed(() => {
      // return showBlockable.value || showTotalable.value;
      return false;
    });
    router.afterEach(() => {
      submitting.value = false;
    });
    const getActionMenuItems = useGetActionMenuItems(api, toast, t);
    const accentColor = useSystemAccentColor();
    const isDark = useIsDark();
    const chartKey = computed(() =>
      isDark.value ? "dark-chart" : "light-chart",
    );
    const onChartLoaded = (chart: Chart) => {
      if (submitting.value) {
        chart.showLoading(t("labels.loading"));
      } else {
        chart.hideLoading();
      }
    };
    const onPointClick = (point: Highcharts.Point) => {
      console.log(point);
      alert("Point clicked");
    };
    const minTimeStamp = computed(() => {
      return Math.min(
        ...payload.value.items
          .map((item) => item.data.map((d) => d.start).filter((v) => v))
          .flat()
          .filter((v) => v !== null),
      );
    });
    const maxTimeStamp = computed(() => {
      return Math.max(
        ...payload.value.items
          .map((item) => item.data.map((d) => d.end).filter((v) => v))
          .flat()
          .filter((v) => v !== null),
      );
    });
    const chartOptions = computed(() => ({
      accessibility: {
        enabled: false,
      },
      chart: {
        backgroundColor: "transparent",
        type: "gantt",
        style: {
          ...(isDark.value ? {} : {}),
          color:
            "rgba(var(--v-theme-on-surface), var(--v-high-emphasis-opacity))",
        },
        spacing: [0, 0, 0, 0],
        // height: 500,
        // scrollablePlotArea: {
        //   minHeight: 500,
        // },
      },
      credits: {
        enabled: false,
      },
      xAxis: [
        {
          currentDateIndicator: {
            color: "#2caffe",
            dashStyle: "ShortDot" as const,
            width: 2,
            label: {
              format: "",
            },
          },
          dateTimeLabelFormats: {
            day: '%e<br><span style="opacity: 0.5; font-size: 0.7em">%a</span>',
          },
          grid: {
            borderWidth: 0,
          },
          gridLineWidth: 1,
          custom: {
            weekendPlotBands: true,
          },
          labels: {
            style: {
              ...(isDark.value ? {} : {}),
              color:
                "rgba(var(--v-theme-on-surface), var(--v-high-emphasis-opacity))",
            },
          },
          min: minTimeStamp.value - 7 * 24 * 60 * 60 * 1000,
          max: maxTimeStamp.value + 7 * 24 * 60 * 60 * 1000,
        },
        {
          grid: {
            borderWidth: 0,
          },
          labels: {
            style: {
              ...(isDark.value ? {} : {}),
              color:
                "rgba(var(--v-theme-on-surface), var(--v-high-emphasis-opacity))",
            },
          },
        },
      ],
      yAxis: [
        {
          grid: {
            borderWidth: 0,
          },
          gridLineWidth: 0,
          labels: {
            symbol: {
              width: 8,
              height: 6,
              x: -4,
              y: -2,
            },
            style: {
              ...(isDark.value ? {} : {}),
              color:
                "rgba(var(--v-theme-on-surface), var(--v-high-emphasis-opacity))",
            },
          },
          staticScale: 30,
          events: {},
        },
      ],
      series: [...payload.value.items].map(
        (series: Highcharts.SeriesGanttOptions) => {
          return {
            ...series,
            events: {
              click: (e: Highcharts.SeriesClickEventObject) => {
                if (e.point) {
                  onPointClick(e.point);
                }
              },
            },
          };
        },
      ),
      scrollbar: {
        enabled: true,
      },
      navigator: {
        enabled: true,
        liveRedraw: true,
        series: {
          type: "gantt",
          pointPlacement: 0.5,
          pointPadding: 0.25,
          accessibility: {
            enabled: false,
          },
        },
        yAxis: {
          min: 0,
          max: 3,
          reversed: true,
          categories: [],
        },
      },
      plotOptions: {
        series: {
          // connectors: {
          //   dashStyle: "ShortDot",
          //   lineWidth: 2,
          //   radius: 5,
          //   startMarker: {
          //     enabled: false,
          //   },
          // },
          // groupPadding: 0,
          dataLabels: [
            // {
            //   enabled: true,
            //   align: "left",
            //   format: "{point.name}",
            //   padding: 10,
            //   style: {
            //     fontWeight: "normal",
            //     textOutline: "none",
            //   },
            // },
            {
              crop: true,
              overflow: "allow" as const,
              inside: true,
              enabled: true,
              align: "right" as const,
              verticalAlign: "middle" as const,
              format:
                "{#if point.completed}{(multiply " +
                "point.completed.amount 100):.0f}%{/if}",
              padding: 10,
              style: {
                fontWeight: "normal",
                textOutline: "none",
                opacity: 1,
                color:
                  "rgba(var(--v-theme-on-surface), var(--v-high-emphasis-opacity))",
              },
            },
          ],
        },
      },
      time: {
        useUTC: true,
      },
      rangeSelector: {
        enabled: true,
        selected: 0,
        buttons: [
          {
            type: "week" as const,
            count: 2,
            text: "2w",
            title: t("labels.rangeSelector.2w"),
          },
          {
            type: "month" as const,
            count: 1,
            text: "1m",
            title: t("labels.rangeSelector.1m"),
          },
          {
            type: "month" as const,
            count: 3,
            text: "3m",
            title: t("labels.rangeSelector.3m"),
          },
          {
            type: "month" as const,
            count: 6,
            text: "6m",
            title: t("labels.rangeSelector.6m"),
          },
          {
            type: "ytd" as const,
            text: "YTD",
            title: t("labels.rangeSelector.YTD"),
          },
          {
            type: "year" as const,
            count: 1,
            text: "1y",
            title: t("labels.rangeSelector.1y"),
          },
          {
            type: "all" as const,
            text: "All",
            title: t("labels.rangeSelector.All"),
          },
        ],
        buttonTheme: {
          fill: "transparent",
          style: {
            color:
              "rgba(var(--v-theme-on-surface), var(--v-medium-emphasis-opacity))",
          },
          states: {
            disabled: {
              fill: "transparent",
              style: {
                color:
                  "rgba(var(--v-theme-on-surface), var(--v-disabled-opacity))",
              },
            },
            hover: {
              fill: "transparent",
              style: {
                color:
                  "rgba(var(--v-theme-on-surface), var(--v-high-emphasis-opacity))",
              },
            },
            select: {
              fill: "transparent",
              style: {
                color:
                  "rgba(var(--v-theme-on-surface), var(--v-high-emphasis-opacity))",
                textDecoration: "underline",
              },
            },
          },
        },
        labelStyle: {
          color: "rgba(var(--v-theme-accent), 1)",
          fontWeight: "bold",
        },
        inputEnabled: false,
        buttonPosition: {
          align: "right" as const,
        },
      },
    }));
    const chart = ref<typeof HighChart | null>(null);
    watch(
      () => submitting.value,
      (is: boolean) => {
        if (chart.value && chart.value.chart) {
          if (is) {
            chart.value.chart.showLoading(t("labels.loading"));
          } else {
            chart.value.chart.hideLoading();
          }
        }
      },
      { immediate: true },
    );
    const onContextMenu = (e: MouseEvent) => {
      e.preventDefault();
      e.stopPropagation();
      e.stopImmediatePropagation();
      if (chart.value && chart.value.chart) {
        if (chart.value.chart.hoverPoint) {
          onPointClick(chart.value.chart.hoverPoint);
        }
      }
      return false;
    };
    return {
      accentColor,
      value,
      dirty,
      submitting,
      onSubmit,
      onReset,
      onRefresh,
      query,
      payload,
      payloadValue,
      showFiltersMenu,
      showColumnsMenu,
      showSortingMenu,
      showGroupingsMenu,
      showAdditional,

      getActionMenuItems,
      chartOptions,
      chart,
      chartKey,
      onChartLoaded,
      onContextMenu,
    };
  },
});
</script>

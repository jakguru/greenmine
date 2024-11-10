<template>
  <v-container fluid>
    <v-card min-height="100" color="surface">
      <v-sheet
        ref="form"
        color="transparent"
        tag="form"
        method="get"
        :action="$route.path"
        @submit="onSubmit"
      >
        <v-toolbar color="transparent" density="compact">
          <v-toolbar-title class="font-weight-bold" tag="h1">
            {{ title }}
          </v-toolbar-title>
        </v-toolbar>
        <v-toolbar tag="nav" color="transparent" density="compact">
          <QueriesTabs :query="query" :queries="queries" />
          <slot name="tabs" />
        </v-toolbar>
        <v-divider />
        <v-toolbar color="transparent">
          <v-slide-group show-arrows class="mx-2">
            <v-slide-group-item>
              <v-btn-group
                v-if="creatable.length > 0"
                divided
                base-color="accent"
                density="compact"
                class="ma-2"
                style="height: 24px"
              >
                <v-btn :to="mainCreateable.url" size="x-small">
                  {{ mainCreateable.title }}
                </v-btn>
                <v-menu v-if="additionalCreatable.length > 0">
                  <template #activator="{ props }">
                    <v-btn v-bind="props" icon="mdi-menu-down" size="x-small" />
                  </template>
                  <v-card :color="surfaceColor">
                    <v-list-item
                      v-for="(c, i) in additionalCreatable"
                      :key="`creatable-${i}`"
                      :title="c.title"
                      :to="c.url"
                    />
                  </v-card>
                </v-menu>
              </v-btn-group>
            </v-slide-group-item>
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
      </v-sheet>
      <v-sheet color="transparent" class="py-3">
        <QueriesPartialDataTable
          v-model:model-value="value"
          v-model:payload-value="payloadValue"
          :query="query"
          :payload="payload"
          :submitting="submitting"
          :dirty="dirty"
          :get-action-items="getActionItems"
          @submit="onSubmit"
        >
          <template #before-top>
            <slot name="before-top" />
          </template>
          <template #after-top>
            <slot name="after-top" />
          </template>
        </QueriesPartialDataTable>
      </v-sheet>
    </v-card>
  </v-container>
</template>

<script lang="ts">
import { defineComponent, computed, ref, watch, inject } from "vue";
import {
  useSystemSurfaceColor,
  useSystemAccentColor,
  loadRouteData,
  cloneObject,
  checkObjectEquality,
} from "@/utils/app";
import { makeNewQueryPayloadFromQueryAndQueryPayload } from "@/friday";
import { useRouter, useRoute } from "vue-router";
import QueriesTabs from "./tabs.vue";
import {
  QueriesPartialFilters,
  QueriesPartialColumns,
  QueriesPartialSorting,
  QueriesPartialGroupings,
  QueriesPartialOptions,
  QueriesPartialDataTable,
} from "./partials";
import { useRouteDataStore } from "@/stores/routeData";
import type { PropType } from "vue";
import type {
  ApiService,
  ToastService,
  BusService,
  BusEventCallbackSignatures,
} from "@jakguru/vueprint";
import type {
  QueryResponseParams,
  QueryResponsePayload,
  QueryData,
  DefinedQuery,
  Permissions,
  Createable,
} from "@/friday";
import type { RealtimeModelEventPayload } from "@/utils/realtime";
import type { GetActionItemsMethod } from "./partials/action-menu";

export default defineComponent({
  name: "QueriesPage",
  components: {
    QueriesTabs,
    QueriesPartialFilters,
    QueriesPartialColumns,
    QueriesPartialSorting,
    QueriesPartialGroupings,
    QueriesPartialOptions,
    QueriesPartialDataTable,
  },
  props: {
    title: {
      type: String,
      required: true,
    },
    params: {
      type: Object as PropType<QueryResponseParams>,
      required: true,
    },
    payload: {
      type: Object as PropType<QueryResponsePayload>,
      required: true,
    },
    query: {
      type: Object as PropType<QueryData>,
      required: true,
    },
    queries: {
      type: Array as PropType<Array<DefinedQuery>>,
      required: true,
    },
    permissions: {
      type: Object as PropType<Permissions>,
      required: true,
    },
    creatable: {
      type: Array as PropType<Array<Createable>>,
      required: true,
    },
    modelRealtimeUpdateKey: {
      type: String as PropType<keyof BusEventCallbackSignatures | undefined>,
      default: undefined,
    },
    getActionItems: {
      type: Function as PropType<GetActionItemsMethod | undefined>,
      default: undefined,
    },
  },
  setup(props) {
    const router = useRouter();
    const route = useRoute();
    const api = inject<ApiService>("api");
    const toast = inject<ToastService>("toast");
    const bus = inject<BusService>("bus");
    const query = computed(() => props.query);
    const modelRealtimeUpdateKey = computed(() => props.modelRealtimeUpdateKey);
    const value = ref<QueryData>(cloneObject(query.value));
    const payload = computed(() => props.payload);
    const payloadValue = ref<QueryResponsePayload>(cloneObject(payload.value));
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
    const createable = computed(() => {
      return props.creatable;
    });
    const mainCreateable = computed(() => [...createable.value][0]);
    const additionalCreatable = computed(() =>
      [...createable.value].filter((c) => c !== mainCreateable.value),
    );
    const surfaceColor = useSystemSurfaceColor();
    const accentColor = useSystemAccentColor();
    const submitting = ref(false);
    const onSubmit = (e?: Event) => {
      if (e) {
        e.preventDefault();
        e.stopPropagation();
      }
      if (submitting.value) {
        return;
      }
      const payload = makeNewQueryPayloadFromQueryAndQueryPayload(
        value.value,
        payloadValue.value,
      );
      submitting.value = true;
      router
        // @ts-expect-error the query object's type is correct, but the router's type is not
        .push({ ...route, query: payload })
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
    const selectedFiltersCount = computed(() => {
      return Object.keys(query.value.filters.current).length;
    });
    const selectedFiltersColor = computed(() =>
      selectedFiltersCount.value > 0 ? accentColor.value : surfaceColor.value,
    );
    const showColumnsMenu = computed(() => {
      return (
        query.value.display.current === "list" &&
        query.value.columns.available.inline.length > 0
      );
    });
    const showSortingMenu = computed(() => {
      return (
        query.value.columns.available.sortable &&
        query.value.columns.available.sortable.length > 0
      );
    });
    const selectedColumnsCount = computed(() => {
      return query.value.columns.current.inline.length;
    });
    const selectedColumnsColor = computed(() =>
      selectedColumnsCount.value > 0 ? accentColor.value : surfaceColor.value,
    );
    const showGroupingsMenu = computed(() => {
      return (
        query.value.display.current === "list" &&
        query.value.columns.available.groupable.length > 0
      );
    });
    const selectedGroupingsCount = computed(() => {
      return query.value.columns.current.groupable.length;
    });
    const selectedGroupingsColor = computed(() =>
      selectedGroupingsCount.value > 0 ? accentColor.value : surfaceColor.value,
    );
    const showBlockable = computed(() => {
      return query.value.columns.available.block.length > 0;
    });
    const showTotalable = computed(() => {
      return query.value.columns.available.totalable.length > 0;
    });
    const showAdditional = computed(() => {
      return showBlockable.value || showTotalable.value;
    });
    router.afterEach(() => {
      submitting.value = false;
    });
    const onModelRealtimeUpdate = (incoming: RealtimeModelEventPayload) => {
      const currentEntityIds = [...payload.value.items].map((i) => i.id);
      const hasMatch = incoming.updated.some((u) =>
        currentEntityIds.includes(u),
      );
      if (hasMatch) {
        onRefresh();
      }
    };
    watch(
      () => modelRealtimeUpdateKey.value,
      (is, was) => {
        if (bus) {
          if (was) {
            bus.off(was, onModelRealtimeUpdate, { local: true });
          }
          if (is) {
            bus.on(is, onModelRealtimeUpdate, { local: true });
          }
        }
      },
      { immediate: true },
    );
    return {
      onSubmit,
      onRefresh,
      onReset,
      surfaceColor,
      accentColor,
      mainCreateable,
      additionalCreatable,
      showFiltersMenu,
      selectedFiltersCount,
      selectedFiltersColor,
      showColumnsMenu,
      showSortingMenu,
      selectedColumnsCount,
      selectedColumnsColor,
      showGroupingsMenu,
      selectedGroupingsCount,
      selectedGroupingsColor,
      value,
      payloadValue,
      dirty,
      submitting,
      showAdditional,
    };
  },
});
</script>

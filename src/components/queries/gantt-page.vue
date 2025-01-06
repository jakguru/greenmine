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
        <slot name="sub-header" />
        <v-toolbar tag="nav" color="transparent" density="compact">
          <QueriesTabs :query="query" :queries="queries" />
          <slot name="tabs" />
        </v-toolbar>
      </v-sheet>
      <EmbeddedIssueQueryGantt :issues="queryResponseGantt" />
    </v-card>
  </v-container>
</template>

<script lang="ts">
import {
  defineComponent,
  computed,
  ref,
  watch,
  inject,
  onMounted,
  onBeforeUnmount,
} from "vue";
import {
  useSystemSurfaceColor,
  useSystemAccentColor,
  loadRouteData,
  cloneObject,
  checkObjectEquality,
} from "@/utils/app";
import { EmbeddedIssueQueryGantt } from "@/components/issues";
import { makeNewQueryPayloadFromQueryAndQueryGanttPayload } from "@/friday";
import { useRouter, useRoute } from "vue-router";
import QueriesTabs from "./tabs.vue";
import { useRouteDataStore } from "@/stores/routeData";
import { TinyEmitter } from "tiny-emitter";
import type { PropType } from "vue";
import type { ApiService, ToastService } from "@jakguru/vueprint";
import type {
  QueryResponseParams,
  QueryResponseGantt,
  QueryResponseGanttPayload,
  QueryData,
  DefinedQuery,
  Permissions,
  Createable,
  Item,
} from "@/friday";
import type { GetActionItemsMethod } from "./partials/action-menu";

export default defineComponent({
  name: "QueriesPage",
  components: {
    QueriesTabs,
    EmbeddedIssueQueryGantt,
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
      type: Object as PropType<QueryResponseGanttPayload>,
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
    getActionItems: {
      type: Function as PropType<GetActionItemsMethod | undefined>,
      default: undefined,
    },
    filterToIdField: {
      type: String as PropType<string>,
      default: "id",
    },
    parentBus: {
      type: Object as PropType<TinyEmitter | undefined>,
      default: undefined,
    },
    parent: {
      type: Object as PropType<Item | undefined>,
      default: undefined,
    },
  },
  setup(props) {
    const router = useRouter();
    const route = useRoute();
    const api = inject<ApiService>("api");
    const toast = inject<ToastService>("toast");
    const query = computed(() => props.query);
    const value = ref<QueryData>(cloneObject(query.value));
    const payload = computed(() => props.payload);
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
      const payload = makeNewQueryPayloadFromQueryAndQueryGanttPayload(
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
    let parentBus: TinyEmitter | undefined;
    onMounted(() => {
      parentBus = props.parentBus;
      if (!parentBus) {
        parentBus = new TinyEmitter();
      }
      parentBus.on("submit", onSubmit);
      parentBus.on("refresh", onRefresh);
    });
    onBeforeUnmount(() => {
      if (parentBus) {
        parentBus.off("*");
      }
    });
    const queryResponseGantt = computed<QueryResponseGantt>(
      () =>
        ({
          params: props.params as QueryResponseParams,
          payload: payloadValue.value as QueryResponseGanttPayload,
          query: value.value as QueryData,
          queries: props.queries as Array<DefinedQuery>,
          permissions: props.permissions as Permissions,
          creatable: props.creatable as Array<Createable>,
        }) as QueryResponseGantt,
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
      queryResponseGantt,
    };
  },
});
</script>

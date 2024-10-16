<template>
  <v-sheet
    ref="form"
    color="transparent"
    tag="form"
    method="get"
    :action="formSubmitPath"
    @submit="onSubmit"
  >
    <QueriesTabs :query="query" :queries="queries" :options="options" />
    <v-divider />
    <v-toolbar color="transparent">
      <slot name="before-filters" />
      <v-menu v-model="showFilterMenu" :close-on-content-click="false">
        <template #activator="{ props }">
          <v-btn
            v-bind="props"
            variant="elevated"
            :color="appBarColor"
            size="small"
            class="me-2"
          >
            <v-icon class="me-2">mdi-filter</v-icon>
            {{ $t("labels.filters") }}
            <v-icon class="ms-2">{{
              showFilterMenu ? "mdi-menu-up" : "mdi-menu-down"
            }}</v-icon>
          </v-btn>
        </template>
        <QueriesPartialFilters
          v-model:value="filters"
          :options="query.filters.available"
          :permission="permission"
          :type="query.type"
          :is-applying="isApplying"
          :is-saving="isSaving"
          :is-clearing="isClearing"
          @submit="onSubmit"
          @save="onSave"
        />
      </v-menu>
      <v-menu v-model="showColumnsMenu" :close-on-content-click="false">
        <template #activator="{ props }">
          <v-btn
            v-bind="props"
            variant="elevated"
            :color="appBarColor"
            size="small"
            class="me-2"
          >
            <v-icon class="me-2">mdi-view-column</v-icon>
            {{ $t("labels.columns") }}
            <v-icon class="ms-2">{{
              showColumnsMenu ? "mdi-menu-up" : "mdi-menu-down"
            }}</v-icon>
          </v-btn>
        </template>
        <QueriesPartialColumns
          v-model:value="columns"
          :options="query.columns.available"
          :permission="permission"
          :type="query.type"
          :is-applying="isApplying"
          :is-saving="isSaving"
          :is-clearing="isClearing"
          @submit="onSubmit"
          @save="onSave"
        />
      </v-menu>
      <v-menu v-model="showGroupingMenu" :close-on-content-click="false">
        <template #activator="{ props }">
          <v-btn
            v-bind="props"
            variant="elevated"
            :color="appBarColor"
            size="small"
            class="me-2"
          >
            <v-icon class="me-2">mdi-group</v-icon>
            {{ $t("labels.groupings") }}
            <v-icon class="ms-2">{{
              showGroupingMenu ? "mdi-menu-up" : "mdi-menu-down"
            }}</v-icon>
          </v-btn>
        </template>
        <v-card color="primary" min-height="100" @submit="onSubmit" />
      </v-menu>
      <v-menu v-model="showOptionsMenu" :close-on-content-click="false">
        <template #activator="{ props }">
          <v-btn
            v-bind="props"
            variant="elevated"
            :color="appBarColor"
            size="small"
            class="me-2"
          >
            <v-icon class="me-2">mdi-cog</v-icon>
            {{ $t("labels.options") }}
            <v-icon class="ms-2">{{
              showOptionsMenu ? "mdi-menu-up" : "mdi-menu-down"
            }}</v-icon>
          </v-btn>
        </template>
        <v-card color="primary" min-height="100" @submit="onSubmit" />
      </v-menu>
      <v-btn
        variant="elevated"
        color="secondary"
        size="small"
        class="me-2"
        type="submit"
        :loading="isApplying"
      >
        <v-icon class="me-2">mdi-check</v-icon>
        {{ $t("labels.apply") }}
      </v-btn>
      <v-btn
        v-if="canClearRoute"
        variant="elevated"
        color="secondary"
        size="small"
        class="me-2"
        :to="clearedRoute"
        :exact="true"
        :loading="isClearing"
        @click="onClear"
      >
        <v-icon class="me-2">mdi-cancel</v-icon>
        {{ $t("labels.clear") }}
      </v-btn>
    </v-toolbar>
  </v-sheet>
</template>

<script lang="ts">
import { defineComponent, ref, computed, watch } from "vue";
import { appDebug, useSystemAppBarColor } from "@/utils/app";
import { useRoute, useRouter } from "vue-router";
import { QueriesPartialFilters, QueriesPartialColumns } from "./partials";
import QueriesTabs from "./tabs.vue";

import type {
  ModelQuery,
  QueriesQuery,
  QueryOptions,
  QueryPermissions,
  QueryFilterRaw,
} from "@/redmine";
import type { PropType } from "vue";

export default defineComponent({
  name: "QueriesForm",
  components: {
    QueriesTabs,
    QueriesPartialFilters,
    QueriesPartialColumns,
  },
  props: {
    query: {
      type: Object as PropType<ModelQuery>,
      required: true,
    },
    queries: {
      type: Array as PropType<Array<QueriesQuery>>,
      required: true,
    },
    showDefault: {
      type: Boolean,
      default: true,
    },
    defaultName: {
      type: String as PropType<string | undefined>,
      default: undefined,
    },
    options: {
      type: Object as PropType<QueryOptions>,
      required: true,
    },
    permission: {
      type: Object as PropType<QueryPermissions["query"]>,
      required: true,
    },
  },
  setup(props) {
    const route = useRoute();
    const router = useRouter();
    const appBarColor = useSystemAppBarColor();
    const form = ref<HTMLFormElement | null>(null);
    const showFilterMenu = ref(false);
    const showColumnsMenu = ref(false);
    const showGroupingMenu = ref(false);
    const showOptionsMenu = ref(false);
    const clearedRoute = computed(() => ({ ...route, query: {} }));
    const canClearRoute = computed(() => {
      return (
        "object" === typeof route.query &&
        null !== route.query &&
        Object.keys(route.query).length > 0
      );
    });
    const formSubmitPath = computed(() => route.path);
    const query = computed(() => props.query);
    const displayType = ref<string>(props.query.options.display_type as string);
    const columns = ref<Array<string>>(
      props.query.columns.current.map((c) => c.name),
    );
    const filters = ref<QueryFilterRaw>(props.query.filters.current);
    watch(
      () => query.value,
      (q) => {
        displayType.value = q.options.display_type as string;
        columns.value = q.columns.current.map((c) => c.name);
        filters.value = q.filters.current;
      },
      { deep: true, immediate: true },
    );
    const formPayload = computed(() => {
      return {
        utf8: "✓",
        set_filter: "1",
        type: query.value.type,
        display_type: displayType.value,
        c: [...columns.value],
        f: [...Object.keys(filters.value), ""],
        op: Object.assign(
          {},
          ...Object.keys(filters.value).map((k) => ({
            [k]: filters.value[k].operator,
          })),
        ),
        v: Object.assign(
          {},
          ...Object.keys(filters.value).map((k) => ({
            [k]: [...filters.value[k].values],
          })),
        ),
      };
    });
    const isApplying = ref(false);
    const isSaving = ref(false);
    const isClearing = ref(false);
    router.afterEach(() => {
      isApplying.value = false;
      isSaving.value = false;
      isClearing.value = false;
    });
    const onSubmit = (e?: Event) => {
      if (e) {
        e.preventDefault();
      }
      appDebug({ ...formPayload.value });
      const newRoute = { ...route, query: { ...formPayload.value } };
      isApplying.value = true;
      router.push(newRoute).catch(() => {
        isApplying.value = false;
      });
    };
    const onSave = (e?: Event) => {
      if (e) {
        e.preventDefault();
      }
      appDebug({ ...formPayload.value });
      const newRoute = {
        ...route,
        name: "queries-new",
        query: { ...formPayload.value },
      };
      isSaving.value = true;
      router.push(newRoute).catch(() => {
        isSaving.value = false;
      });
    };
    const onClear = (e?: Event) => {
      if (e) {
        e.preventDefault();
      }
      isClearing.value = true;
      router.push(clearedRoute.value).catch(() => {
        isClearing.value = false;
      });
    };
    return {
      appBarColor,
      form,
      showFilterMenu,
      showColumnsMenu,
      showGroupingMenu,
      showOptionsMenu,
      formSubmitPath,
      clearedRoute,
      canClearRoute,
      onClear,
      onSubmit,
      onSave,
      displayType,
      columns,
      filters,
      isApplying,
      isSaving,
      isClearing,
    };
  },
});
</script>

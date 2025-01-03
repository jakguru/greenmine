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
    <QueriesPartialDataTable
      v-model:model-value="value"
      v-model:payload-value="payloadValue"
      :query="query"
      :payload="payload"
      :submitting="submitting"
      :dirty="dirty"
      :get-action-items="getActionMenuItems"
      filter-to-id-field="issue_id"
      @submit="onSubmit"
      @refresh="onRefresh"
    />
  </v-container>
</template>

<script lang="ts">
import { defineComponent, computed, inject, ref, watch } from "vue";
import { useI18n } from "vue-i18n";
import { useRoute, useRouter } from "vue-router";
import { makeNewQueryPayloadFromQueryAndQueryPayload } from "@/friday";
import {
  useSystemAccentColor,
  cloneObject,
  checkObjectEquality,
  loadRouteData,
} from "@/utils/app";
import {
  QueriesPartialFilters,
  QueriesPartialColumns,
  QueriesPartialSorting,
  QueriesPartialGroupings,
  QueriesPartialOptions,
  QueriesPartialDataTable,
} from "@/components/queries/partials";
import { useRouteDataStore } from "@/stores/routeData";
import { useGetActionMenuItems } from "@/components/queries/utils/issues";

import type { PropType } from "vue";
import type {
  ToastService,
  ApiService,
  BusService,
  BusEventCallbackSignatures,
} from "@jakguru/vueprint";

import type {
  QueryResponsePayload,
  QueryData,
  Issue,
  QueryResponse,
} from "@/friday";

import type { RealtimeModelEventPayload } from "@/utils/realtime";

export default defineComponent({
  name: "EmbeddedIssueQueryTable",
  components: {
    QueriesPartialFilters,
    QueriesPartialColumns,
    QueriesPartialSorting,
    QueriesPartialGroupings,
    QueriesPartialOptions,
    QueriesPartialDataTable,
  },
  props: {
    issues: {
      type: Object as PropType<QueryResponse<Issue>>,
      required: true,
    },
  },
  setup(props) {
    const toast = inject<ToastService>("toast");
    const api = inject<ApiService>("api");
    const bus = inject<BusService>("bus");
    const route = useRoute();
    const router = useRouter();
    const { t } = useI18n({ useScope: "global" });
    const issues = computed(() => props.issues);
    const query = computed(() => issues.value.query);
    const value = ref<QueryData>(cloneObject(query.value));
    const payload = computed(() => issues.value.payload);
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
      return (
        query.value.columns.available.sortable &&
        query.value.columns.available.sortable.length > 0
      );
    });
    const showGroupingsMenu = computed(() => {
      return (
        query.value.display.current === "list" &&
        query.value.columns.available.groupable.length > 0
      );
    });
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
    const modelRealtimeUpdateKey = computed<
      keyof BusEventCallbackSignatures | undefined
    >(() => undefined);
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
    const getActionMenuItems = useGetActionMenuItems(api, toast, t);
    const accentColor = useSystemAccentColor();
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
    };
  },
});
</script>

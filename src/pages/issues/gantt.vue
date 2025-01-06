<template>
  <QueriesPage
    :title="$t('pages.issues-gantt.title')"
    :params="params"
    :payload="payload"
    :query="query"
    :queries="queries"
    :permissions="permissions"
    :creatable="creatable"
    :get-action-items="getActionMenuItems"
    :parent-bus="childBus"
    filter-to-id-field="issue_id"
  />
</template>

<script lang="ts">
import { defineComponent, inject, onMounted, onBeforeUnmount } from "vue";
import { useI18n } from "vue-i18n";
import { useGetActionMenuItems } from "@/components/queries/utils/issues";
import { TinyEmitter } from "tiny-emitter";
import QueriesPage from "@/components/queries/gantt-page.vue";

import type { PropType } from "vue";
import type {
  QueryResponseParams,
  QueryResponseGanttPayload,
  QueryData,
  DefinedQuery,
  Permissions,
  Createable,
} from "@/friday";
import type { ApiService, ToastService, BusService } from "@jakguru/vueprint";

export default defineComponent({
  name: "IssuesGantt",
  components: {
    QueriesPage,
  },
  props: {
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
  },
  setup() {
    const api = inject<ApiService>("api");
    const toast = inject<ToastService>("toast");
    const bus = inject<BusService>("bus");
    const childBus = new TinyEmitter();
    const { t } = useI18n({ useScope: "global" });
    const getActionMenuItems = useGetActionMenuItems(api, toast, t);
    const doRefresh = () => {
      childBus.emit("refresh");
    };
    onMounted(() => {
      if (bus) {
        bus.on("rtu:enumerations", doRefresh, { local: true });
        bus.on("rtu:issue-statuses", doRefresh, { local: true });
        bus.on("rtu:trackers", doRefresh, { local: true });
      }
    });
    onBeforeUnmount(() => {
      if (bus) {
        bus.off("rtu:enumerations", doRefresh);
        bus.off("rtu:issue-statuses", doRefresh);
        bus.off("rtu:trackers", doRefresh);
      }
    });
    return {
      getActionMenuItems,
      childBus,
    };
  },
});
</script>

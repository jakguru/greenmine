<template>
  <QueriesPage
    :title="$t('pages.issues.title')"
    :params="params"
    :payload="payload"
    :query="query"
    :queries="queries"
    :permissions="permissions"
    :creatable="creatable"
    :get-action-items="getActionMenuItems"
    filter-to-id-field="issue_id"
  />
</template>

<script lang="ts">
import { defineComponent, inject } from "vue";
import { QueriesPage } from "@/components/queries";
import { useI18n } from "vue-i18n";
import { useGetActionMenuItems } from "@/components/queries/utils/issues";

import type { PropType } from "vue";
import type {
  QueryResponseParams,
  QueryResponsePayload,
  QueryData,
  DefinedQuery,
  Permissions,
  Createable,
} from "@/friday";
import type { ApiService, ToastService } from "@jakguru/vueprint";

export default defineComponent({
  name: "IssuesIndex",
  components: {
    QueriesPage,
  },
  props: {
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
  },
  setup() {
    const api = inject<ApiService>("api");
    const toast = inject<ToastService>("toast");
    const { t } = useI18n({ useScope: "global" });
    const getActionMenuItems = useGetActionMenuItems(api, toast, t);
    return {
      getActionMenuItems,
    };
  },
});
</script>

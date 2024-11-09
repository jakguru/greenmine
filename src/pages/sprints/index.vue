<template>
  <QueriesPage
    :title="$t('pages.sprints.title')"
    :params="params"
    :payload="payload"
    :query="query"
    :queries="queries"
    :permissions="permissions"
    :creatable="creatable"
    :get-action-items="getActionMenuItems"
  >
    <template #tabs>
      <v-btn
        :to="{
          name: 'sprints-id',
          params: { id: 0 },
        }"
        color="warning"
        variant="elevated"
        class="ml-auto mr-3"
      >
        {{ $t("labels.backlog") }}
      </v-btn>
    </template>
  </QueriesPage>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { QueriesPage } from "@/components/queries";

import type { PropType } from "vue";
import type {
  QueryResponseParams,
  QueryResponsePayload,
  QueryData,
  DefinedQuery,
  Permissions,
  Createable,
  Item,
} from "@/friday";

import type { ActionMenuItem } from "@/components/queries/partials/action-menu";

export default defineComponent({
  name: "SprintsIndex",
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
    const getActionMenuItems = (sprints: Item[]): ActionMenuItem[] => {
      if (sprints.length > 1) {
        return [];
      } else {
        return [];
      }
    };
    return {
      getActionMenuItems,
    };
  },
});
</script>

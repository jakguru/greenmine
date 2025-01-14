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
import { defineComponent, h } from "vue";
import { QueriesPage } from "@/components/queries";
import { VListItem } from "vuetify/components/VList";
import { useI18n } from "vue-i18n";

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
    const { t } = useI18n({ useScope: "global" });
    const getActionMenuItems = (
      sprints: Item[],
      _onDone: () => void,
      onFilterTo: () => void,
    ): ActionMenuItem[] => {
      if (sprints.length > 1) {
        return [
          {
            component: h(VListItem, {
              title: t("issueActionMenu.filterTo.title"),
              appendIcon: "mdi-filter",
              density: "compact",
              onClick: () => onFilterTo(),
            }),
          },
        ];
      }
      return [
        {
          component: h(VListItem, {
            title: t("labels.open"),
            prependIcon: "mdi-open-in-app",
            density: "compact",
            to: {
              name: "sprints-id",
              params: { id: sprints[0].id },
            },
          }),
        },
        {
          component: h(VListItem, {
            title: t("issueActionMenu.filterTo.title"),
            appendIcon: "mdi-filter",
            density: "compact",
            onClick: () => onFilterTo(),
          }),
        },
      ];
    };
    return {
      getActionMenuItems,
    };
  },
});
</script>

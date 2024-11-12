<template>
  <QueriesPage
    :title="$t('pages.custom-fields.title')"
    :params="params"
    :payload="payload"
    :query="query"
    :queries="queries"
    :permissions="permissions"
    :creatable="creatable"
    :get-action-items="getActionMenuItems"
  />
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
  name: "CustomFieldIndex",
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
      customFields: Item[],
      _onDone: () => void,
      onFilterTo: () => void,
    ): ActionMenuItem[] => {
      if (customFields.length > 1) {
        return [
          {
            component: h(VListItem, {
              title: t("customFieldActionMenu.filterTo.title"),
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
              name: "custom-fields-id-edit",
              params: { id: customFields[0].id },
            },
          }),
        },
        {
          component: h(VListItem, {
            title: t("customFieldActionMenu.filterTo.title"),
            appendIcon: "mdi-filter",
            density: "compact",
            onClick: () => onFilterTo(),
          }),
        },
        {
          component: h(VListItem, {
            title: t("customFieldActionMenu.delete.title"),
            appendIcon: "mdi-delete",
            density: "compact",
            onClick: () => {
              alert(`deleting custom field ${customFields[0].id}`);
            },
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

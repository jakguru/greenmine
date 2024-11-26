<template>
  <QueriesPage
    :title="$t('pages.users.title')"
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
import { defineComponent, h, inject } from "vue";
import { QueriesPage } from "@/components/queries";
import { VListItem } from "vuetify/components/VList";
import { useI18n } from "vue-i18n";
import { getCsrfObject } from "@/utils/app";
import qs from "qs";

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
import type { ApiService, SwalService, ToastService } from "@jakguru/vueprint";

export default defineComponent({
  name: "UsersIndex",
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
    const api = inject<ApiService>("api");
    const swal = inject<SwalService>("swal");
    const toast = inject<ToastService>("toast");
    const getActionMenuItems = (
      customFields: Item[],
      onDone: () => void,
      onFilterTo: () => void,
    ): ActionMenuItem[] => {
      if (customFields.length > 1) {
        return [
          {
            component: h(VListItem, {
              title: t("userActionMenu.filterTo.title"),
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
              name: "users-id-edit",
              params: { id: customFields[0].id },
            },
          }),
        },
        {
          component: h(VListItem, {
            title: t("userActionMenu.filterTo.title"),
            appendIcon: "mdi-filter",
            density: "compact",
            onClick: () => onFilterTo(),
          }),
        },
        {
          component: h(VListItem, {
            title: t("userActionMenu.delete.title"),
            appendIcon: "mdi-delete",
            density: "compact",
            onClick: async () => {
              if (!api || !swal || !toast) return;
              const { isConfirmed } = await swal.fire({
                title: t("userActionMenu.delete.confirm"),
                icon: "warning",
                showCancelButton: true,
                confirmButtonText: t("labels.yes"),
                cancelButtonText: t("labels.no"),
              });
              if (!isConfirmed) return;
              const { status } = await api.delete(
                `/users/${customFields[0].id}?${qs.stringify(getCsrfObject())}`,
              );
              if (status < 200 || status >= 300) {
                toast.fire({
                  title: t("userActionMenu.delete.error"),
                  icon: "error",
                });
              }
              onDone();
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

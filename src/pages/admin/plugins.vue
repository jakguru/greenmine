<template>
  <v-container fluid>
    <v-card min-height="100" color="surface">
      <v-toolbar color="transparent" density="compact">
        <v-toolbar-title class="font-weight-bold d-flex align-center" tag="h1">
          <v-icon size="20" class="me-3" style="position: relative; top: -2px"
            >mdi-puzzle</v-icon
          >
          {{ $t("pages.admin-plugins.title") }}
        </v-toolbar-title>
      </v-toolbar>
      <v-divider />
      <v-data-table v-bind="bindings">
        <template #expanded-row="{ columns, item }">
          <tr>
            <td class="px-3 py-2" :colspan="columns.length">
              {{ item.description }}
            </td>
          </tr>
        </template>
        <template #[`item.settings`]="{ item }">
          <RouterLink
            v-if="item.settings"
            :to="{ name: 'settings-plugin-id', params: { id: item.id } }"
          >
            {{ $t("labels.configure") }}
          </RouterLink>
        </template>
      </v-data-table>
    </v-card>
  </v-container>
</template>

<script lang="ts">
import { defineComponent, computed } from "vue";
import { RouterLink } from "vue-router";

import type { PropType } from "vue";
import type { PluginData } from "@/redmine";

export default defineComponent({
  name: "AdminPlugins",
  components: {
    RouterLink,
  },
  props: {
    plugins: {
      type: Array as PropType<PluginData[]>,
      required: true,
    },
  },
  setup(props) {
    const plugins = computed(() => props.plugins);
    const headers = computed(() => [
      {
        key: "name",
        value: "name",
        title: "Name",
        sortable: true,
      },
      {
        key: "author",
        value: "author",
        title: "Author",
        sortable: true,
      },
      {
        key: "version",
        value: "version",
        title: "Version",
        sortable: true,
      },
      {
        key: "settings",
        title: "",
        sortable: false,
      },
    ]);
    const bindings = computed(() => ({
      items: plugins.value,
      headers: headers.value,
      showExpand: true,
      hover: true,
    }));
    return {
      bindings,
    };
  },
});
</script>

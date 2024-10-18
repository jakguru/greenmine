<template>
  <v-card color="surface">
    <v-data-table-server
      v-model:model-value="selected"
      v-model:items-per-page="itemsPerPage"
      v-bind="tableBindings"
      @update:options="loadItems"
    >
      <template #group-header="{ item, columns, toggleGroup, isGroupOpen }">
        <tr>
          <td :colspan="columns.length">
            <VBtn
              :icon="isGroupOpen(item) ? '$expand' : '$next'"
              size="small"
              variant="text"
              @click="toggleGroup(item)"
            ></VBtn>
            <strong>{{ item.value }}</strong>
          </td>
        </tr>
      </template>
    </v-data-table-server>
  </v-card>
</template>

<script lang="ts">
import { defineComponent, ref, computed, watch } from "vue";
import { appDebug, useSystemAppBarColor } from "@/utils/app";
import { useRoute, useRouter } from "vue-router";
import { useI18n } from "vue-i18n";

import type {
  GroupedEntry,
  ModelQuery,
  QueryAvailableFilter,
  QueryColumn,
} from "@/redmine";
import type { PropType } from "vue";

export default defineComponent({
  name: "QueriesList",
  components: {},
  props: {
    items: {
      type: Array as PropType<GroupedEntry<any>[]>,
      required: true,
    },
    query: {
      type: Object as PropType<ModelQuery>,
      required: true,
    },
    options: {
      type: Object as PropType<Record<string, QueryAvailableFilter>>,
      required: true,
    },
    showIdColumn: {
      type: Boolean as PropType<boolean>,
      default: false,
    },
  },
  setup(props) {
    const items = computed(() => props.items);
    const query = computed(() => props.query);
    const options = computed(() => props.options);
    const showIdColumn = computed(() => props.showIdColumn);
    const itemsPerPage = ref(query.value.per_page);
    const { t } = useI18n({ useScope: "global" });
    const getQueryFieldName = (key: string) => {
      if (
        options.value[key] &&
        options.value[key].options &&
        options.value[key].options.name
      ) {
        return options.value[key].options.name;
      }
      return t(`columns.${query.value.type.toLowerCase()}.${key}`);
    };
    const getQueryColumnKey = (field: QueryColumn) => {
      return field.caption_key.replace("field_", "entry.");
    };
    watch(
      () => query.value,
      (q) => {
        itemsPerPage.value = q.per_page;
      },
      { deep: true, immediate: true },
    );
    const groups = computed(() => {
      const groups: Record<
        string,
        {
          name: string | null;
          count: number | null;
          totals: string | Record<string, number> | null;
        }
      > = {};
      items.value.forEach((item) => {
        const key = item.group_name || "";
        if (!groups[key]) {
          groups[key] = {
            name: item.group_name,
            count: item.group_count,
            totals: item.group_totals,
          };
        }
      });
      return groups;
    });
    const groupKeys = computed(() => Object.keys(groups.value));
    const isGrouped = computed(
      () =>
        groupKeys.value.length > 0 &&
        JSON.stringify(groupKeys.value) !== JSON.stringify([""]),
    );
    const headers = computed(() => {
      const ret = [...query.value.columns.current].map((c) => ({
        title: getQueryFieldName(c.name),
        sortable: false !== c.sortable,
        key: getQueryColumnKey(c),
        value: getQueryColumnKey(c),
        noWrap: true,
      }));
      if (isGrouped.value) {
        ret.unshift({
          title: "",
          sortable: false,
          key: "group_name",
          value: "group_name",
          noWrap: true,
        });
      }
      if (showIdColumn.value) {
        ret.unshift({
          title: t("columns.id"),
          sortable: false,
          key: "entry.id",
          value: "entry.id",
          noWrap: true,
        });
      }
      return ret;
    });
    const tableBindings = computed(() => {
      const ret: any = {
        headers: headers.value,
        items: items.value,
        itemsLength: query.value.total,
        itemsPerPageOptions: [5, 10, 15, 20, 25, 50, 75, 100],
        page: query.value.page,
        returnObject: true,
        selectStrategy: "page",
        showCurrentPage: true,
        showSelect: true,
      };
      if (isGrouped.value) {
        ret.groupBy = [{ key: "group_name" }];
      }
      return ret;
    });
    const loadItems = () => {};
    const selected = ref([]);
    return {
      itemsPerPage,
      groups,
      tableBindings,
      loadItems,
      selected,
    };
  },
});
</script>

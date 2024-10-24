<template>
  <v-data-table-server v-bind="tableBindings" @update:options="onUpdateOptions">
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
    <template
      v-for="c in cellColumnKeys"
      :key="`cell-for-${c}`"
      #[`item.${c}`]="{
        index,
        item,
        internalItem,
        isExpanded,
        toggleExpand,
        isSelected,
        toggleSelect,
        value,
        column,
      }"
    >
      <QueriesPartialDataTableCell
        :query="query"
        :index="index"
        :item="item"
        :internal-item="internalItem"
        :is-expanded="isExpanded"
        :toggle-expand="toggleExpand"
        :is-selected="isSelected"
        :toggle-select="toggleSelect"
        :value="value"
        :column="column"
      />
    </template>
  </v-data-table-server>
</template>

<script lang="ts">
import { defineComponent, computed, ref, nextTick } from "vue";
import { cloneObject } from "@/utils/app";
import { useI18n } from "vue-i18n";
import { QueriesPartialDataTableCell } from "./data-table-cell-component";

import type { PropType } from "vue";
import type { QueryData, QueryResponsePayload, Column, Item } from "@/friday";

export default defineComponent({
  name: "QueriesPartialDataTable",
  components: {
    QueriesPartialDataTableCell,
  },
  props: {
    modelValue: {
      type: Object as PropType<QueryData>,
      required: true,
    },
    query: {
      type: Object as PropType<QueryData>,
      required: true,
    },
    payload: {
      type: Object as PropType<QueryResponsePayload>,
      required: true,
    },
    submitting: {
      type: Boolean,
      default: false,
    },
    dirty: {
      type: Boolean,
      default: false,
    },
  },
  emits: [
    "update:modelValue",
    "update:value",
    "update",
    "submit",
    "refresh",
    "reset",
  ],
  setup(props, { emit }) {
    const { t } = useI18n({ useScope: "global" });
    const dirty = computed(() => props.dirty);
    const modelValue = computed({
      get: () => props.modelValue,
      set: (value) => {
        emit("update:modelValue", value);
        emit("update:value", value);
        emit("update", value);
        nextTick(() => {
          if (dirty.value) {
            emit("submit");
          }
        });
      },
    });
    const query = computed(() => props.query);
    const payload = computed(() => props.payload);
    const submitting = computed(() => props.submitting);
    const grouping = computed<Column | undefined>(
      () => query.value.columns.current.groupable[0],
    );
    const headers = computed(() => {
      const ret: Column[] = [];
      if (grouping.value) {
        ret.push({
          key: "group_name",
          value: "group_name",
          title: grouping.value.title,
          nowrap: grouping.value.nowrap,
          sortable: false,
          meta: grouping.value.meta,
          attributes: grouping.value.attributes,
        });
      }
      query.value.columns.current.inline.forEach((col) => {
        ret.push(cloneObject(col));
      });
      return ret;
    });
    const tableBindings = computed(() => ({
      headers: headers.value,
      items: payload.value.items,
      itemsLength: payload.value.items_length,
      itemsPerPage: payload.value.items_per_page,
      itemsPerPageOptions: [5, 10, 15, 20, 25, 50, 75, 100],
      page: payload.value.page,
      returnObejects: true,
      selectStrategy: "page" as "page" | "all" | "single" | undefined,
      showCurrentPage: true,
      showSelect: true,
      multiSort: true,
      sortBy: query.value.columns.current.sort
        ? [...query.value.columns.current.sort].map((c) => ({
            key: c.key,
            order: c.sort,
          }))
        : undefined,
      groupBy: grouping.value ? [{ key: "group_name" }] : undefined,
      loading: submitting.value,
    }));
    const selectedItems = ref<Array<Item>>([]);
    const onUpdateOptions = (options: any) => {
      console.log(options);
    };
    const cellColumnKeys = computed(() => [...headers.value].map((c) => c.key));
    return {
      tableBindings,
      selectedItems,
      onUpdateOptions,
      cellColumnKeys,
    };
  },
});
</script>

<style lang="scss">
.query-data-table {
  overflow-y: auto;
  overflow-x: hidden;
}
</style>

<template>
  <v-data-table-server
    v-bind="tableBindings"
    v-model:model-value="selectedItems"
    @update:options="onUpdateOptions"
  >
    <template #group-header="{ item, columns, toggleGroup, isGroupOpen }">
      <tr>
        <td :colspan="columns.length">
          <div class="d-flex h-100 align-center">
            <VBtn
              :icon="isGroupOpen(item) ? '$expand' : '$next'"
              size="small"
              variant="text"
              @click="toggleGroup(item)"
            ></VBtn>
            <strong>{{ item.value }}</strong>
            <v-spacer />
            <div v-if="hasGlobalTotals" class="d-flex justify-end">
              <div
                v-for="(t, i) in payload.totals"
                :key="`totals-${item.value}-${i}`"
                class="px-2"
              >
                <v-chip size="small">
                  <strong class="me-2">{{ t.title }}</strong>
                  <abbr
                    :title="
                      formatDurationForHumans(totalsByGroup[item.value][t.key])
                    "
                    >{{
                      formatDuration(totalsByGroup[item.value][t.key])
                    }}</abbr
                  >
                </v-chip>
              </div>
            </div>
          </div>
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
        :menu-generator="handleInTableContextMenuEvent"
      />
    </template>
    <template #expanded-row="{ columns, item }">
      <tr>
        <td class="px-0 py-2" :colspan="columns.length">
          <v-list-item
            v-for="block in query.columns.current.block"
            :key="block.key"
            :title="block.title"
            :subtitle="item.entry[block.key].value"
          />
        </td>
      </tr>
    </template>
    <template #top>
      <slot name="before-top" />
      <v-row no-gutters>
        <v-col cols="12" sm="6" class="d-flex justify-center justify-sm-start">
          <v-menu
            v-model:model-value="actionMenuOpened"
            v-bind="actionMenuBindings"
          >
            <template #activator="{ props }">
              <v-btn-group
                divided
                base-color="accent"
                :class="xs ? 'ma-2 mb-4' : 'ma-2'"
                style="height: 32px"
              >
                <v-btn
                  height="32"
                  v-bind="{
                    ...props,
                    disabled: selectedItems.length === 0,
                  }"
                >
                  {{ $t("labels.actions") }}
                </v-btn>
                <v-btn
                  v-bind="{ ...props, disabled: selectedItems.length === 0 }"
                  icon="mdi-menu-down"
                  density="comfortable"
                  height="32"
                />
              </v-btn-group>
            </template>
            <ActionMenu
              :items="actionMenuItems"
              :loading="actionMenuIsLoading"
            />
          </v-menu>
        </v-col>
        <v-col
          v-if="hasGlobalTotals"
          cols="12"
          sm="6"
          class="d-flex justify-end"
        >
          <v-slide-group show-arrows>
            <v-slide-group-item
              v-for="t in payload.totals"
              :key="t.key"
              class="px-2"
            >
              <v-chip>
                <strong class="me-2">{{ t.title }}</strong>
                <abbr :title="formatDurationForHumans(Number(t.total))">{{
                  formatDuration(Number(t.total))
                }}</abbr>
              </v-chip>
            </v-slide-group-item>
          </v-slide-group>
        </v-col>
      </v-row>
      <v-divider class="mt-3" />
      <slot name="after-top" />
    </template>
  </v-data-table-server>
</template>

<script lang="ts">
import { defineComponent, computed, ref, watch } from "vue";
import { cloneObject, checkObjectEquality } from "@/utils/app";
import { formatDuration, formatDurationForHumans } from "@/utils/formatting";
import { QueriesPartialDataTableCell } from "./data-table-cell-component";
import { useDisplay } from "vuetify";
import { ActionMenu } from "./action-menu";

import type { PropType } from "vue";
import type {
  QueryData,
  QueryResponsePayload,
  Column,
  Item,
  ColumnSort,
} from "@/friday";
import type { ActionMenuItem, GetActionItemsMethod } from "./action-menu";

export default defineComponent({
  name: "QueriesPartialDataTable",
  components: {
    QueriesPartialDataTableCell,
    ActionMenu,
  },
  props: {
    modelValue: {
      type: Object as PropType<QueryData>,
      required: true,
    },
    payloadValue: {
      type: Object as PropType<QueryResponsePayload>,
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
    getActionItems: {
      type: Function as PropType<GetActionItemsMethod | undefined>,
      default: undefined,
    },
    filterToIdField: {
      type: String as PropType<string>,
      default: "id",
    },
  },
  emits: [
    "update:modelValue",
    "update:payloadValue",
    "update:model-value",
    "update:payload-value",
    "submit",
    "refresh",
    "reset",
  ],
  setup(props, { emit }) {
    const modelValue = ref(props.modelValue);
    const payloadValue = ref(props.payloadValue);
    const display = useDisplay();
    const modelValueComputed = computed(() => props.modelValue);
    const payloadValueComputed = computed(() => props.payloadValue);
    const getActionItems = computed(() => props.getActionItems);
    watch(
      () => modelValueComputed.value,
      (is) => {
        modelValue.value = is;
      },
      { deep: true, immediate: true },
    );
    watch(
      () => payloadValueComputed.value,
      (is) => {
        payloadValue.value = is;
      },
      { deep: true, immediate: true },
    );
    watch(
      () => modelValue.value,
      (is) => {
        emit("update:modelValue", is);
        emit("update:model-value", is);
      },
      { deep: true },
    );
    watch(
      () => payloadValue.value,
      (is) => {
        emit("update:payloadValue", is);
        emit("update:payload-value", is);
      },
      { deep: true },
    );
    const query = computed(() => props.query);
    const payload = computed(() => props.payload);
    const submitting = computed(() => props.submitting);
    const grouping = computed<Column | undefined>(
      () => query.value.columns.current.groupable[0],
    );
    const hasBlocks = computed(
      () => query.value.columns.current.block.length > 0,
    );
    const hasGlobalTotals = computed(
      () => query.value.columns.current.totalable.length > 0,
    );
    const headers = computed(() => {
      const ret: Column[] = [];
      if (query.value.columns.current.inline.length > 0) {
        ret.push({
          key: "__menu",
          value: "",
          title: "",
          nowrap: true,
          sortable: false,
          meta: {
            default_order: null,
            frozen: null,
            groupable: false,
            inline: true,
            sort_key: "",
            totalable: false,
          },
        });
      }
      // if (grouping.value) {
      //   ret.push({
      //     key: "group_name",
      //     value: "group_name",
      //     title: grouping.value.title,
      //     nowrap: grouping.value.nowrap,
      //     sortable: false,
      //     meta: grouping.value.meta,
      //     attributes: grouping.value.attributes,
      //   });
      // }
      query.value.columns.current.inline.forEach((col) => {
        const toAdd = cloneObject(col);
        // if (grouping.value) {
        //   if (toAdd.key === grouping.value.key) {
        //     toAdd.sortable = false;
        //   }
        // }
        ret.push(toAdd);
      });
      return ret;
    });
    const selectedItems = ref<Array<number>>([]);
    const actionMenuOpened = ref(false);
    const actionMenuIsLoading = ref(false);
    const actionMenuOffsetX = ref<number | undefined>(undefined);
    const actionMenuOffsetY = ref<number | undefined>(undefined);
    const actionMenuAbsolutePositioningOffset = computed(() => {
      const ret: Record<string, string> = {};
      if ("number" === typeof actionMenuOffsetX.value) {
        ret.left = `${actionMenuOffsetX.value}px`;
      }
      if ("number" === typeof actionMenuOffsetY.value) {
        ret.top = `${actionMenuOffsetY.value + 44}px`;
      }
      return ret;
    });
    const actionMenuBindings = computed(() => ({
      absolute: true,
      attach: "main.v-main > div.v-container",
      contentProps: {
        style: {
          ...actionMenuAbsolutePositioningOffset.value,
          zIndex: 20,
        },
      },
    }));
    watch(
      () => selectedItems.value,
      (value) => {
        if (value.length === 0) {
          actionMenuOpened.value = false;
        }
      },
    );
    const actionMenuItems = ref<ActionMenuItem[]>([]);
    const onActionMenuDone = () => {
      selectedItems.value = [];
      emit("refresh");
    };
    const filterToIdField = computed(() => props.filterToIdField);
    const onFilterTo = () => {
      modelValue.value.filters.current[filterToIdField.value] = {
        operator: "=",
        values: [selectedItems.value.map((i) => i.toString()).join(",")],
      };
      emit("submit");
      selectedItems.value = [];
    };
    const loadActionMenuItems = async () => {
      actionMenuIsLoading.value = true;
      actionMenuItems.value = [];
      if (!getActionItems.value) {
        actionMenuIsLoading.value = false;
        actionMenuOpened.value = false;
        alert(
          '"getActionItems" prop was not passed to QueriesPartialDataTable component',
        );
        return;
      }
      try {
        actionMenuItems.value = await getActionItems.value(
          selectedItems.value
            .map((id) => payload.value.items.find((item) => item.id === id))
            .filter((v) => "undefined" !== typeof v),
          onActionMenuDone,
          onFilterTo,
        );
        actionMenuIsLoading.value = false;
      } catch (e) {
        console.error(e);
        actionMenuIsLoading.value = false;
        actionMenuOpened.value = false;
        return;
      }
    };
    watch(
      () => actionMenuOpened.value,
      (is) => {
        if (!is) {
          actionMenuOffsetX.value = undefined;
          actionMenuOffsetY.value = undefined;
        } else {
          loadActionMenuItems();
        }
      },
    );
    const handleInTableContextMenuEvent = (
      item: Item,
      _column: any,
      e: MouseEvent,
      only: boolean = false,
    ) => {
      e.preventDefault();
      e.stopPropagation();
      e.stopImmediatePropagation();
      if (!selectedItems.value.includes(item.id) || only) {
        selectedItems.value = [item.id];
      }
      if (document) {
        const mainContainer = document.querySelector(
          "main.v-main > div.v-container",
        );
        if (mainContainer) {
          const mainContainerRect = mainContainer.getBoundingClientRect();
          const mainContainerX = mainContainerRect.x;
          const mainContainerY = mainContainerRect.y;
          actionMenuOffsetX.value = e.clientX - mainContainerX;
          actionMenuOffsetY.value = e.clientY - mainContainerY;
        } else {
          actionMenuOffsetX.value = undefined;
          actionMenuOffsetY.value = undefined;
        }
      } else {
        actionMenuOffsetX.value = undefined;
        actionMenuOffsetY.value = undefined;
      }
      actionMenuOpened.value = true;
    };
    const tableBindings = computed(() => ({
      headers: headers.value,
      hover: true,
      items: payload.value.items,
      itemsLength: payload.value.items_length,
      itemsPerPage: payload.value.items_per_page,
      itemsPerPageOptions: [25, 50, 100],
      page: payload.value.page,
      returnObejects: true,
      selectStrategy: "page" as const,
      showCurrentPage: true,
      showSelect: true,
      showExpand: hasBlocks.value,
      multiSort: true,
      mustSort: true,
      sortBy: query.value.columns.current.sort
        ? [...query.value.columns.current.sort].map((c) => ({
            key: c.key,
            order: c.sort,
          }))
        : undefined,
      groupBy: grouping.value ? [{ key: "group_name" }] : undefined,
      loading: submitting.value,
      cellProps({ item, column }: { item: Item; column: any }) {
        return {
          onContextmenu: handleInTableContextMenuEvent.bind(null, item, column),
        };
      },
      class: ["query-data-table"],
    }));
    let firstTimeUpdated = false;
    const onUpdateOptions = (options: any) => {
      if (!firstTimeUpdated) {
        firstTimeUpdated = true;
        return;
      }
      payloadValue.value.items_per_page = options.itemsPerPage || 25;
      payloadValue.value.page = options.page || 1;
      const queryColumnsCurrentSort: ColumnSort[] = options.sortBy
        ? options.sortBy
            .map((s: { key: string; order: "asc" | "desc" }) => {
              const sortableColumn = query.value.columns.available.sortable
                ? query.value.columns.available.sortable.find(
                    (c) => c.key === s.key,
                  )
                : undefined;
              if (!sortableColumn) {
                return undefined;
              }
              return {
                ...sortableColumn,
                sort: s.order,
              } as ColumnSort;
            })
            .filter((v: ColumnSort | undefined) => "undefined" !== typeof v)
        : [];
      const originalQueryColumnsCurrentSort = cloneObject(
        query.value.columns.current.sort,
      );
      const sortingIsDifferent = !checkObjectEquality(
        queryColumnsCurrentSort,
        originalQueryColumnsCurrentSort,
      );
      if (sortingIsDifferent) {
        modelValue.value.columns.current.sort = queryColumnsCurrentSort;
      }
      if (
        !checkObjectEquality(query.value, modelValue.value) ||
        !checkObjectEquality(payload.value, payloadValue.value)
      ) {
        emit("submit");
      }
    };
    const cellColumnKeys = computed(() => [...headers.value].map((c) => c.key));
    const getItemBlockContent = (item: any, block: Column) => {
      return item.entry[block.key];
    };
    const totalsByGroup = computed(() => {
      const ret: Record<string, Record<string, number>> = {};
      payload.value.items.forEach((item) => {
        const group = item.group_name;
        if (!group) {
          return;
        }
        if (!ret[group]) {
          ret[group] = {};
        }
        query.value.columns.current.totalable.forEach((total) => {
          if (!ret[group][total.key]) {
            ret[group][total.key] = 0;
          }
          ret[group][total.key] += Number(item.entry[total.key].value);
        });
      });
      return ret;
    });
    return {
      tableBindings,
      selectedItems,
      onUpdateOptions,
      cellColumnKeys,
      getItemBlockContent,
      hasGlobalTotals,
      formatDuration,
      formatDurationForHumans,
      totalsByGroup,
      handleInTableContextMenuEvent,
      actionMenuOpened,
      actionMenuBindings,
      actionMenuIsLoading,
      actionMenuItems,
      xs: display.xs,
    };
  },
});
</script>

<style lang="scss">
.query-data-table {
  .v-table {
    > .v-table__wrapper {
      > table {
        > tbody {
          > tr {
            > td {
              cursor: context-menu;
            }
          }
        }
      }
    }
  }
}
</style>

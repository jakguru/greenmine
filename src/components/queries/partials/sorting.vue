<template>
  <QueriesOptionMenu
    v-bind="optionsMenuBindings"
    @submit="onSubmit"
    @reset="onReset"
    @refresh="onRefresh"
  >
    <template #content>
      <v-container class="query-columns-sorting">
        <v-row>
          <v-col cols="12" sm="6">
            <v-list-item :subtitle="$t('labels.current')">
              <template #append>
                <v-btn
                  size="x-small"
                  variant="text"
                  icon="mdi-notification-clear-all"
                  color="warning"
                  :disabled="0 === sortedColumns.length"
                  @click="onClearAll"
                />
              </template>
            </v-list-item>
            <v-divider />
            <v-sheet
              color="transparent"
              class="draggable-list-wrapper"
              min-width="300"
              max-height="400"
            >
              <draggable
                v-model="sortedColumns"
                item-key="value"
                group="columns"
                class="draggable-group"
                ghost-class="ghost"
              >
                <template #item="{ element, index }">
                  <v-list-item
                    :title="element.title"
                    min-width="300"
                    density="compact"
                  >
                    <v-radio-group
                      v-model="sortedColumns[index].sort"
                      inline
                      class="mt-2"
                      density="compact"
                      :loading="submitting"
                    >
                      <v-radio
                        :label="$t('labels.order.asc')"
                        value="asc"
                        density="compact"
                        :disabled="submitting"
                      ></v-radio>
                      <v-radio
                        :label="$t('labels.order.desc')"
                        value="desc"
                        density="compact"
                        :disabled="submitting"
                      ></v-radio>
                    </v-radio-group>
                    <template #append>
                      <div class="d-flex h-100 align-center">
                        <v-btn
                          size="x-small"
                          variant="text"
                          icon="mdi-chevron-up"
                          color="info"
                          :disabled="0 === index"
                          @click="onMoveSortedColumnUp(index)"
                        />
                        <v-btn
                          size="x-small"
                          variant="text"
                          icon="mdi-chevron-down"
                          color="info"
                          :disabled="index === sortedColumns.length - 1"
                          @click="onMoveSortedColumnDown(index)"
                        />
                        <v-btn
                          variant="text"
                          size="x-small"
                          color="warning"
                          icon
                          @click="onRemoveFromSelected(index)"
                        >
                          <v-icon>mdi-close</v-icon>
                        </v-btn>
                      </div>
                    </template>
                  </v-list-item>
                </template>
              </draggable>
            </v-sheet>
          </v-col>
          <v-col cols="12" sm="6">
            <v-list-item :subtitle="$t('labels.available')">
              <template #append>
                <v-btn
                  size="x-small"
                  variant="text"
                  icon="mdi-playlist-plus"
                  color="success"
                  :disabled="0 === remainingColumns.length"
                  @click="onAddAll"
                />
              </template>
            </v-list-item>
            <v-divider />
            <v-sheet
              color="transparent"
              class="draggable-list-wrapper"
              min-width="300"
              max-height="400"
            >
              <draggable
                v-model="remainingColumns"
                item-key="value"
                group="columns"
                class="draggable-group"
                ghost-class="ghost"
              >
                <template #item="{ element }">
                  <v-list-item
                    :title="element.title"
                    min-width="300"
                    density="compact"
                  >
                    <template #append>
                      <div class="d-flex h-100 align-center">
                        <v-btn
                          variant="text"
                          size="x-small"
                          color="success"
                          icon
                          @click="onAddToSelected(element)"
                        >
                          <v-icon>mdi-plus</v-icon>
                        </v-btn>
                      </div>
                    </template>
                  </v-list-item>
                </template>
              </draggable>
            </v-sheet>
          </v-col>
        </v-row>
      </v-container>
    </template>
  </QueriesOptionMenu>
</template>

<script lang="ts">
import { defineComponent, computed } from "vue";
import { useSystemSurfaceColor, useSystemAccentColor } from "@/utils/app";
import { useI18n } from "vue-i18n";
import QueriesOptionMenu from "./option-menu.vue";
import Draggable from "vuedraggable";

import type { PropType } from "vue";
import type { QueryData, Column, ColumnSort } from "@/friday";

export default defineComponent({
  name: "QueriesPartialSorting",
  components: {
    QueriesOptionMenu,
    Draggable,
  },
  props: {
    modelValue: {
      type: Object as PropType<QueryData>,
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
    const surfaceColor = useSystemSurfaceColor();
    const accentColor = useSystemAccentColor();
    const modelValue = computed({
      get: () => props.modelValue,
      set: (value) => {
        emit("update:modelValue", value);
        emit("update:value", value);
        emit("update", value);
      },
    });
    const submitting = computed(() => props.submitting);
    const dirty = computed(() => props.dirty);
    const sortedColumnsCount = computed(() => {
      return modelValue.value.columns.current.sort.length;
    });
    const sortedColumnsColor = computed(() =>
      sortedColumnsCount.value > 0 ? accentColor.value : surfaceColor.value,
    );
    const optionsMenuBindings = computed(() => ({
      class: ["me-2", "my-2"],
      dirty: dirty.value,
      submitting: submitting.value,
      color: sortedColumnsColor.value,
      icon: "mdi-sort",
      title: t("labels.sorting"),
      count: sortedColumnsCount.value,
    }));
    const onSubmit = (e?: Event) => {
      e?.preventDefault();
      emit("submit");
    };
    const onReset = (e?: Event) => {
      e?.preventDefault();
      emit("reset");
    };
    const onRefresh = (e?: Event) => {
      e?.preventDefault();
      emit("refresh");
    };
    const sortedColumns = computed({
      get: () => modelValue.value.columns.current.sort,
      set: (value: Array<ColumnSort>) => {
        modelValue.value.columns.current.sort = value;
      },
    });
    const sortedColumnKeys = computed(() =>
      sortedColumns.value.map((column) => column.key),
    );
    const remainingColumns = computed({
      get: () =>
        modelValue.value.columns.available.inline.filter(
          (column) => !sortedColumnKeys.value.includes(column.key),
        ),
      set: (_value: Array<Column>) => {
        // noop - the list is automatically calculated based on the selected columns from the available columns
      },
    });
    const onMoveSortedColumnUp = (index: number) => {
      if (index > 0) {
        const [item] = modelValue.value.columns.current.sort.splice(index, 1);
        modelValue.value.columns.current.sort.splice(index - 1, 0, item);
      }
    };
    const onMoveSortedColumnDown = (index: number) => {
      if (index < sortedColumns.value.length - 1) {
        const [item] = modelValue.value.columns.current.sort.splice(index, 1);
        modelValue.value.columns.current.sort.splice(index + 1, 0, item);
      }
    };
    const onRemoveFromSelected = (index: number) => {
      modelValue.value.columns.current.sort.splice(index, 1);
    };
    const onAddToSelected = (value: Column) => {
      modelValue.value.columns.current.sort.push({ ...value, sort: "asc" });
    };
    const onClearAll = () => {
      modelValue.value.columns.current.sort = [];
    };
    const onAddAll = () => {
      remainingColumns.value.forEach((c) => {
        modelValue.value.columns.current.sort.push({ ...c, sort: "asc" });
      });
    };
    return {
      optionsMenuBindings,
      onSubmit,
      onReset,
      onRefresh,
      sortedColumns,
      remainingColumns,
      onMoveSortedColumnUp,
      onMoveSortedColumnDown,
      onRemoveFromSelected,
      onAddToSelected,
      onClearAll,
      onAddAll,
    };
  },
});
</script>

<style lang="scss">
.query-columns-sorting {
  .v-list-item {
    cursor: move;
  }

  .ghost {
    opacity: 0.5;
    background: #c8ebfb;
  }

  .draggable-list-wrapper {
    overflow-y: auto;
    overflow-x: hidden;
  }
}
</style>

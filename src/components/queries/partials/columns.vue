<template>
  <v-card min-height="100" class="query-filters-panel">
    <v-toolbar color="transparent" density="compact">
      <v-toolbar-items class="ml-auto">
        <v-btn
          v-if="permission.save"
          variant="text"
          :loading="isSaving"
          @click="save"
        >
          <v-icon>mdi-content-save</v-icon>
          <span class="ms-2">{{ $t("labels.save") }}</span>
        </v-btn>
      </v-toolbar-items>
    </v-toolbar>
    <v-divider />
    <v-container>
      <v-row>
        <v-col cols="12" sm="6">
          <v-list-subheader>{{ $t("labels.selected") }}</v-list-subheader>
          <draggable
            v-model="selectedColumns"
            item-key="value"
            group="columns"
            class="draggable-group"
            ghost-class="ghost"
          >
            <template #item="{ element, index }">
              <v-list-item :title="element.text" min-width="300">
                <template #append>
                  <div class="d-flex h-100 align-center">
                    <div class="d-flex h-100 flex-column">
                      <v-btn
                        size="x-small"
                        variant="text"
                        icon="mdi-chevron-up"
                        :disabled="0 === index"
                        @click="moveSelectedColumnUp(index)"
                      />
                      <v-btn
                        size="x-small"
                        variant="text"
                        icon="mdi-chevron-down"
                        :disabled="index === selectedColumns.length - 1"
                        @click="moveSelectedColumnDown(index)"
                      />
                    </div>
                    <v-btn
                      variant="text"
                      icon
                      @click="removeFromSelected(index)"
                    >
                      <v-icon>mdi-close</v-icon>
                    </v-btn>
                  </div>
                </template>
              </v-list-item>
            </template>
          </draggable>
        </v-col>
        <v-col cols="12" sm="6">
          <v-list-subheader>{{ $t("labels.available") }}</v-list-subheader>
          <draggable
            v-model="remainingColumns"
            item-key="value"
            group="columns"
            class="draggable-group"
            ghost-class="ghost"
          >
            <template #item="{ element }">
              <v-list-item :title="element.text" min-width="300">
                <template #append>
                  <div class="d-flex h-100 align-center">
                    <v-btn
                      variant="text"
                      icon
                      @click="addToSelected(element.value)"
                    >
                      <v-icon>mdi-plus</v-icon>
                    </v-btn>
                  </div>
                </template>
              </v-list-item>
            </template>
          </draggable>
        </v-col>
      </v-row>
    </v-container>
    <v-divider />
    <v-toolbar color="transparent" density="compact">
      <v-toolbar-items></v-toolbar-items>
      <v-toolbar-items class="ml-auto">
        <v-btn
          variant="text"
          color="secondary"
          :loading="isApplying"
          @click="apply"
        >
          <v-icon>mdi-check</v-icon>
          <span class="ms-2">{{ $t("labels.apply") }}</span>
        </v-btn>
      </v-toolbar-items>
    </v-toolbar>
  </v-card>
</template>

<script lang="ts">
import { defineComponent, computed } from "vue";
import { useI18n } from "vue-i18n";
import draggable from "vuedraggable";

import type {
  QueryColumn,
  QueryPermissions,
  QueryAvailableFilter,
} from "@/redmine";
import type { PropType } from "vue";

export default defineComponent({
  name: "QueriesPartialColumns",
  components: {
    draggable,
  },
  props: {
    value: {
      type: Array as PropType<Array<string>>,
      required: true,
    },
    options: {
      type: Array as PropType<Array<QueryColumn>>,
      required: true,
    },
    columns: {
      type: Object as PropType<Record<string, QueryAvailableFilter>>,
      required: true,
    },
    permission: {
      type: Object as PropType<QueryPermissions["query"]>,
      required: true,
    },
    type: {
      type: String as PropType<string>,
      required: true,
    },
    isApplying: {
      type: Boolean as PropType<boolean>,
      default: false,
    },
    isSaving: {
      type: Boolean as PropType<boolean>,
      default: false,
    },
    isClearing: {
      type: Boolean as PropType<boolean>,
      default: false,
    },
  },
  emits: ["update:value", "submit", "save"],
  setup(props, { emit }) {
    const { t } = useI18n({ useScope: "global" });
    const val = computed({
      get: () => props.value,
      set: (value: Array<string>) => emit("update:value", value),
    });
    const permission = computed(() => props.permission);
    const apply = () => {
      emit("submit");
    };
    const save = () => {
      if (!permission.value.save) {
        return;
      }
      emit("save");
    };
    const options = computed(() => props.options);
    const columns = computed(() => props.columns);
    const type = computed(() => props.type);
    const getQueryFieldName = (key: string) => {
      if (
        columns.value[key] &&
        columns.value[key].options &&
        columns.value[key].options.name
      ) {
        return columns.value[key].options.name;
      }
      return t(`columns.${type.value.toLowerCase()}.${key}`);
    };
    const displayOptionItems = computed(() =>
      [...options.value].map((o) => ({
        text: getQueryFieldName(o.name),
        value: o.name,
      })),
    );
    const selectedColumns = computed({
      get: () =>
        [...val.value]
          .map((v) => {
            const o = options.value.find((o) => o.name === v);
            if (!o) {
              return undefined;
            } else {
              return {
                text: getQueryFieldName(o.name),
                value: o.name,
              };
            }
          })
          .filter((v) => v !== undefined),
      set: (value: Array<{ text: string; value: string }>) => {
        val.value = value.map((v) => v.value);
      },
    });
    const remainingColumns = computed({
      get: () =>
        [...displayOptionItems.value].filter(
          (o) => !selectedColumns.value.find((s) => s.value === o.value),
        ),
      set: (value: Array<{ text: string; value: string }>) => {
        const index = val.value.findIndex((v) => v === value[0].value);
        if (index) {
          val.value.splice(index, 1);
        }
      },
    });
    const moveSelectedColumnUp = (index: number) => {
      if (index > 0) {
        const [item] = val.value.splice(index, 1);
        val.value.splice(index - 1, 0, item);
      }
    };
    const moveSelectedColumnDown = (index: number) => {
      if (index < selectedColumns.value.length - 1) {
        const [item] = val.value.splice(index, 1);
        val.value.splice(index + 1, 0, item);
      }
    };
    const removeFromSelected = (index: number) => {
      val.value.splice(index, 1);
    };
    const addToSelected = (value: string) => {
      val.value.push(value);
    };
    return {
      val,
      apply,
      save,
      displayOptionItems,
      selectedColumns,
      remainingColumns,
      moveSelectedColumnUp,
      moveSelectedColumnDown,
      removeFromSelected,
      addToSelected,
    };
  },
});
</script>

<style lang="scss">
.draggable-group {
  .v-list-item {
    cursor: move;
  }

  .ghost {
    opacity: 0.5;
    background: #c8ebfb;
  }
}
</style>

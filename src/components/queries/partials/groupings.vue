<template>
  <QueriesOptionMenu
    v-bind="optionsMenuBindings"
    @submit="onSubmit"
    @reset="onReset"
    @refresh="onRefresh"
  >
    <template #content>
      <v-list-item :subtitle="$t('labels.groupBy')" />
      <v-divider />
      <v-sheet
        color="transparent"
        class="query-groupings-panel my-3"
        min-width="300"
        max-height="400"
      >
        <v-radio-group v-model="groupableColumn" hide-details>
          <v-list-item :title="$t('labels.none')">
            <template #prepend>
              <v-radio :value="null" hide-details />
            </template>
          </v-list-item>
          <v-list-item
            v-for="col in availableColumns"
            :key="col.value"
            :title="col.title"
          >
            <template #prepend>
              <v-radio :value="cloneObject(col)" hide-details />
            </template>
          </v-list-item>
        </v-radio-group>
      </v-sheet>
    </template>
  </QueriesOptionMenu>
</template>

<script lang="ts">
import { defineComponent, computed } from "vue";
import {
  useSystemSurfaceColor,
  useSystemAccentColor,
  cloneObject,
} from "@/utils/app";
import { useI18n } from "vue-i18n";
import QueriesOptionMenu from "./option-menu.vue";

import type { PropType } from "vue";
import type { QueryData, Column } from "@/friday";

export default defineComponent({
  name: "QueriesPartialGroupings",
  components: {
    QueriesOptionMenu,
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
    const groupableColumnsCount = computed(() => {
      return modelValue.value.columns.current.groupable.length;
    });
    const groupableColumnsColor = computed(() =>
      groupableColumnsCount.value > 0 ? accentColor.value : surfaceColor.value,
    );
    const optionsMenuBindings = computed(() => ({
      class: ["me-2", "my-2"],
      dirty: dirty.value,
      submitting: submitting.value,
      color: groupableColumnsColor.value,
      icon: "mdi-group",
      title: t("labels.groupings"),
      count: groupableColumnsCount.value,
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
    const groupableColumn = computed<Column | null>({
      get: () => modelValue.value.columns.current.groupable[0] || null,
      set: (value: Column | null) => {
        if (value) {
          modelValue.value.columns.current.groupable = [cloneObject(value)];
        } else {
          modelValue.value.columns.current.groupable = [];
        }
        console.log(modelValue.value.columns.current.groupable);
      },
    });
    const availableColumns = computed(
      () => modelValue.value.columns.available.groupable,
    );
    return {
      optionsMenuBindings,
      onSubmit,
      onReset,
      onRefresh,
      groupableColumn,
      availableColumns,
      cloneObject,
    };
  },
});
</script>

<style lang="scss">
.query-groupings-panel {
  overflow-y: auto;
  overflow-x: hidden;
}
</style>

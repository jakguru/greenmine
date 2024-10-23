<template>
  <QueriesOptionMenu
    v-bind="optionsMenuBindings"
    @submit="onSubmit"
    @reset="onReset"
    @refresh="onRefresh"
  >
    <template #content>
      <v-container>
        <v-row>
          <v-col v-if="availableBlock.length > 0" cols="12" :sm="smColSize">
            <v-list-item :subtitle="$t('labels.showExpandable')" />
            <v-divider />
            <v-sheet
              color="transparent"
              class="query-options-panel my-3"
              min-width="300"
              max-height="400"
            >
              <v-list-item
                v-for="col in availableBlock"
                :key="col.value"
                :title="col.title"
              >
                <template #prepend>
                  <v-checkbox
                    v-model="currentBlock"
                    :value="cloneObject(col)"
                    hide-details
                    multiple
                  />
                </template>
              </v-list-item>
            </v-sheet>
          </v-col>
          <v-col v-if="availableTotalable.length > 0" cols="12" :sm="smColSize">
            <v-list-item :subtitle="$t('labels.showTotalsFor')" />
            <v-divider />
            <v-sheet
              color="transparent"
              class="query-options-panel my-3"
              min-width="300"
              max-height="400"
            >
              <v-list-item
                v-for="col in availableTotalable"
                :key="col.value"
                :title="col.title"
              >
                <template #prepend>
                  <v-checkbox
                    v-model="currentTotalable"
                    :value="cloneObject(col)"
                    hide-details
                    multiple
                  />
                </template>
              </v-list-item>
            </v-sheet>
          </v-col>
        </v-row>
      </v-container>
    </template>
  </QueriesOptionMenu>
</template>

<script lang="ts">
import { defineComponent, computed } from "vue";
import { useSystemAccentColor, cloneObject } from "@/utils/app";
import { useI18n } from "vue-i18n";
import QueriesOptionMenu from "./option-menu.vue";

import type { PropType } from "vue";
import type { QueryData, Column } from "@/friday";

export default defineComponent({
  name: "QueriesPartialOptions",
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
    const optionsMenuBindings = computed(() => ({
      class: ["me-2", "my-2"],
      dirty: dirty.value,
      submitting: submitting.value,
      color: accentColor.value,
      icon: "mdi-cogs",
      title: t("labels.more"),
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
    const availableTotalable = computed(() => {
      return modelValue.value.columns.available.totalable;
    });
    const currentTotalable = computed({
      get: () => modelValue.value.columns.current.totalable,
      set: (value: Column[]) => {
        modelValue.value.columns.current.totalable = value;
      },
    });
    const availableBlock = computed(() => {
      return modelValue.value.columns.available.block;
    });
    const currentBlock = computed({
      get: () => modelValue.value.columns.current.block,
      set: (value: Column[]) => {
        modelValue.value.columns.current.block = value;
      },
    });
    const smColSize = computed(() =>
      availableTotalable.value.length > 0 && availableBlock.value.length > 0
        ? 6
        : 12,
    );
    return {
      optionsMenuBindings,
      onSubmit,
      onReset,
      onRefresh,
      cloneObject,
      availableTotalable,
      currentTotalable,
      availableBlock,
      currentBlock,
      smColSize,
    };
  },
});
</script>

<style lang="scss">
.query-options-panel {
  overflow-y: auto;
  overflow-x: hidden;
}
</style>

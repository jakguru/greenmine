<template>
  <v-sheet v-bind="wrapperProps">
    <VChart
      :option="option"
      :autoresize="true"
      :loading="loading"
      :theme="theme"
      :loading-options="loadingOptions"
    />
    <v-dialog v-bind="filterDialogBindings">
      <v-card color="surface">
        <v-toolbar color="transparent" density="compact">
          <v-toolbar-title>{{ $t("charts.filters") }}</v-toolbar-title>
          <v-toolbar-items>
            <v-btn icon="mdi-close" @click="closeFilterDialog" />
          </v-toolbar-items>
        </v-toolbar>
        <v-divider />
        <v-container>
          <slot
            name="filters"
            :loading="loading"
            :min-date="minDate"
            :max-date="maxDate"
          ></slot>
        </v-container>
      </v-card>
    </v-dialog>
    <v-btn
      v-show="!loading"
      color="accent"
      icon="mdi-filter"
      size="x-small"
      :style="{ position: 'absolute', bottom: '5px', right: '5px' }"
      @click="openFilterDialog"
    />
  </v-sheet>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import VChart from "vue-echarts";
import type { PropType } from "vue";
export default defineComponent({
  name: "BaseChart",
  components: { VChart },
  props: {
    doLoad: {
      type: Function as PropType<() => void>,
      required: true,
    },
    wrapperProps: {
      type: Object as PropType<Record<string, unknown>>,
      required: true,
    },
    option: {
      type: Object as PropType<Record<string, unknown>>,
      required: true,
    },
    loading: {
      type: Boolean as PropType<boolean>,
      required: true,
    },
    loadingOptions: {
      type: Object as PropType<Record<string, unknown>>,
      required: true,
    },
    theme: {
      type: String as PropType<"dark" | "light">,
      required: true,
    },
    filterDialogBindings: {
      type: Object as PropType<Record<string, unknown>>,
      required: true,
    },
    openFilterDialog: {
      type: Function as PropType<() => void>,
      required: true,
    },
    closeFilterDialog: {
      type: Function as PropType<() => void>,
      required: true,
    },
    minDate: {
      type: String as PropType<string>,
      required: true,
    },
    maxDate: {
      type: String as PropType<string>,
      required: true,
    },
  },
});
</script>

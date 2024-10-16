<template>
  <v-card min-height="100" class="query-filters-panel">
    <v-toolbar color="transparent" density="compact">
      <v-toolbar-items class="ml-auto">
        <!-- <v-btn
          v-if="permission.save"
          variant="text"
          :loading="isSaving"
          @click="save"
        >
          <v-icon>mdi-content-save</v-icon>
          <span class="ms-2">{{ $t("labels.save") }}</span>
        </v-btn> -->
      </v-toolbar-items>
    </v-toolbar>
    <v-divider />

    <v-divider />
    <v-toolbar color="transparent" density="compact">
      <v-toolbar-items></v-toolbar-items>
      <v-toolbar-items class="ml-auto">
        <!-- <v-btn
          variant="text"
          color="secondary"
          :loading="isApplying"
          @click="apply"
        >
          <v-icon>mdi-check</v-icon>
          <span class="ms-2">{{ $t("labels.apply") }}</span>
        </v-btn> -->
      </v-toolbar-items>
    </v-toolbar>
  </v-card>
</template>

<script lang="ts">
import { defineComponent, computed } from "vue";

import type { QueryOptions, QueryPermissions } from "@/redmine";
import type { PropType } from "vue";

export default defineComponent({
  name: "QueriesPartialOptions",
  props: {
    value: {
      type: Object as PropType<QueryOptions>,
      required: true,
    },
    options: {
      type: Array as PropType<Array<string>>,
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
    const val = computed({
      get: () => props.value,
      set: (value: Array<string>) => emit("update:value", value),
    });
    return {
      val,
    };
  },
});
</script>

<template>
  <v-card color="primary" min-height="100" />
</template>

<script lang="ts">
import { defineComponent, computed } from "vue";

import type { QueryColumn, QueryPermissions } from "@/redmine";
import type { PropType } from "vue";

export default defineComponent({
  name: "QueriesPartialColumns",
  props: {
    value: {
      type: Array as PropType<Array<string>>,
      required: true,
    },
    options: {
      type: Array as PropType<Array<QueryColumn>>,
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

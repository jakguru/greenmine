<template>
  <v-list-item three-line>
    <pre>{{ news }}</pre>
  </v-list-item>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import type { News } from "@/redmine";
import type { PropType } from "vue";
export default defineComponent({
  name: "NewsPreview",
  props: {
    news: {
      type: Object as PropType<News>,
      required: true,
    },
  },
});
</script>

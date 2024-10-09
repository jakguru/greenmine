<template>
  <v-container class="page-welcome" :fluid="true">
    <h1 class="text-h5">{{ $t("labels.home") }}</h1>
  </v-container>
</template>

<script lang="ts">
import { defineComponent } from "vue";
export default defineComponent({
  name: "WelcomeIndex",
  props: {
    welcome: {
      type: String,
      required: true,
    },
    news: {
      type: Array,
      required: true,
    },
  },
});
</script>

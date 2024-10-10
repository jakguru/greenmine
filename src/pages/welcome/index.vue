<template>
  <v-container class="page-welcome" :fluid="true">
    <h1 class="text-h5 mb-3">{{ $t("labels.home") }}</h1>
    <v-row>
      <v-col cols="12" md="6">
        <Markdown :raw="welcome" />
      </v-col>
    </v-row>
  </v-container>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { Markdown } from "@/components/rendering/markdown";
export default defineComponent({
  name: "WelcomeIndex",
  components: {
    Markdown,
  },
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

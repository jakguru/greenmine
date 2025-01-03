<template>
  <v-empty-state
    :headline="$t('generics.construction.headline')"
    :title="$t('generics.construction.title')"
    :text="$t('generics.construction.text')"
    :image="constructionImage"
  ></v-empty-state>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import constructionImage from "@/assets/images/construction.svg?url";

export default defineComponent({
  name: "UnderConstruction",
  setup() {
    return {
      constructionImage,
    };
  },
});
</script>

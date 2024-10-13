<template>
  <v-empty-state
    :headline="$t('generics.404.headline')"
    :title="$t('generics.404.title')"
    :text="$t('generics.404.text')"
    :image="fourOhFourImage"
  ></v-empty-state>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import fourOhFourImage from "@/assets/images/404.svg?url";
export default defineComponent({
  name: "NotFound",
  setup() {
    return {
      fourOhFourImage,
    };
  },
});
</script>

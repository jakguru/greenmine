<template>
  <v-empty-state
    :headline="$t('generics.404.headline')"
    :title="$t('generics.404.title')"
    :text="$t('generics.404.text')"
    :image="fourOhFourImage"
  ></v-empty-state>
</template>

<script lang="ts">
import { defineComponent, onMounted } from "vue";
import fourOhFourImage from "@/assets/images/404.svg?url";
import { useHead } from "@unhead/vue";
import { useI18n } from "vue-i18n";

export default defineComponent({
  name: "NotFound",
  setup() {
    const { t } = useI18n({ useScope: "global" });
    onMounted(() => {
      useHead({
        title: t("views.404.title"),
      });
    });
    return {
      fourOhFourImage,
    };
  },
});
</script>

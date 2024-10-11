<template>
  <form
    action="/search"
    method="GET"
    accept-charset="UTF-8"
    class="d-flex align-center"
    @submit="onSubmit"
  >
    <v-text-field
      v-model="searchVal"
      density="compact"
      hide-details
      clearable
      prepend-inner-icon="mdi-magnify"
    />
    <input type="submit" style="display: none" />
  </form>
</template>

<script lang="ts">
import { defineComponent, computed, inject } from "vue";
import { useRouter } from "vue-router";
import { useI18n } from "vue-i18n";
import type { ToastService } from "@jakguru/vueprint";
export default defineComponent({
  name: "GlobalSearchField",
  props: {
    search: {
      type: String,
      default: "",
    },
  },
  emits: ["update:search"],
  setup(props, { emit }) {
    const search = computed(() => props.search);
    const toast = inject<ToastService>("toast");
    const { t } = useI18n({ useScope: "global" });
    const searchVal = computed({
      get: () => search.value,
      set: (val) => emit("update:search", val),
    });
    const router = useRouter();
    const onSubmit = (e: Event) => {
      e.preventDefault();
      if (searchVal.value) {
        router
          .push({
            name: "search",
            query: {
              utf8: "✓",
              q: searchVal.value,
            },
          })
          .catch(() => {
            if (toast) {
              toast.fire({
                icon: "error",
                title: t("errors.search.failed"),
              });
            }
          })
          .finally(() => {
            searchVal.value = "";
          });
      }
    };
    return {
      searchVal,
      onSubmit,
    };
  },
});
</script>

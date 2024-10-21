<template>
  <v-tabs
    density="compact"
    :mandatory="true"
    :show-arrows="true"
    :items="tabs"
    slider-color="accent"
  />
</template>

<script lang="ts">
import { defineComponent, computed } from "vue";
import { useRoute } from "vue-router";
import { useI18n } from "vue-i18n";

import type { QueryData, DefinedQuery } from "@/friday";
import type { PropType } from "vue";

export default defineComponent({
  name: "QueriesTabs",
  components: {},
  props: {
    query: {
      type: Object as PropType<QueryData>,
      required: true,
    },
    queries: {
      type: Array as PropType<Array<DefinedQuery>>,
      required: true,
    },
  },
  setup(props) {
    const { t } = useI18n();
    const route = useRoute();
    const query = computed(() => props.query);
    const queries = computed(() => props.queries);
    const tabs = computed(() => {
      const ret: any = [];
      ret.push({
        text: t("labels.main"),
        to: { ...route, query: {} },
        exact: true,
      });
      queries.value.forEach((q) => {
        ret.push({
          text: q.name,
          to: { ...route, query: { query_id: q.id } },
          exact: true,
        });
      });
      if (
        query.value.new_record &&
        !(
          "object" !== typeof route.query ||
          null === route.query ||
          Object.keys(route.query).length === 0
        )
      ) {
        ret.push({
          text: t("labels.new"),
          to: { ...route },
          exact: true,
        });
      }
      return ret;
    });
    return {
      tabs,
    };
  },
});
</script>

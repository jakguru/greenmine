<template>
  <v-sheet color="transparent">
    <v-toolbar tag="nav" color="transparent" density="compact">
      <v-tabs
        density="compact"
        :mandatory="true"
        :show-arrows="true"
        :items="tabs"
      />
      <slot name="after-tabs" />
    </v-toolbar>
  </v-sheet>
</template>

<script lang="ts">
import { defineComponent, computed } from "vue";
import { useRoute } from "vue-router";
import { useI18n } from "vue-i18n";

import type { ModelQuery, QueriesQuery, QueryOptions } from "@/redmine";
import type { PropType } from "vue";

export default defineComponent({
  name: "QueriesTabs",
  components: {},
  props: {
    query: {
      type: Object as PropType<ModelQuery>,
      required: true,
    },
    queries: {
      type: Array as PropType<Array<QueriesQuery>>,
      required: true,
    },
    showDefault: {
      type: Boolean,
      default: true,
    },
    defaultName: {
      type: String as PropType<string | undefined>,
      default: undefined,
    },
    options: {
      type: Object as PropType<QueryOptions>,
      required: true,
    },
  },
  setup(props) {
    const { t } = useI18n();
    const route = useRoute();
    const query = computed(() => props.query);
    const queries = computed(() => props.queries);
    const showDefault = computed(() => props.showDefault);
    const defaultName = computed(() => props.defaultName || t("labels.all"));
    const tabs = computed(() => {
      const ret = [];
      if (showDefault.value) {
        ret.push({
          text: defaultName.value,
          to: { ...route, query: {} },
          exact: true,
        });
      }
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

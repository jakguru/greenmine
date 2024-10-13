<template>
  <div v-if="projects" class="page-projects">
    <v-container :fluid="true">
      <h1 class="text-h5 mb-3">
        <span>{{ $t("pages.projects.title") }}</span>
        <v-btn
          icon="mdi-rss-box"
          class="ms-3"
          size="x-small"
          :href="routePathForAtom"
          target="_blank"
          color="secondary"
        ></v-btn>
        <v-btn
          icon="mdi-file-delimited"
          class="ms-3"
          size="x-small"
          :href="routePathForCsv"
          target="_blank"
          color="secondary"
        ></v-btn>
      </h1>
      <QueriesForm
        :query="query"
        :queries="queries"
        :options="appData.queries.projects"
        :permission="permissions.query"
      />
    </v-container>
  </div>
</template>

<script lang="ts">
import { defineComponent, computed } from "vue";
import { useRoute } from "vue-router";
import { QueriesForm } from "@/components/queries";
import { useAppData } from "@/utils/app";
import qs from "qs";

import type { ProjectsProject, ModelQuery, QueriesQuery } from "@/redmine";
import type { PropType } from "vue";
export default defineComponent({
  name: "ProjectsIndex",
  components: {
    QueriesForm,
  },
  props: {
    projects: {
      type: Array as PropType<ProjectsProject[]>,
      required: true,
    },
    permissions: {
      type: Object as PropType<Record<string, any>>,
      required: true,
    },
    queries: {
      type: Array as PropType<Array<QueriesQuery>>,
      required: true,
    },
    query: {
      type: Object as PropType<ModelQuery>,
      required: true,
    },
  },
  setup(props) {
    const query = computed(() => props.query);
    const route = useRoute();
    const routePathForAtom = computed(() => {
      let ret = `${route.path}.atom`;
      if (
        "object" === typeof route.query &&
        null !== route.query &&
        Object.keys(route.query).length > 0 &&
        !query.value.new_record
      ) {
        ret += `?${qs.stringify(route.query)}`;
      }
      return ret;
    });
    const routePathForCsv = computed(() => {
      let ret = `${route.path}.csv`;
      if (
        "object" === typeof route.query &&
        null !== route.query &&
        Object.keys(route.query).length > 0 &&
        !query.value.new_record
      ) {
        ret += `?${qs.stringify(route.query)}`;
      }
      return ret;
    });
    const appData = useAppData();
    return { routePathForAtom, routePathForCsv, appData };
  },
});
</script>

<template>
  <v-sheet
    ref="form"
    color="transparent"
    tag="form"
    method="get"
    :action="formSubmitPath"
    @submit="onSubmit"
  >
    <QueriesTabs :query="query" :queries="queries" :options="options" />
    <v-divider />
    <v-toolbar color="transparent">
      <slot name="before-filters" />
      <v-menu v-model="showFilterMenu" :close-on-content-click="false">
        <template #activator="{ props }">
          <v-btn
            v-bind="props"
            variant="elevated"
            :color="appBarColor"
            size="small"
            class="me-2"
          >
            <v-icon class="me-2">mdi-filter</v-icon>
            {{ $t("labels.filters") }}
            <v-icon class="ms-2">{{
              showFilterMenu ? "mdi-menu-up" : "mdi-menu-down"
            }}</v-icon>
          </v-btn>
        </template>
        <v-card color="primary" min-height="100" />
      </v-menu>
      <v-menu v-model="showColumnsMenu" :close-on-content-click="false">
        <template #activator="{ props }">
          <v-btn
            v-bind="props"
            variant="elevated"
            :color="appBarColor"
            size="small"
            class="me-2"
          >
            <v-icon class="me-2">mdi-view-column</v-icon>
            {{ $t("labels.columns") }}
            <v-icon class="ms-2">{{
              showColumnsMenu ? "mdi-menu-up" : "mdi-menu-down"
            }}</v-icon>
          </v-btn>
        </template>
        <v-card color="primary" min-height="100" />
      </v-menu>
      <v-menu v-model="showGroupingMenu" :close-on-content-click="false">
        <template #activator="{ props }">
          <v-btn
            v-bind="props"
            variant="elevated"
            :color="appBarColor"
            size="small"
            class="me-2"
          >
            <v-icon class="me-2">mdi-group</v-icon>
            {{ $t("labels.groupings") }}
            <v-icon class="ms-2">{{
              showGroupingMenu ? "mdi-menu-up" : "mdi-menu-down"
            }}</v-icon>
          </v-btn>
        </template>
        <v-card color="primary" min-height="100" />
      </v-menu>
      <v-menu v-model="showOptionsMenu" :close-on-content-click="false">
        <template #activator="{ props }">
          <v-btn
            v-bind="props"
            variant="elevated"
            :color="appBarColor"
            size="small"
            class="me-2"
          >
            <v-icon class="me-2">mdi-cog</v-icon>
            {{ $t("labels.options") }}
            <v-icon class="ms-2">{{
              showOptionsMenu ? "mdi-menu-up" : "mdi-menu-down"
            }}</v-icon>
          </v-btn>
        </template>
        <v-card color="primary" min-height="100" />
      </v-menu>
      <v-btn
        variant="elevated"
        color="secondary"
        size="small"
        class="me-2"
        type="submit"
      >
        <v-icon class="me-2">mdi-check</v-icon>
        {{ $t("labels.apply") }}
      </v-btn>
      <v-btn
        v-if="canClearRoute"
        variant="elevated"
        color="secondary"
        size="small"
        class="me-2"
        :to="clearedRoute"
        :exact="true"
      >
        <v-icon class="me-2">mdi-cancel</v-icon>
        {{ $t("labels.clear") }}
      </v-btn>
    </v-toolbar>
  </v-sheet>
</template>

<script lang="ts">
import { defineComponent, ref, computed } from "vue";
import { useSystemAppBarColor } from "@/utils/app";
import { useRoute } from "vue-router";

import QueriesTabs from "./tabs.vue";

import type {
  ModelQuery,
  QueriesQuery,
  QueryOptions,
  QueryPermissions,
} from "@/redmine";
import type { PropType } from "vue";

export default defineComponent({
  name: "QueriesForm",
  components: {
    QueriesTabs,
  },
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
    permission: {
      type: Object as PropType<QueryPermissions>,
      required: true,
    },
  },
  setup(_props) {
    const route = useRoute();
    const appBarColor = useSystemAppBarColor();
    const form = ref<HTMLFormElement | null>(null);
    const showFilterMenu = ref(false);
    const showColumnsMenu = ref(false);
    const showGroupingMenu = ref(false);
    const showOptionsMenu = ref(false);
    const clearedRoute = computed(() => ({ ...route, query: {} }));
    const canClearRoute = computed(() => {
      return (
        "object" === typeof route.query &&
        null !== route.query &&
        Object.keys(route.query).length > 0
      );
    });
    const formSubmitPath = computed(() => route.path);
    const onSubmit = (e: Event) => {
      e.preventDefault();
      console.log("submit");
    };
    return {
      appBarColor,
      form,
      showFilterMenu,
      showColumnsMenu,
      showGroupingMenu,
      showOptionsMenu,
      formSubmitPath,
      clearedRoute,
      canClearRoute,
      onSubmit,
    };
  },
});
</script>

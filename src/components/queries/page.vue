<template>
  <v-container fluid>
    <v-card min-height="100" color="surface">
      <v-sheet
        ref="form"
        color="transparent"
        tag="form"
        method="get"
        :action="$route.path"
        @submit="onSubmit"
      >
        <v-toolbar color="transparent" density="compact">
          <v-toolbar-title class="font-weight-bold" tag="h1">
            {{ title }}
          </v-toolbar-title>
        </v-toolbar>
        <v-toolbar tag="nav" color="transparent" density="compact">
          <QueriesTabs :query="query" :queries="queries" />
        </v-toolbar>
        <v-divider />
        <v-toolbar color="transparent">
          <v-slide-group show-arrows>
            <v-slide-group-item>
              <v-btn-group
                v-if="creatable.length > 0"
                divided
                base-color="accent"
                density="compact"
                class="ms-4 me-2"
                style="height: 24px"
              >
                <v-btn :to="mainCreateable.url" size="x-small">
                  {{ mainCreateable.title }}
                </v-btn>
                <v-menu v-if="additionalCreatable.length > 0">
                  <template #activator="{ props }">
                    <v-btn v-bind="props" icon="mdi-menu-down" size="x-small" />
                  </template>
                  <v-card :color="surfaceColor">
                    <v-list-item
                      v-for="(c, i) in additionalCreatable"
                      :key="`creatable-${i}`"
                      :title="c.title"
                      :to="c.url"
                    />
                  </v-card>
                </v-menu>
              </v-btn-group>
            </v-slide-group-item>
            <v-slide-group-item>
              <QueriesOptionMenu
                v-if="showFiltersMenu"
                class="me-2"
                :color="selectedFiltersColor"
                icon="mdi-filter"
                :title="$t('labels.filters')"
                :count="selectedFiltersCount"
              >
                <template #content>
                  <div>Filters!</div>
                </template>
              </QueriesOptionMenu>
            </v-slide-group-item>
            <v-slide-group-item>
              <QueriesOptionMenu
                v-if="showColumnsMenu"
                class="me-2"
                :color="selectedColumnsColor"
                icon="mdi-view-column"
                :title="$t('labels.columns')"
                :count="selectedColumnsCount"
              >
                <template #content>
                  <div>Columns!</div>
                </template>
              </QueriesOptionMenu>
            </v-slide-group-item>
            <v-slide-group-item>
              <QueriesOptionMenu
                v-if="showGroupingsMenu"
                class="me-2"
                :color="selectedGroupingsColor"
                icon="mdi-group"
                :title="$t('labels.groupings')"
                :count="selectedGroupingsCount"
              >
                <template #content>
                  <div>Groupings!</div>
                </template>
              </QueriesOptionMenu>
            </v-slide-group-item>
            <v-slide-group-item>
              <QueriesOptionMenu
                v-if="showAdditional"
                class="me-2"
                :color="accentColor"
                :title="$t('labels.more')"
              >
                <template #content>
                  <div>More!</div>
                </template>
              </QueriesOptionMenu>
            </v-slide-group-item>
            <v-slide-group-item>
              <v-btn
                variant="elevated"
                :color="accentColor"
                size="x-small"
                class="me-2"
                type="submit"
                height="24px"
                :loading="submitting"
                style="position: relative; top: 1px"
              >
                <v-icon class="me-2">mdi-check</v-icon>
                {{ $t("labels.apply") }}
              </v-btn>
            </v-slide-group-item>
          </v-slide-group>
        </v-toolbar>
      </v-sheet>
    </v-card>
  </v-container>
</template>

<script lang="ts">
import { defineComponent, computed, ref, watch } from "vue";
import { useSystemSurfaceColor, useSystemAccentColor } from "@/utils/app";
import { useRouter } from "vue-router";
import QueriesTabs from "./tabs.vue";
import QueriesOptionMenu from "./partials/option-menu.vue";
import equal from "fast-deep-equal";
import type { PropType } from "vue";
import type {
  QueryResponseParams,
  QueryResponsePayload,
  QueryData,
  DefinedQuery,
  Permissions,
  Createable,
} from "@/friday";
export default defineComponent({
  name: "QueriesPage",
  components: {
    QueriesTabs,
    QueriesOptionMenu,
  },
  props: {
    title: {
      type: String,
      required: true,
    },
    params: {
      type: Object as PropType<QueryResponseParams>,
      required: true,
    },
    payload: {
      type: Object as PropType<QueryResponsePayload>,
      required: true,
    },
    query: {
      type: Object as PropType<QueryData>,
      required: true,
    },
    queries: {
      type: Array as PropType<Array<DefinedQuery>>,
      required: true,
    },
    permissions: {
      type: Object as PropType<Permissions>,
      required: true,
    },
    creatable: {
      type: Array as PropType<Array<Createable>>,
      required: true,
    },
  },
  setup(props) {
    const router = useRouter();
    const query = computed(() => props.query);
    const value = ref<QueryData>(query.value);
    const dirty = computed(() => equal(query.value, value.value));
    watch(
      () => query.value,
      (v) => {
        value.value = v;
      },
      { immediate: true, deep: true },
    );
    const createable = computed(() => {
      return props.creatable;
    });
    const mainCreateable = computed(() => [...createable.value][0]);
    const additionalCreatable = computed(() =>
      [...createable.value].filter((c) => c !== mainCreateable.value),
    );
    const surfaceColor = useSystemSurfaceColor();
    const accentColor = useSystemAccentColor();
    const submitting = ref(false);
    const onSubmit = (e?: Event) => {
      if (e) {
        e.preventDefault();
        e.stopPropagation();
      }
      const payload = {};
      console.log("submit", payload, value.value);
    };
    const showFiltersMenu = computed(() => {
      return Object.keys(query.value.filters.available).length > 0;
    });
    const selectedFiltersCount = computed(() => {
      return Object.keys(query.value.filters.current).length;
    });
    const selectedFiltersColor = computed(() =>
      selectedFiltersCount.value > 0 ? accentColor.value : surfaceColor.value,
    );
    const showColumnsMenu = computed(() => {
      return (
        query.value.display.current === "list" &&
        query.value.columns.available.inline.length > 0
      );
    });
    const selectedColumnsCount = computed(() => {
      return query.value.columns.current.inline.length;
    });
    const selectedColumnsColor = computed(() =>
      selectedColumnsCount.value > 0 ? accentColor.value : surfaceColor.value,
    );
    const showGroupingsMenu = computed(() => {
      return (
        query.value.display.current === "list" &&
        query.value.columns.available.groupable.length > 0
      );
    });
    const selectedGroupingsCount = computed(() => {
      return query.value.columns.current.groupable.length;
    });
    const selectedGroupingsColor = computed(() =>
      selectedGroupingsCount.value > 0 ? accentColor.value : surfaceColor.value,
    );
    const showBlockable = computed(() => {
      return query.value.columns.available.block.length > 0;
    });
    const showTotalable = computed(() => {
      return query.value.columns.available.totalable.length > 0;
    });
    const showAdditional = computed(() => {
      return showBlockable.value || showTotalable.value;
    });
    router.afterEach(() => {
      submitting.value = false;
    });
    return {
      onSubmit,
      surfaceColor,
      accentColor,
      mainCreateable,
      additionalCreatable,
      showFiltersMenu,
      selectedFiltersCount,
      selectedFiltersColor,
      showColumnsMenu,
      selectedColumnsCount,
      selectedColumnsColor,
      showGroupingsMenu,
      selectedGroupingsCount,
      selectedGroupingsColor,
      value,
      dirty,
      submitting,
      showAdditional,
    };
  },
});
</script>

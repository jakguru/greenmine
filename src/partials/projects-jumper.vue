<template>
  <v-card :color="systemSurfaceColor" width="320">
    <v-list class="bg-transparent transparent py-0">
      <v-list-item
        v-if="hasSomeProject"
        class="py-3"
        tag="form"
        action="#"
        method="GET"
        @submit="onSearchSubmit"
      >
        <v-text-field
          v-model="searchVal"
          density="compact"
          hide-details
          clearable
          prepend-inner-icon="mdi-magnify"
        />
        <input type="submit" style="display: none" />
      </v-list-item>
      <v-divider v-if="hasSomeProject" />
      <v-list-subheader v-if="appData.projects.recent.length > 0">{{
        $t("labels.jumper.recent")
      }}</v-list-subheader>
      <v-list-item
        v-for="(project, i) in recent"
        :key="i.toString()"
        v-bind="project"
      />
      <v-list-subheader v-if="appData.projects.bookmarked.length > 0">{{
        $t("labels.jumper.bookmarked")
      }}</v-list-subheader>
      <v-list-item
        v-for="(project, i) in bookmarked"
        :key="i.toString()"
        v-bind="project"
      />
      <v-list-subheader v-if="appData.projects.active.length > 0">{{
        $t("labels.jumper.all")
      }}</v-list-subheader>
      <v-list-item
        v-for="(project, i) in active"
        :key="i.toString()"
        v-bind="project"
      />
      <v-divider v-if="hasSomeProject" />
      <v-list-item
        :to="{ name: 'projects' }"
        :title="$t('labels.jumper.all')"
      />
    </v-list>
  </v-card>
</template>

<script lang="ts">
import { defineComponent, computed } from "vue";
import type { JumpProject } from "@/redmine";
export default defineComponent({
  name: "PartialProjectsJumper",
  props: {
    systemSurfaceColor: {
      type: String,
      default: "primary",
    },
    appData: {
      type: Object,
      required: true,
    },
    search: {
      type: String,
      default: "",
    },
  },
  emits: ["update:search", "submit:search"],
  setup(props, { emit }) {
    const appData = computed(() => props.appData);
    const search = computed(() => props.search);
    const searchVal = computed({
      get: () => search.value,
      set: (val) => emit("update:search", val),
    });
    const onSearchSubmit = (e: Event) => {
      e.preventDefault();
      emit("submit:search");
    };
    const hasSomeProject = computed(() => {
      return (
        appData.value.projects.recent.length > 0 ||
        appData.value.projects.bookmarked.length > 0 ||
        appData.value.projects.active.length > 0
      );
    });
    const jumpProjectToVListItemBindings = (project: JumpProject) => {
      const classes = new Set<string>();
      if (project.level > 0) {
        classes.add("ps-" + project.level + 2);
      }
      return {
        to: { name: "projects-id", params: { id: project.id.toString() } },
        title: project.name,
        class: [...classes],
      };
    };
    const recent = computed(() =>
      [...appData.value.projects.recent].map(jumpProjectToVListItemBindings),
    );
    const bookmarked = computed(() =>
      [...appData.value.projects.bookmarked].map(
        jumpProjectToVListItemBindings,
      ),
    );
    const active = computed(() =>
      [...appData.value.projects.active].map(jumpProjectToVListItemBindings),
    );
    return {
      searchVal,
      onSearchSubmit,
      hasSomeProject,
      recent,
      bookmarked,
      active,
    };
  },
});
</script>

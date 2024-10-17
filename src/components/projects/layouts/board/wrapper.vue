<template>
  <v-row class="project-board-wrapper">
    <v-col v-for="project in tree" :key="project.id" cols="12" sm="6" lg="4">
      <ProjectsLayoutsBoardPanel :project="project" />
    </v-col>
  </v-row>
</template>

<script lang="ts">
import { defineComponent, computed } from "vue";
import ProjectsLayoutsBoardPanel from "./panel.vue";

import type { ProjectsProject } from "@/redmine";
import type { PropType } from "vue";
import type { ProjectsProjectTree } from "./";

export default defineComponent({
  name: "ProjectsLayoutsBoardWrapper",
  components: {
    ProjectsLayoutsBoardPanel,
  },
  props: {
    projects: {
      type: Array as PropType<ProjectsProject[]>,
      required: true,
    },
  },
  setup(props) {
    const projects = computed(() => props.projects);
    const tree = computed<ProjectsProjectTree[]>(() => {
      const tree: ProjectsProjectTree[] = [];
      const map: Record<number, ProjectsProjectTree> = {};
      projects.value.forEach((project) => {
        map[project.id] = { ...project, children: [] };
      });
      projects.value.forEach((project) => {
        if (project.parent_id) {
          if (map[project.parent_id]) {
            map[project.parent_id].children?.push(map[project.id]);
          }
        } else {
          tree.push(map[project.id]);
        }
      });
      return tree;
    });
    return {
      tree,
    };
  },
});
</script>

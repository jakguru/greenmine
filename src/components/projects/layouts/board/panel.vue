<template>
  <v-card color="surface" class="project-board-project">
    <v-list-item two-line>
      <v-list-item-title>
        <RouterLink :to="to" class="text-h6">
          {{ project.name }}
        </RouterLink>
      </v-list-item-title>
      <v-list-item-subtitle>
        <code v-if="project.homepage">
          <a :href="project.homepage" target="_blank">
            {{ project.homepage }}
          </a>
        </code>
      </v-list-item-subtitle>
    </v-list-item>
    <v-divider />
    <v-toolbar color="transparent" density="compact">
      <v-icon :color="publicityIconInfo.color" class="ms-3">
        {{ publicityIconInfo.icon }}
      </v-icon>
      <v-icon :color="statusIconInfo.color" class="ms-3">
        {{ statusIconInfo.icon }}
      </v-icon>
    </v-toolbar>
    <v-divider />
    <v-sheet
      color="transparent"
      height="200"
      style="overflow-y: auto"
      class="py-3 px-4"
    >
      <Markdown :raw="project.description" />
    </v-sheet>
    <pre>{{ project }}</pre>
  </v-card>
</template>

<script lang="ts">
import { defineComponent, computed } from "vue";
import { RouterLink } from "vue-router";

import { Markdown } from "@/components/rendering/markdown";

import type { PropType } from "vue";
import type { ProjectsProjectTree } from "./";

export default defineComponent({
  name: "ProjectsLayoutsBoardPanel",
  components: {
    RouterLink,
    Markdown,
  },
  props: {
    project: {
      type: Object as PropType<ProjectsProjectTree>,
      required: true,
    },
  },
  setup(props) {
    const project = computed(() => props.project);
    const to = computed(() => ({
      name: "projects-id",
      params: { id: project.value.id.toString() },
    }));
    const publicityIconInfo = computed(() => ({
      icon: project.value.is_public ? "mdi-earth" : "mdi-lock",
      color: project.value.is_public ? "success" : "error",
    }));
    const statusIconInfo = computed(() => ({
      icon: project.value.status === 1 ? "mdi-check" : "mdi-close",
      color: project.value.status === 1 ? "success" : "error",
    }));
    return {
      to,
      publicityIconInfo,
      statusIconInfo,
    };
  },
});
</script>

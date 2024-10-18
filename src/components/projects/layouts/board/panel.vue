<template>
  <v-card color="surface" class="project-board-project">
    <v-toolbar color="transparent" density="compact">
      <v-toolbar-title>
        <RouterLink :to="to" class="text-h6">
          {{ project.name }}
        </RouterLink>
      </v-toolbar-title>
    </v-toolbar>
    <v-divider />
    <v-card-text class="d-flex justify-start align-center">
      <v-chip
        :prepend-icon="publicityIconInfo.icon"
        :color="publicityIconInfo.color"
        class="me-2"
      >
        {{ publicityIconInfo.hint }}
      </v-chip>
      <v-chip
        :prepend-icon="statusIconInfo.icon"
        :color="statusIconInfo.color"
        class="me-2"
      >
        {{ statusIconInfo.hint }}
      </v-chip>
      <v-chip
        v-if="project.homepage"
        color="primary"
        :href="project.homepage"
        target="_blank"
        prepend-icon="mdi-home"
        class="me-2"
      >
        {{ project.homepage }}
      </v-chip>
    </v-card-text>
    <v-divider />
    <v-sheet
      color="transparent"
      max-height="200"
      style="overflow-y: auto"
      class="py-3 px-4"
    >
      <Markdown :raw="project.description" />
    </v-sheet>
    <v-divider v-if="project.children && project.children.length > 0" />
    <v-expansion-panels v-if="project.children && project.children.length > 0">
      <v-expansion-panel
        v-for="child in project.children"
        :key="child.id"
        :title="child.name"
      >
        <template #text>
          <ProjectsLayoutsBoardPanel :project="child" />
        </template>
      </v-expansion-panel>
    </v-expansion-panels>
  </v-card>
</template>

<script lang="ts">
import { defineComponent, computed } from "vue";
import { RouterLink } from "vue-router";
import { useI18n } from "vue-i18n";

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
      params: { id: project.value.identifier.toString() },
    }));
    const { t } = useI18n({ useScope: "global" });
    const publicityIconInfo = computed(() => ({
      icon: project.value.is_public ? "mdi-earth" : "mdi-lock",
      color: project.value.is_public ? "success" : "error",
      hint: t(
        project.value.is_public ? t("labels.public") : t("labels.private"),
      ),
    }));
    const statusIconInfo = computed(() => ({
      icon: project.value.status === 1 ? "mdi-check" : "mdi-close",
      color: project.value.status === 1 ? "success" : "error",
      hint: t(
        project.value.status === 1 ? t("labels.active") : t("labels.archived"),
      ),
    }));
    return {
      to,
      publicityIconInfo,
      statusIconInfo,
    };
  },
});
</script>

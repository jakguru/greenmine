<template>
  <div>
    <v-progress-circular v-if="loading" indeterminate color="primary" />
    <RouterLink v-else-if="show" :to="routerLinkTo">
      {{ project ? project.name : "" }}
    </RouterLink>
  </div>
</template>

<script lang="ts">
import { defineComponent, computed, ref, watch, inject } from "vue";
import { RouterLink } from "vue-router";
import type { ApiService } from "@jakguru/vueprint";
import type { PropType } from "vue";

interface GetProjectByIdData {
  id: number;
  identifier: string;
  name: string;
}

export default defineComponent({
  name: "ProjectById",
  components: {
    RouterLink,
  },
  props: {
    projectId: {
      type: [String, Number] as PropType<string | number | null>,
      required: true,
    },
  },
  setup(props) {
    const api = inject<ApiService>("api");
    const projectId = computed(() => props.projectId);
    const project = ref<GetProjectByIdData | null>(null);
    const loading = ref(false);
    const show = computed(
      () =>
        !loading.value &&
        "object" === typeof project.value &&
        null !== project.value,
    );
    const loadProject = async () => {
      if (null === projectId.value) {
        project.value = null;
        return;
      }
      loading.value = true;
      if (api) {
        const { status, data } = await api.get<GetProjectByIdData>(
          `/ui/data/project-by-id/${projectId.value}`,
        );
        if (200 === status) {
          project.value = data;
        } else {
          project.value = null;
        }
      }
      loading.value = false;
    };
    watch(() => projectId.value, loadProject, { immediate: true });
    const routerLinkTo = computed(() => ({
      name: "projects-id",
      params: {
        id: project.value ? project.value.id : 0,
      },
    }));
    return {
      loading,
      show,
      routerLinkTo,
      project,
    };
  },
});
</script>

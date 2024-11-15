<template>
  <v-container fluid>
    <v-card min-height="100" color="surface">
      <v-toolbar color="transparent" density="compact">
        <v-toolbar-title class="font-weight-bold d-flex align-center" tag="h1">
          <v-icon size="20" class="me-3" style="position: relative; top: -2px">
            mdi-note-multiple
          </v-icon>
          {{ $t("pages.trackers.admin.title") }}
        </v-toolbar-title>
      </v-toolbar>
      <v-divider />
      <TrackerForm
        :form-authenticity-token="formAuthenticityToken"
        name="values"
        :values="trackers"
        :core-fields="coreFields"
        :issue-custom-fields="issueCustomFields"
        :projects="projects"
        :statuses="statuses"
      />
    </v-card>
  </v-container>
</template>

<script lang="ts">
import { defineComponent, inject, onMounted, onBeforeUnmount } from "vue";
import TrackerForm from "@/components/forms/tracker.vue";
import { useReloadRouteData } from "@/utils/app";
import { useRoute } from "vue-router";
import type { Tracker, SelectableListItem } from "@/friday";
import type { PropType } from "vue";
import { BusService, ApiService, ToastService } from "@jakguru/vueprint";

export default defineComponent({
  name: "TrackerIndex",
  components: {
    TrackerForm,
  },
  props: {
    formAuthenticityToken: {
      type: String,
      required: true,
    },
    coreFields: {
      type: Array as PropType<SelectableListItem<string>[]>,
      required: true,
    },
    issueCustomFields: {
      type: Array as PropType<SelectableListItem<number>[]>,
      required: true,
    },
    projects: {
      type: Array as PropType<SelectableListItem<number>[]>,
      required: true,
    },
    statuses: {
      type: Array as PropType<SelectableListItem<number>[]>,
      required: true,
    },
    trackers: {
      type: Array as PropType<Tracker[]>,
      required: true,
    },
  },
  setup() {
    const bus = inject<BusService>("bus");
    const api = inject<ApiService>("api");
    const toast = inject<ToastService>("toast");
    const route = useRoute();
    const routeDataReloader = useReloadRouteData(route, api, toast);
    const onRtuTrackeres = () => {
      if (!routeDataReloader.loading.value) {
        routeDataReloader.call();
      }
    };
    onMounted(() => {
      if (bus) {
        bus.on("rtu:trackers", onRtuTrackeres, { local: true });
      }
    });
    onBeforeUnmount(() => {
      if (bus) {
        bus.off("rtu:trackers", onRtuTrackeres);
      }
    });
    return {};
  },
});
</script>

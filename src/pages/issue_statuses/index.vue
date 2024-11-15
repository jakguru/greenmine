<template>
  <v-container fluid>
    <v-card min-height="100" color="surface">
      <v-toolbar color="transparent" density="compact">
        <v-toolbar-title class="font-weight-bold d-flex align-center" tag="h1">
          <v-icon size="20" class="me-3" style="position: relative; top: -2px">
            mdi-note-check
          </v-icon>
          {{ $t("pages.issue-statuses.admin.title") }}
        </v-toolbar-title>
      </v-toolbar>
      <v-divider />
      <IssueStatusForm
        :form-authenticity-token="formAuthenticityToken"
        name="values"
        :values="statuses"
      />
    </v-card>
  </v-container>
</template>

<script lang="ts">
import { defineComponent, inject, onMounted, onBeforeUnmount } from "vue";
import IssueStatusForm from "@/components/forms/status.vue";
import { useReloadRouteData } from "@/utils/app";
import { useRoute } from "vue-router";
import type { IssueStatus } from "@/friday";
import type { PropType } from "vue";
import { BusService, ApiService, ToastService } from "@jakguru/vueprint";

export default defineComponent({
  name: "IssueStatusIndex",
  components: {
    IssueStatusForm,
  },
  props: {
    formAuthenticityToken: {
      type: String,
      required: true,
    },
    statuses: {
      type: Array as PropType<IssueStatus[]>,
      required: true,
    },
  },
  setup() {
    const bus = inject<BusService>("bus");
    const api = inject<ApiService>("api");
    const toast = inject<ToastService>("toast");
    const route = useRoute();
    const routeDataReloader = useReloadRouteData(route, api, toast);
    const onRtuIssueStatuses = () => {
      routeDataReloader.call();
    };
    onMounted(() => {
      if (bus) {
        bus.on("rtu:issue-statuses", onRtuIssueStatuses, { local: true });
      }
    });
    onBeforeUnmount(() => {
      if (bus) {
        bus.off("rtu:issue-statuses", onRtuIssueStatuses);
      }
    });
    return {};
  },
});
</script>

<template>
  <v-container fluid>
    <v-card min-height="100" color="surface">
      <v-toolbar color="transparent" density="compact">
        <v-toolbar-title class="font-weight-bold d-flex align-center" tag="h1">
          <v-icon size="20" class="me-3" style="position: relative; top: -2px">
            mdi-list-box
          </v-icon>
          {{ $t("pages.enumerations.admin.title") }}
        </v-toolbar-title>
      </v-toolbar>
      <v-divider />
      <v-container fluid>
        <v-row>
          <v-col cols="12">
            <EnumerableForm
              :form-authenticity-token="formAuthenticityToken"
              :name="TimeEntryActivity.name"
              :values="TimeEntryActivity.values"
              low-color="#607D8B"
              high-color="#607D8B"
            />
          </v-col>
        </v-row>
        <v-row>
          <v-col cols="12">
            <EnumerableForm
              :form-authenticity-token="formAuthenticityToken"
              :name="IssueImpact.name"
              :values="IssueImpact.values"
            />
          </v-col>
        </v-row>
        <v-row>
          <v-col cols="12">
            <EnumerableForm
              :form-authenticity-token="formAuthenticityToken"
              :name="IssuePriority.name"
              :values="IssuePriority.values"
            />
          </v-col>
        </v-row>
        <v-row>
          <v-col cols="12">
            <EnumerableForm
              :form-authenticity-token="formAuthenticityToken"
              :name="DocumentCategory.name"
              :values="DocumentCategory.values"
              low-color="#607D8B"
              high-color="#607D8B"
            />
          </v-col>
        </v-row>
      </v-container>
    </v-card>
  </v-container>
</template>

<script lang="ts">
import { defineComponent, inject, onMounted, onBeforeUnmount } from "vue";
import EnumerableForm from "@/components/forms/enumerable.vue";
import { useReloadRouteData } from "@/utils/app";
import { useRoute } from "vue-router";
import type { EnumerableProp } from "@/friday";
import type { PropType } from "vue";
import { BusService, ApiService, ToastService } from "@jakguru/vueprint";

export default defineComponent({
  name: "EnumerationsIndex",
  components: {
    EnumerableForm,
  },
  props: {
    formAuthenticityToken: {
      type: String,
      required: true,
    },
    // eslint-disable-next-line vue/prop-name-casing
    DocumentCategory: {
      type: Object as PropType<EnumerableProp>,
      required: true,
    },
    // eslint-disable-next-line vue/prop-name-casing
    IssueImpact: {
      type: Object as PropType<EnumerableProp>,
      required: true,
    },
    // eslint-disable-next-line vue/prop-name-casing
    IssuePriority: {
      type: Object as PropType<EnumerableProp>,
      required: true,
    },
    // eslint-disable-next-line vue/prop-name-casing
    TimeEntryActivity: {
      type: Object as PropType<EnumerableProp>,
      required: true,
    },
  },
  setup() {
    const bus = inject<BusService>("bus");
    const api = inject<ApiService>("api");
    const toast = inject<ToastService>("toast");
    const route = useRoute();
    const routeDataReloader = useReloadRouteData(route, api, toast);
    const onRtuEnumerations = () => {
      if (!routeDataReloader.loading.value) {
        routeDataReloader.call();
      }
    };
    onMounted(() => {
      if (bus) {
        bus.on("rtu:enumerations", onRtuEnumerations, { local: true });
      }
    });
    onBeforeUnmount(() => {
      if (bus) {
        bus.off("rtu:enumerations", onRtuEnumerations);
      }
    });
    return {};
  },
});
</script>

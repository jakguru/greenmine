<template>
  <v-container fluid>
    <v-card min-height="100" color="surface">
      <v-toolbar color="transparent" density="compact">
        <v-toolbar-title class="font-weight-bold d-flex align-center" tag="h1">
          <v-icon size="20" class="me-3" style="position: relative; top: -2px"
            >mdi-information</v-icon
          >
          {{ $t("pages.admin-info.title") }}
        </v-toolbar-title>
      </v-toolbar>
      <v-divider />
      <v-sheet color="transparent" class="py-2">
        <v-list-item>
          <v-list-item-subtitle>{{
            $t("pages.admin-info.content.redmine")
          }}</v-list-item-subtitle>
          <v-list-item-title class="font-weight-bold">{{
            redmine
          }}</v-list-item-title>
        </v-list-item>
        <v-list-item
          v-for="(item, i) in list"
          :key="`admin-info-item-${i}`"
          v-bind="item"
        />
      </v-sheet>
      <v-divider />
      <RenderCode :content="environment" :show-line-numbers="false" />
    </v-card>
  </v-container>
</template>

<script lang="ts">
import { defineComponent, computed, h } from "vue";
import { useI18n } from "vue-i18n";
import { VIcon } from "vuetify/components/VIcon";
import RenderCode from "@/components/rendering/code.vue";

import { PropType } from "vue";

interface Checklist {
  defaultAdministratorAccountChanged: boolean;
  fileRepositoryWritable: boolean;
  pluginAssetsWritable: boolean;
  allMigrationsHaveBeenRun: boolean;
  minimagickAvailable: boolean;
  convertAvailable: boolean;
  gsAvailable: boolean;
  defaultActiveJobQueueChanged?: boolean;
}

export default defineComponent({
  name: "AdminInfo",
  components: {
    RenderCode,
  },
  props: {
    checklist: {
      type: Object as PropType<Checklist>,
      required: true,
    },
    environment: {
      type: String,
      required: true,
    },
    redmine: {
      type: String,
      required: true,
    },
  },
  setup(props) {
    const { t } = useI18n({ useScope: "global" });
    const checklist = computed(() => props.checklist);
    const list = computed(() => [
      {
        title: t(
          "pages.admin-info.content.checklist.defaultAdministratorAccountChanged",
        ),
        appendIcon: () =>
          h(
            VIcon,
            {
              color: checklist.value.defaultAdministratorAccountChanged
                ? "success"
                : "error",
            },
            checklist.value.defaultAdministratorAccountChanged
              ? "mdi-check"
              : "mdi-close",
          ),
      },
      {
        title: t("pages.admin-info.content.checklist.fileRepositoryWritable"),
        appendIcon: () =>
          h(
            VIcon,
            {
              color: checklist.value.fileRepositoryWritable
                ? "success"
                : "error",
            },
            checklist.value.fileRepositoryWritable ? "mdi-check" : "mdi-close",
          ),
      },
      {
        title: t("pages.admin-info.content.checklist.pluginAssetsWritable"),
        appendIcon: () =>
          h(
            VIcon,
            {
              color: checklist.value.pluginAssetsWritable ? "success" : "error",
            },
            checklist.value.pluginAssetsWritable ? "mdi-check" : "mdi-close",
          ),
      },
      {
        title: t("pages.admin-info.content.checklist.allMigrationsHaveBeenRun"),
        appendIcon: () =>
          h(
            VIcon,
            {
              color: checklist.value.allMigrationsHaveBeenRun
                ? "success"
                : "error",
            },
            checklist.value.allMigrationsHaveBeenRun
              ? "mdi-check"
              : "mdi-close",
          ),
      },
      {
        title: t("pages.admin-info.content.checklist.minimagickAvailable"),
        appendIcon: () =>
          h(
            VIcon,
            {
              color: checklist.value.minimagickAvailable
                ? "success"
                : "warning",
            },
            checklist.value.minimagickAvailable ? "mdi-check" : "mdi-alert",
          ),
      },
      {
        title: t("pages.admin-info.content.checklist.convertAvailable"),
        appendIcon: () =>
          h(
            VIcon,
            {
              color: checklist.value.convertAvailable ? "success" : "warning",
            },
            checklist.value.convertAvailable ? "mdi-check" : "mdi-alert",
          ),
      },
      {
        title: t("pages.admin-info.content.checklist.gsAvailable"),
        appendIcon: () =>
          h(
            VIcon,
            {
              color: checklist.value.gsAvailable ? "success" : "warning",
            },
            checklist.value.gsAvailable ? "mdi-check" : "mdi-alert",
          ),
      },
      {
        title: t(
          "pages.admin-info.content.checklist.defaultActiveJobQueueChanged",
        ),
        appendIcon: () =>
          h(
            VIcon,
            {
              color: checklist.value.defaultActiveJobQueueChanged
                ? "success"
                : "warning",
            },
            checklist.value.defaultActiveJobQueueChanged
              ? "mdi-check"
              : "mdi-alert",
          ),
      },
    ]);
    return {
      list,
    };
  },
});
</script>

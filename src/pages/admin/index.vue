<template>
  <v-container fluid>
    <v-card min-height="100" color="surface">
      <v-toolbar color="transparent" density="compact">
        <v-toolbar-title class="font-weight-bold d-flex align-center" tag="h1">
          <v-icon size="20" class="me-3" style="position: relative; top: -2px"
            >mdi-cog</v-icon
          >
          {{ $t("pages.admin.title") }}
        </v-toolbar-title>
      </v-toolbar>
      <v-divider />
      <template
        v-for="(item, i) in administrationNav"
        :key="`admin-nav-item-${i}`"
      >
        <v-list-item v-bind="item" :id="`admin-nav-item-${i}`" />
      </template>
    </v-card>
  </v-container>
</template>

<script lang="ts">
import { defineComponent, computed } from "vue";
import { useI18n } from "vue-i18n";

export default defineComponent({
  name: "AdminIndex",
  props: {
    noConfigurationData: {
      type: Boolean,
      required: true,
    },
  },
  setup() {
    const { t } = useI18n({ useScope: "global" });
    const administrationNav = computed(() => [
      {
        title: t("pages.admin-projects.title"),
        prependIcon: "mdi-code-block-braces",
        to: { name: "admin-projects" },
      },
      {
        title: t("pages.users.admin.title"),
        prependIcon: "mdi-account-multiple",
        to: { name: "users" },
      },
      {
        title: t("pages.groups.admin.title"),
        prependIcon: "mdi-account-group",
        to: { name: "groups" },
      },
      {
        title: t("pages.roles.admin.title"),
        prependIcon: "mdi-badge-account",
        to: { name: "roles" },
      },
      {
        title: t("pages.trackers.admin.title"),
        prependIcon: "mdi-note-multiple",
        to: { name: "trackers" },
      },
      {
        title: t("pages.issue-statuses.admin.title"),
        prependIcon: "mdi-note-check",
        to: { name: "issue-statuses" },
      },
      {
        title: t("pages.workflows.admin.title"),
        prependIcon: "mdi-arrow-decision",
        to: { name: "workflows" },
      },
      {
        title: t("pages.custom-fields.admin.title"),
        prependIcon: "mdi-form-textbox",
        to: { name: "custom-fields" },
      },
      {
        title: t("pages.enumerations.admin.title"),
        prependIcon: "mdi-list-box",
        to: { name: "enumerations" },
      },
      {
        title: t("pages.settings.admin.title"),
        prependIcon: "mdi-folder-cog",
        to: { name: "settings" },
      },
      {
        title: t("pages.auth-sources.admin.title"),
        prependIcon: "mdi-shield-account-variant",
        to: { name: "auth-sources" },
      },
      {
        title: t("pages.admin-plugins.title"),
        prependIcon: "mdi-puzzle",
        to: { name: "admin-plugins" },
      },
      {
        title: t("pages.admin-info.title"),
        prependIcon: "mdi-information",
        to: { name: "admin-info" },
      },
    ]);
    return {
      administrationNav,
    };
  },
});
</script>

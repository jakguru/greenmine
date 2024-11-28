import { computed } from "vue";
import { useI18n } from "vue-i18n";
import { useAppData } from "@/utils/app";

export const useAdminNav = () => {
  const { t } = useI18n({ useScope: "global" });
  const appData = useAppData();
  return computed(() =>
    [
      {
        title: t("pages.admin-projects.title"),
        prependIcon: "mdi-code-block-braces",
        to: { name: "projects" },
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
      // {
      //   title: t("pages.auth-sources.admin.title"),
      //   prependIcon: "mdi-shield-account-variant",
      //   to: { name: "auth-sources" },
      // },
      {
        title: t("pages.admin-plugins.title"),
        prependIcon: "mdi-puzzle",
        to: { name: "admin-plugins" },
      },
      {
        title: t("pages.admin-integrations.title"),
        prependIcon: "mdi-relation-many-to-many",
        to: { name: "admin-integrations" },
      },
      {
        title: t("pages.admin-info.title"),
        prependIcon: "mdi-information",
        to: { name: "admin-info" },
      },
      {
        title: t("pages.admin-sidekiq.title"),
        prependIcon: "mdi-queue-first-in-last-out",
        // to: { name: "admin-sidekiq" },
        href: "/admin/sidekiq",
        target: "_blank",
      },
      {
        title: t("pages.admin.menu.title"),
        prependIcon: "mdi-cog",
        to: { name: "admin" },
      },
    ].filter((i) => {
      if (i.href === "/admin/sidekiq" || i.to?.name === "admin-sidekiq") {
        return (
          appData.value && appData.value.friday && appData.value.friday.sidekiq
        );
      } else {
        return true;
      }
    }),
  );
};

import { inject } from "vue";
import { createWebHistory, createRouter } from "vue-router";
import { loadRouteData, loadAppData } from "@/utils/app";
import { useRouteDataStore } from "@/stores/routeData";
import { useAppDataStore } from "@/stores/appData";
import { updateHead } from "@/utils/head";
import type { RouteRecordRaw } from "vue-router";
import type {
  ApiService,
  ToastService,
  LocalStorageService,
} from "@jakguru/vueprint";

const fourOhFour = () => import("@/views/404.vue");

const routes: RouteRecordRaw[] = [
  {
    path: "/search",
    name: "search",
    // component: () => import('@/pages/login/index.vue'),
    component: fourOhFour,
    meta: {
      title: "pages.search.title",
    },
  },
  {
    path: "/",
    name: "home",
    // component: () => import("@/pages/welcome/index.vue"),
    component: () => import("@/pages/welcome/index.vue"),
    meta: {
      title: "pages.home.title",
    },
  },
  {
    path: "/account/activate",
    name: "account-activate",
    // "component": () => import("@/pages/account/activate.vue")
    component: fourOhFour,
    meta: {
      title: "pages.account-activate.title",
    },
  },
  {
    path: "/account/activation_email",
    name: "account-activation-email",
    // "component": () => import("@/pages/account/activation_email.vue")
    component: fourOhFour,
    meta: {
      title: "pages.account-activation-email.title",
    },
  },
  {
    path: "/account/lost_password",
    name: "account-lost-password",
    // "component": () => import("@/pages/account/lost_password.vue")
    component: fourOhFour,
    meta: {
      title: "pages.account-lost-password.title",
    },
  },
  {
    path: "/account/register",
    name: "account-register",
    // "component": () => import("@/pages/account/register.vue")
    component: fourOhFour,
    meta: {
      title: "pages.account-register.title",
    },
  },
  {
    path: "/account/twofa",
    name: "account-twofa",
    // "component": () => import("@/pages/account/twofa.vue")
    component: fourOhFour,
    meta: {
      title: "pages.account-twofa.title",
    },
  },
  {
    path: "/account/twofa/confirm",
    name: "account-twofa-confirm",
    // "component": () => import("@/pages/account/twofa/confirm.vue")
    component: fourOhFour,
    meta: {
      title: "pages.account-twofa-confirm.title",
    },
  },
  {
    path: "/activity",
    name: "activity",
    // "component": () => import("@/pages/activity.vue")
    component: fourOhFour,
    meta: {
      title: "pages.activity.title",
    },
  },
  {
    path: "/admin",
    name: "admin",
    // "component": () => import("@/pages/admin.vue")
    component: fourOhFour,
    meta: {
      title: "pages.admin.title",
    },
  },
  {
    path: "/admin/info",
    name: "admin-info",
    // "component": () => import("@/pages/admin/info.vue")
    component: fourOhFour,
    meta: {
      title: "pages.admin-info.title",
    },
  },
  {
    path: "/admin/plugins",
    name: "admin-plugins",
    // "component": () => import("@/pages/admin/plugins.vue")
    component: fourOhFour,
    meta: {
      title: "pages.admin-plugins.title",
    },
  },
  {
    path: "/admin/projects_context_menu",
    name: "admin-projects-context-menu",
    // "component": () => import("@/pages/admin/projects_context_menu.vue")
    component: fourOhFour,
    meta: {
      title: "pages.admin-projects-context-menu.title",
    },
  },
  {
    path: "/admin/projects",
    name: "admin-projects",
    // "component": () => import("@/pages/admin/projects.vue")
    component: fourOhFour,
    meta: {
      title: "pages.admin-projects.title",
    },
  },
  {
    path: "/attachments/:id",
    name: "attachments-id",
    // "component": () => import("@/pages/attachments/id.vue")
    component: fourOhFour,
    meta: {
      title: "pages.attachments-id.title",
    },
  },
  {
    path: "/attachments/:id/:filename",
    name: "attachments-id-filename",
    // "component": () => import("@/pages/attachments/id/filename.vue")
    component: fourOhFour,
    meta: {
      title: "pages.attachments-id-filename.title",
    },
  },
  {
    path: "/attachments/:object_type/:object_id/download",
    name: "attachments-object-type-object-id-download",
    // "component": () => import("@/pages/attachments/object_type/object_id/download.vue")
    component: fourOhFour,
    meta: {
      title: "pages.attachments-object-type-object-id-download.title",
    },
  },
  {
    path: "/attachments/:object_type/:object_id/edit",
    name: "attachments-object-type-object-id-edit",
    // "component": () => import("@/pages/attachments/object_type/object_id/edit.vue")
    component: fourOhFour,
    meta: {
      title: "pages.attachments-object-type-object-id-edit.title",
    },
  },
  {
    path: "/attachments/download/:id",
    name: "attachments-download-id",
    // "component": () => import("@/pages/attachments/download/id.vue")
    component: fourOhFour,
    meta: {
      title: "pages.attachments-download-id.title",
    },
  },
  {
    path: "/attachments/download/:id/:filename",
    name: "attachments-download-id-filename",
    // "component": () => import("@/pages/attachments/download/id/filename.vue")
    component: fourOhFour,
    meta: {
      title: "pages.attachments-download-id-filename.title",
    },
  },
  {
    path: "/auth_sources",
    name: "auth-sources",
    // "component": () => import("@/pages/auth_sources.vue")
    component: fourOhFour,
    meta: {
      title: "pages.auth-sources.title",
    },
  },
  {
    path: "/auth_sources/:id",
    name: "auth-sources-id",
    // "component": () => import("@/pages/auth_sources/id.vue")
    component: fourOhFour,
    meta: {
      title: "pages.auth-sources-id.title",
    },
  },
  {
    path: "/auth_sources/:id/edit",
    name: "auth-sources-id-edit",
    // "component": () => import("@/pages/auth_sources/id/edit.vue")
    component: fourOhFour,
    meta: {
      title: "pages.auth-sources-id-edit.title",
    },
  },
  {
    path: "/auth_sources/:id/test_connection",
    name: "auth-sources-id-test-connection",
    // "component": () => import("@/pages/auth_sources/id/test_connection.vue")
    component: fourOhFour,
    meta: {
      title: "pages.auth-sources-id-test-connection.title",
    },
  },
  {
    path: "/auth_sources/autocomplete_for_new_user",
    name: "auth-sources-autocomplete-for-new-user",
    // "component": () => import("@/pages/auth_sources/autocomplete_for_new_user.vue")
    component: fourOhFour,
    meta: {
      title: "pages.auth-sources-autocomplete-for-new-user.title",
    },
  },
  {
    path: "/auth_sources/new",
    name: "auth-sources-new",
    // "component": () => import("@/pages/auth_sources/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.auth-sources-new.title",
    },
  },
  {
    path: "/boards/:board_id/topics/:id",
    name: "boards-board-id-topics-id",
    // "component": () => import("@/pages/boards/board_id/topics/id.vue")
    component: fourOhFour,
    meta: {
      title: "pages.boards-board-id-topics-id.title",
    },
  },
  {
    path: "/boards/:board_id/topics/:id/edit",
    name: "boards-board-id-topics-id-edit",
    // "component": () => import("@/pages/boards/board_id/topics/id/edit.vue")
    component: fourOhFour,
    meta: {
      title: "pages.boards-board-id-topics-id-edit.title",
    },
  },
  {
    path: "/boards/:board_id/topics/new",
    name: "boards-board-id-topics-new",
    // "component": () => import("@/pages/boards/board_id/topics/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.boards-board-id-topics-new.title",
    },
  },
  {
    path: "/boards/:board_id/topics/quote/:id",
    name: "boards-board-id-topics-quote-id",
    // "component": () => import("@/pages/boards/board_id/topics/quote/id.vue")
    component: fourOhFour,
    meta: {
      title: "pages.boards-board-id-topics-quote-id.title",
    },
  },
  {
    path: "/custom_fields",
    name: "custom-fields",
    // "component": () => import("@/pages/custom_fields.vue")
    component: fourOhFour,
    meta: {
      title: "pages.custom-fields.title",
    },
  },
  {
    path: "/custom_fields/:custom_field_id/enumerations",
    name: "custom-fields-custom-field-id-enumerations",
    // "component": () => import("@/pages/custom_fields/custom_field_id/enumerations.vue")
    component: fourOhFour,
    meta: {
      title: "pages.custom-fields-custom-field-id-enumerations.title",
    },
  },
  {
    path: "/custom_fields/:id/edit",
    name: "custom-fields-id-edit",
    // "component": () => import("@/pages/custom_fields/id/edit.vue")
    component: fourOhFour,
    meta: {
      title: "pages.custom-fields-id-edit.title",
    },
  },
  {
    path: "/custom_fields/new",
    name: "custom-fields-new",
    // "component": () => import("@/pages/custom_fields/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.custom-fields-new.title",
    },
  },
  {
    path: "/documents/:id",
    name: "documents-id",
    // "component": () => import("@/pages/documents/id.vue")
    component: fourOhFour,
    meta: {
      title: "pages.documents-id.title",
    },
  },
  {
    path: "/documents/:id/edit",
    name: "documents-id-edit",
    // "component": () => import("@/pages/documents/id/edit.vue")
    component: fourOhFour,
    meta: {
      title: "pages.documents-id-edit.title",
    },
  },
  {
    path: "/enumerations",
    name: "enumerations",
    // "component": () => import("@/pages/enumerations.vue")
    component: fourOhFour,
    meta: {
      title: "pages.enumerations.title",
    },
  },
  {
    path: "/enumerations/:id/edit",
    name: "enumerations-id-edit",
    // "component": () => import("@/pages/enumerations/id/edit.vue")
    component: fourOhFour,
    meta: {
      title: "pages.enumerations-id-edit.title",
    },
  },
  {
    path: "/enumerations/:type",
    name: "enumerations-type",
    // "component": () => import("@/pages/enumerations/type.vue")
    component: fourOhFour,
    meta: {
      title: "pages.enumerations-type.title",
    },
  },
  {
    path: "/enumerations/new",
    name: "enumerations-new",
    // "component": () => import("@/pages/enumerations/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.enumerations-new.title",
    },
  },
  {
    path: "/groups",
    name: "groups",
    // "component": () => import("@/pages/groups.vue")
    component: fourOhFour,
    meta: {
      title: "pages.groups.title",
    },
  },
  {
    path: "/groups/:group_id/memberships",
    name: "groups-group-id-memberships",
    // "component": () => import("@/pages/groups/group_id/memberships.vue")
    component: fourOhFour,
    meta: {
      title: "pages.groups-group-id-memberships.title",
    },
  },
  {
    path: "/groups/:group_id/memberships/:id",
    name: "groups-group-id-memberships-id",
    // "component": () => import("@/pages/groups/group_id/memberships/id.vue")
    component: fourOhFour,
    meta: {
      title: "pages.groups-group-id-memberships-id.title",
    },
  },
  {
    path: "/groups/:group_id/memberships/:id/edit",
    name: "groups-group-id-memberships-id-edit",
    // "component": () => import("@/pages/groups/group_id/memberships/id/edit.vue")
    component: fourOhFour,
    meta: {
      title: "pages.groups-group-id-memberships-id-edit.title",
    },
  },
  {
    path: "/groups/:group_id/memberships/new",
    name: "groups-group-id-memberships-new",
    // "component": () => import("@/pages/groups/group_id/memberships/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.groups-group-id-memberships-new.title",
    },
  },
  {
    path: "/groups/:id",
    name: "groups-id",
    // "component": () => import("@/pages/groups/id.vue")
    component: fourOhFour,
    meta: {
      title: "pages.groups-id.title",
    },
  },
  {
    path: "/groups/:id/autocomplete_for_user",
    name: "groups-id-autocomplete-for-user",
    // "component": () => import("@/pages/groups/id/autocomplete_for_user.vue")
    component: fourOhFour,
    meta: {
      title: "pages.groups-id-autocomplete-for-user.title",
    },
  },
  {
    path: "/groups/:id/edit",
    name: "groups-id-edit",
    // "component": () => import("@/pages/groups/id/edit.vue")
    component: fourOhFour,
    meta: {
      title: "pages.groups-id-edit.title",
    },
  },
  {
    path: "/groups/:id/users/new",
    name: "groups-id-users-new",
    // "component": () => import("@/pages/groups/id/users/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.groups-id-users-new.title",
    },
  },
  {
    path: "/groups/new",
    name: "groups-new",
    // "component": () => import("@/pages/groups/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.groups-new.title",
    },
  },
  {
    path: "/imports/:id",
    name: "imports-id",
    // "component": () => import("@/pages/imports/id.vue")
    component: fourOhFour,
    meta: {
      title: "pages.imports-id.title",
    },
  },
  {
    path: "/imports/:id/mapping",
    name: "imports-id-mapping",
    // "component": () => import("@/pages/imports/id/mapping.vue")
    component: fourOhFour,
    meta: {
      title: "pages.imports-id-mapping.title",
    },
  },
  {
    path: "/imports/:id/run",
    name: "imports-id-run",
    // "component": () => import("@/pages/imports/id/run.vue")
    component: fourOhFour,
    meta: {
      title: "pages.imports-id-run.title",
    },
  },
  {
    path: "/imports/:id/settings",
    name: "imports-id-settings",
    // "component": () => import("@/pages/imports/id/settings.vue")
    component: fourOhFour,
    meta: {
      title: "pages.imports-id-settings.title",
    },
  },
  {
    path: "/issue_categories/:id",
    name: "issue-categories-id",
    // "component": () => import("@/pages/issue_categories/id.vue")
    component: fourOhFour,
    meta: {
      title: "pages.issue-categories-id.title",
    },
  },
  {
    path: "/issue_categories/:id/edit",
    name: "issue-categories-id-edit",
    // "component": () => import("@/pages/issue_categories/id/edit.vue")
    component: fourOhFour,
    meta: {
      title: "pages.issue-categories-id-edit.title",
    },
  },
  {
    path: "/issue_statuses",
    name: "issue-statuses",
    // "component": () => import("@/pages/issue_statuses.vue")
    component: fourOhFour,
    meta: {
      title: "pages.issue-statuses.title",
    },
  },
  {
    path: "/issue_statuses/:id/edit",
    name: "issue-statuses-id-edit",
    // "component": () => import("@/pages/issue_statuses/id/edit.vue")
    component: fourOhFour,
    meta: {
      title: "pages.issue-statuses-id-edit.title",
    },
  },
  {
    path: "/issue_statuses/new",
    name: "issue-statuses-new",
    // "component": () => import("@/pages/issue_statuses/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.issue-statuses-new.title",
    },
  },
  {
    path: "/issues",
    name: "issues",
    // "component": () => import("@/pages/issues.vue")
    component: fourOhFour,
    meta: {
      title: "pages.issues.title",
    },
  },
  {
    path: "/issues/:id",
    name: "issues-id",
    // "component": () => import("@/pages/issues/id.vue")
    component: fourOhFour,
    meta: {
      title: "pages.issues-id.title",
    },
  },
  {
    path: "/issues/:id/edit",
    name: "issues-id-edit",
    // "component": () => import("@/pages/issues/id/edit.vue")
    component: fourOhFour,
    meta: {
      title: "pages.issues-id-edit.title",
    },
  },
  {
    path: "/issues/:id/tab/:name",
    name: "issues-id-tab-name",
    // "component": () => import("@/pages/issues/id/tab/name.vue")
    component: fourOhFour,
    meta: {
      title: "pages.issues-id-tab-name.title",
    },
  },
  {
    path: "/issues/:issue_id/relations",
    name: "issues-issue-id-relations",
    // "component": () => import("@/pages/issues/issue_id/relations.vue")
    component: fourOhFour,
    meta: {
      title: "pages.issues-issue-id-relations.title",
    },
  },
  {
    path: "/issues/:issue_id/time_entries/new",
    name: "issues-issue-id-time-entries-new",
    // "component": () => import("@/pages/issues/issue_id/time_entries/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.issues-issue-id-time-entries-new.title",
    },
  },
  {
    path: "/issues/auto_complete",
    name: "issues-auto-complete",
    // "component": () => import("@/pages/issues/auto_complete.vue")
    component: fourOhFour,
    meta: {
      title: "pages.issues-auto-complete.title",
    },
  },
  {
    path: "/issues/bulk_edit",
    name: "issues-bulk-edit",
    // "component": () => import("@/pages/issues/bulk_edit.vue")
    component: fourOhFour,
    meta: {
      title: "pages.issues-bulk-edit.title",
    },
  },
  {
    path: "/issues/calendar",
    name: "issues-calendar",
    // "component": () => import("@/pages/issues/calendar.vue")
    component: fourOhFour,
    meta: {
      title: "pages.issues-calendar.title",
    },
  },
  {
    path: "/issues/changes",
    name: "issues-changes",
    // "component": () => import("@/pages/issues/changes.vue")
    component: fourOhFour,
    meta: {
      title: "pages.issues-changes.title",
    },
  },
  {
    path: "/issues/context_menu",
    name: "issues-context-menu",
    // "component": () => import("@/pages/issues/context_menu.vue")
    component: fourOhFour,
    meta: {
      title: "pages.issues-context-menu.title",
    },
  },
  {
    path: "/issues/gantt",
    name: "issues-gantt",
    // "component": () => import("@/pages/issues/gantt.vue")
    component: fourOhFour,
    meta: {
      title: "pages.issues-gantt.title",
    },
  },
  {
    path: "/issues/imports/new",
    name: "issues-imports-new",
    // "component": () => import("@/pages/issues/imports/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.issues-imports-new.title",
    },
  },
  {
    path: "/issues/new",
    name: "issues-new",
    // "component": () => import("@/pages/issues/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.issues-new.title",
    },
  },
  {
    path: "/issues/preview",
    name: "issues-preview",
    // "component": () => import("@/pages/issues/preview.vue")
    component: fourOhFour,
    meta: {
      title: "pages.issues-preview.title",
    },
  },
  {
    path: "/journals/:id/diff",
    name: "journals-id-diff",
    // "component": () => import("@/pages/journals/id/diff.vue")
    component: fourOhFour,
    meta: {
      title: "pages.journals-id-diff.title",
    },
  },
  {
    path: "/journals/:id/edit",
    name: "journals-id-edit",
    // "component": () => import("@/pages/journals/id/edit.vue")
    component: fourOhFour,
    meta: {
      title: "pages.journals-id-edit.title",
    },
  },
  {
    path: "/login",
    name: "login",
    // "component": () => import("@/pages/login.vue")
    component: fourOhFour,
    meta: {
      title: "pages.login.title",
    },
  },
  {
    path: "/mail_handler",
    name: "mail-handler",
    // "component": () => import("@/pages/mail_handler.vue")
    component: fourOhFour,
    meta: {
      title: "pages.mail-handler.title",
    },
  },
  {
    path: "/memberships/:id",
    name: "memberships-id",
    // "component": () => import("@/pages/memberships/id.vue")
    component: fourOhFour,
    meta: {
      title: "pages.memberships-id.title",
    },
  },
  {
    path: "/memberships/:id/edit",
    name: "memberships-id-edit",
    // "component": () => import("@/pages/memberships/id/edit.vue")
    component: fourOhFour,
    meta: {
      title: "pages.memberships-id-edit.title",
    },
  },
  {
    path: "/my",
    name: "my",
    // "component": () => import("@/pages/my.vue")
    component: fourOhFour,
    meta: {
      title: "pages.my.title",
    },
  },
  {
    path: "/my/account",
    name: "my-account",
    // "component": () => import("@/pages/my/account.vue")
    component: fourOhFour,
    meta: {
      title: "pages.my-account.title",
    },
  },
  {
    path: "/my/account/destroy",
    name: "my-account-destroy",
    // "component": () => import("@/pages/my/account/destroy.vue")
    component: fourOhFour,
    meta: {
      title: "pages.my-account-destroy.title",
    },
  },
  {
    path: "/my/api_key",
    name: "my-api-key",
    // "component": () => import("@/pages/my/api_key.vue")
    component: fourOhFour,
    meta: {
      title: "pages.my-api-key.title",
    },
  },
  {
    path: "/my/page",
    name: "my-page",
    // "component": () => import("@/pages/my/page.vue")
    component: fourOhFour,
    meta: {
      title: "pages.my-page.title",
    },
  },
  {
    path: "/my/password",
    name: "my-password",
    // "component": () => import("@/pages/my/password.vue")
    component: fourOhFour,
    meta: {
      title: "pages.my-password.title",
    },
  },
  {
    path: "/my/twofa/:scheme/activate",
    name: "my-twofa-scheme-activate",
    // "component": () => import("@/pages/my/twofa/scheme/activate.vue")
    component: fourOhFour,
    meta: {
      title: "pages.my-twofa-scheme-activate.title",
    },
  },
  {
    path: "/my/twofa/:scheme/activate/confirm",
    name: "my-twofa-scheme-activate-confirm",
    // "component": () => import("@/pages/my/twofa/scheme/activate/confirm.vue")
    component: fourOhFour,
    meta: {
      title: "pages.my-twofa-scheme-activate-confirm.title",
    },
  },
  {
    path: "/my/twofa/:scheme/deactivate",
    name: "my-twofa-scheme-deactivate",
    // "component": () => import("@/pages/my/twofa/scheme/deactivate.vue")
    component: fourOhFour,
    meta: {
      title: "pages.my-twofa-scheme-deactivate.title",
    },
  },
  {
    path: "/my/twofa/:scheme/deactivate/confirm",
    name: "my-twofa-scheme-deactivate-confirm",
    // "component": () => import("@/pages/my/twofa/scheme/deactivate/confirm.vue")
    component: fourOhFour,
    meta: {
      title: "pages.my-twofa-scheme-deactivate-confirm.title",
    },
  },
  {
    path: "/my/twofa/backup_codes",
    name: "my-twofa-backup-codes",
    // "component": () => import("@/pages/my/twofa/backup_codes.vue")
    component: fourOhFour,
    meta: {
      title: "pages.my-twofa-backup-codes.title",
    },
  },
  {
    path: "/my/twofa/backup_codes/confirm",
    name: "my-twofa-backup-codes-confirm",
    // "component": () => import("@/pages/my/twofa/backup_codes/confirm.vue")
    component: fourOhFour,
    meta: {
      title: "pages.my-twofa-backup-codes-confirm.title",
    },
  },
  {
    path: "/my/twofa/backup_codes/create",
    name: "my-twofa-backup-codes-create",
    // "component": () => import("@/pages/my/twofa/backup_codes/create.vue")
    component: fourOhFour,
    meta: {
      title: "pages.my-twofa-backup-codes-create.title",
    },
  },
  {
    path: "/my/twofa/select_scheme",
    name: "my-twofa-select-scheme",
    // "component": () => import("@/pages/my/twofa/select_scheme.vue")
    component: fourOhFour,
    meta: {
      title: "pages.my-twofa-select-scheme.title",
    },
  },
  {
    path: "/news",
    name: "news",
    // "component": () => import("@/pages/news.vue")
    component: fourOhFour,
    meta: {
      title: "pages.news.title",
    },
  },
  {
    path: "/news/:id",
    name: "news-id",
    // "component": () => import("@/pages/news/id.vue")
    component: fourOhFour,
    meta: {
      title: "pages.news-id.title",
    },
  },
  {
    path: "/news/:id/edit",
    name: "news-id-edit",
    // "component": () => import("@/pages/news/id/edit.vue")
    component: fourOhFour,
    meta: {
      title: "pages.news-id-edit.title",
    },
  },
  {
    path: "/news/new",
    name: "news-new",
    // "component": () => import("@/pages/news/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.news-new.title",
    },
  },
  {
    path: "/news/preview",
    name: "news-preview",
    // "component": () => import("@/pages/news/preview.vue")
    component: fourOhFour,
    meta: {
      title: "pages.news-preview.title",
    },
  },
  {
    path: "/preview/text",
    name: "preview-text",
    // "component": () => import("@/pages/preview/text.vue")
    component: fourOhFour,
    meta: {
      title: "pages.preview-text.title",
    },
  },
  {
    path: "/projects",
    name: "projects",
    component: () => import("@/pages/projects/index.vue"),
    meta: {
      title: "pages.projects.title",
    },
  },
  {
    path: "/projects/:id",
    name: "projects-id",
    // "component": () => import("@/pages/projects/id.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-id.title",
    },
  },
  {
    path: "/projects/:id/activity",
    name: "projects-id-activity",
    // "component": () => import("@/pages/projects/id/activity.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-id-activity.title",
    },
  },
  {
    path: "/projects/:id/copy",
    name: "projects-id-copy",
    // "component": () => import("@/pages/projects/id/copy.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-id-copy.title",
    },
  },
  {
    path: "/projects/:id/edit",
    name: "projects-id-edit",
    // "component": () => import("@/pages/projects/id/edit.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-id-edit.title",
    },
  },
  {
    path: "/projects/:id/issues/report",
    name: "projects-id-issues-report",
    // "component": () => import("@/pages/projects/id/issues/report.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-id-issues-report.title",
    },
  },
  {
    path: "/projects/:id/issues/report/:detail",
    name: "projects-id-issues-report-detail",
    // "component": () => import("@/pages/projects/id/issues/report/detail.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-id-issues-report-detail.title",
    },
  },
  {
    path: "/projects/:id/repository",
    name: "projects-id-repository",
    // "component": () => import("@/pages/projects/id/repository.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-id-repository.title",
    },
  },
  {
    path: "/projects/:id/repository/:repository_id",
    name: "projects-id-repository-repository-id",
    // "component": () => import("@/pages/projects/id/repository/repository_id.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-id-repository-repository-id.title",
    },
  },
  {
    path: "/projects/:id/repository/:repository_id/annotate(/*path)",
    name: "projects-id-repository-repository-id-annotate-path",
    // "component": () => import("@/pages/projects/id/repository/repository_id/annotate(/*path).vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-id-repository-repository-id-annotate-path.title",
    },
  },
  {
    path: "/projects/:id/repository/:repository_id/browse(/*path)",
    name: "projects-id-repository-repository-id-browse-path",
    // "component": () => import("@/pages/projects/id/repository/repository_id/browse(/*path).vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-id-repository-repository-id-browse-path.title",
    },
  },
  {
    path: "/projects/:id/repository/:repository_id/changes(/*path)",
    name: "projects-id-repository-repository-id-changes-path",
    // "component": () => import("@/pages/projects/id/repository/repository_id/changes(/*path).vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-id-repository-repository-id-changes-path.title",
    },
  },
  {
    path: "/projects/:id/repository/:repository_id/diff(/*path)",
    name: "projects-id-repository-repository-id-diff-path",
    // "component": () => import("@/pages/projects/id/repository/repository_id/diff(/*path).vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-id-repository-repository-id-diff-path.title",
    },
  },
  {
    path: "/projects/:id/repository/:repository_id/entry(/*path)",
    name: "projects-id-repository-repository-id-entry-path",
    // "component": () => import("@/pages/projects/id/repository/repository_id/entry(/*path).vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-id-repository-repository-id-entry-path.title",
    },
  },
  {
    path: "/projects/:id/repository/:repository_id/graph",
    name: "projects-id-repository-repository-id-graph",
    // "component": () => import("@/pages/projects/id/repository/repository_id/graph.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-id-repository-repository-id-graph.title",
    },
  },
  {
    path: "/projects/:id/repository/:repository_id/raw(/*path)",
    name: "projects-id-repository-repository-id-raw-path",
    // "component": () => import("@/pages/projects/id/repository/repository_id/raw(/*path).vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-id-repository-repository-id-raw-path.title",
    },
  },
  {
    path: "/projects/:id/repository/:repository_id/revision",
    name: "projects-id-repository-repository-id-revision",
    // "component": () => import("@/pages/projects/id/repository/repository_id/revision.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-id-repository-repository-id-revision.title",
    },
  },
  {
    path: "/projects/:id/repository/:repository_id/revisions",
    name: "projects-id-repository-repository-id-revisions",
    // "component": () => import("@/pages/projects/id/repository/repository_id/revisions.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-id-repository-repository-id-revisions.title",
    },
  },
  {
    path: "/projects/:id/repository/:repository_id/revisions/:rev",
    name: "projects-id-repository-repository-id-revisions-rev",
    // "component": () => import("@/pages/projects/id/repository/repository_id/revisions/rev.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-id-repository-repository-id-revisions-rev.title",
    },
  },
  {
    path: "/projects/:id/repository/:repository_id/revisions/:rev/annotate(/*path)",
    name: "projects-id-repository-repository-id-revisions-rev-annotate-path",
    // "component": () => import("@/pages/projects/id/repository/repository_id/revisions/rev/annotate(/*path).vue")
    component: fourOhFour,
    meta: {
      title:
        "pages.projects-id-repository-repository-id-revisions-rev-annotate-path.title",
    },
  },
  {
    path: "/projects/:id/repository/:repository_id/revisions/:rev/browse(/*path)",
    name: "projects-id-repository-repository-id-revisions-rev-browse-path",
    // "component": () => import("@/pages/projects/id/repository/repository_id/revisions/rev/browse(/*path).vue")
    component: fourOhFour,
    meta: {
      title:
        "pages.projects-id-repository-repository-id-revisions-rev-browse-path.title",
    },
  },
  {
    path: "/projects/:id/repository/:repository_id/revisions/:rev/diff(/*path)",
    name: "projects-id-repository-repository-id-revisions-rev-diff-path",
    // "component": () => import("@/pages/projects/id/repository/repository_id/revisions/rev/diff(/*path).vue")
    component: fourOhFour,
    meta: {
      title:
        "pages.projects-id-repository-repository-id-revisions-rev-diff-path.title",
    },
  },
  {
    path: "/projects/:id/repository/:repository_id/revisions/:rev/entry(/*path)",
    name: "projects-id-repository-repository-id-revisions-rev-entry-path",
    // "component": () => import("@/pages/projects/id/repository/repository_id/revisions/rev/entry(/*path).vue")
    component: fourOhFour,
    meta: {
      title:
        "pages.projects-id-repository-repository-id-revisions-rev-entry-path.title",
    },
  },
  {
    path: "/projects/:id/repository/:repository_id/revisions/:rev/raw(/*path)",
    name: "projects-id-repository-repository-id-revisions-rev-raw-path",
    // "component": () => import("@/pages/projects/id/repository/repository_id/revisions/rev/raw(/*path).vue")
    component: fourOhFour,
    meta: {
      title:
        "pages.projects-id-repository-repository-id-revisions-rev-raw-path.title",
    },
  },
  {
    path: "/projects/:id/repository/:repository_id/revisions/:rev/show(/*path)",
    name: "projects-id-repository-repository-id-revisions-rev-show-path",
    // "component": () => import("@/pages/projects/id/repository/repository_id/revisions/rev/show(/*path).vue")
    component: fourOhFour,
    meta: {
      title:
        "pages.projects-id-repository-repository-id-revisions-rev-show-path.title",
    },
  },
  {
    path: "/projects/:id/repository/:repository_id/show/*path",
    name: "projects-id-repository-repository-id-show-path",
    // "component": () => import("@/pages/projects/id/repository/repository_id/show/*path.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-id-repository-repository-id-show-path.title",
    },
  },
  {
    path: "/projects/:id/repository/:repository_id/statistics",
    name: "projects-id-repository-repository-id-statistics",
    // "component": () => import("@/pages/projects/id/repository/repository_id/statistics.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-id-repository-repository-id-statistics.title",
    },
  },
  {
    path: "/projects/:id/search",
    name: "projects-id-search",
    // component: () => import('@/pages/login/index.vue'),
    meta: {
      title: "pages./projects/:id/search.title",
    },
    component: fourOhFour,
  },
  {
    path: "/projects/:id/settings(/:tab)",
    name: "projects-id-settings-tab",
    // "component": () => import("@/pages/projects/id/settings(/tab).vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-id-settings-tab.title",
    },
  },
  {
    path: "/projects/:id/wiki/destroy",
    name: "projects-id-wiki-destroy",
    // "component": () => import("@/pages/projects/id/wiki/destroy.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-id-wiki-destroy.title",
    },
  },
  {
    path: "/projects/:project_id/boards",
    name: "projects-project-id-boards",
    // "component": () => import("@/pages/projects/project_id/boards.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-boards.title",
    },
  },
  {
    path: "/projects/:project_id/boards/:id",
    name: "projects-project-id-boards-id",
    // "component": () => import("@/pages/projects/project_id/boards/id.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-boards-id.title",
    },
  },
  {
    path: "/projects/:project_id/boards/:id/edit",
    name: "projects-project-id-boards-id-edit",
    // "component": () => import("@/pages/projects/project_id/boards/id/edit.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-boards-id-edit.title",
    },
  },
  {
    path: "/projects/:project_id/boards/new",
    name: "projects-project-id-boards-new",
    // "component": () => import("@/pages/projects/project_id/boards/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-boards-new.title",
    },
  },
  {
    path: "/projects/:project_id/documents",
    name: "projects-project-id-documents",
    // "component": () => import("@/pages/projects/project_id/documents.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-documents.title",
    },
  },
  {
    path: "/projects/:project_id/documents/new",
    name: "projects-project-id-documents-new",
    // "component": () => import("@/pages/projects/project_id/documents/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-documents-new.title",
    },
  },
  {
    path: "/projects/:project_id/files",
    name: "projects-project-id-files",
    // "component": () => import("@/pages/projects/project_id/files.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-files.title",
    },
  },
  {
    path: "/projects/:project_id/files/new",
    name: "projects-project-id-files-new",
    // "component": () => import("@/pages/projects/project_id/files/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-files-new.title",
    },
  },
  {
    path: "/projects/:project_id/issue_categories",
    name: "projects-project-id-issue-categories",
    // "component": () => import("@/pages/projects/project_id/issue_categories.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-issue-categories.title",
    },
  },
  {
    path: "/projects/:project_id/issue_categories/new",
    name: "projects-project-id-issue-categories-new",
    // "component": () => import("@/pages/projects/project_id/issue_categories/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-issue-categories-new.title",
    },
  },
  {
    path: "/projects/:project_id/issues",
    name: "projects-project-id-issues",
    // "component": () => import("@/pages/projects/project_id/issues.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-issues.title",
    },
  },
  {
    path: "/projects/:project_id/issues/:copy_from/copy",
    name: "projects-project-id-issues-copy-from-copy",
    // "component": () => import("@/pages/projects/project_id/issues/copy_from/copy.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-issues-copy-from-copy.title",
    },
  },
  {
    path: "/projects/:project_id/issues/calendar",
    name: "projects-project-id-issues-calendar",
    // "component": () => import("@/pages/projects/project_id/issues/calendar.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-issues-calendar.title",
    },
  },
  {
    path: "/projects/:project_id/issues/gantt",
    name: "projects-project-id-issues-gantt",
    // "component": () => import("@/pages/projects/project_id/issues/gantt.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-issues-gantt.title",
    },
  },
  {
    path: "/projects/:project_id/issues/new",
    name: "projects-project-id-issues-new",
    // "component": () => import("@/pages/projects/project_id/issues/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-issues-new.title",
    },
  },
  {
    path: "/projects/:project_id/memberships",
    name: "projects-project-id-memberships",
    // "component": () => import("@/pages/projects/project_id/memberships.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-memberships.title",
    },
  },
  {
    path: "/projects/:project_id/memberships/autocomplete",
    name: "projects-project-id-memberships-autocomplete",
    // "component": () => import("@/pages/projects/project_id/memberships/autocomplete.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-memberships-autocomplete.title",
    },
  },
  {
    path: "/projects/:project_id/memberships/new",
    name: "projects-project-id-memberships-new",
    // "component": () => import("@/pages/projects/project_id/memberships/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-memberships-new.title",
    },
  },
  {
    path: "/projects/:project_id/news",
    name: "projects-project-id-news",
    // "component": () => import("@/pages/projects/project_id/news.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-news.title",
    },
  },
  {
    path: "/projects/:project_id/news/new",
    name: "projects-project-id-news-new",
    // "component": () => import("@/pages/projects/project_id/news/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-news-new.title",
    },
  },
  {
    path: "/projects/:project_id/queries/new",
    name: "projects-project-id-queries-new",
    // "component": () => import("@/pages/projects/project_id/queries/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-queries-new.title",
    },
  },
  {
    path: "/projects/:project_id/repositories/new",
    name: "projects-project-id-repositories-new",
    // "component": () => import("@/pages/projects/project_id/repositories/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-repositories-new.title",
    },
  },
  {
    path: "/projects/:project_id/roadmap",
    name: "projects-project-id-roadmap",
    // "component": () => import("@/pages/projects/project_id/roadmap.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-roadmap.title",
    },
  },
  {
    path: "/projects/:project_id/time_entries",
    name: "projects-project-id-time-entries",
    // "component": () => import("@/pages/projects/project_id/time_entries.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-time-entries.title",
    },
  },
  {
    path: "/projects/:project_id/time_entries/new",
    name: "projects-project-id-time-entries-new",
    // "component": () => import("@/pages/projects/project_id/time_entries/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-time-entries-new.title",
    },
  },
  {
    path: "/projects/:project_id/time_entries/report",
    name: "projects-project-id-time-entries-report",
    // "component": () => import("@/pages/projects/project_id/time_entries/report.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-time-entries-report.title",
    },
  },
  {
    path: "/projects/:project_id/versions",
    name: "projects-project-id-versions",
    // "component": () => import("@/pages/projects/project_id/versions.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-versions.title",
    },
  },
  {
    path: "/projects/:project_id/versions/new",
    name: "projects-project-id-versions-new",
    // "component": () => import("@/pages/projects/project_id/versions/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-versions-new.title",
    },
  },
  {
    path: "/projects/:project_id/wiki",
    name: "projects-project-id-wiki",
    // "component": () => import("@/pages/projects/project_id/wiki.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-wiki.title",
    },
  },
  {
    path: "/projects/:project_id/wiki/:id",
    name: "projects-project-id-wiki-id",
    // "component": () => import("@/pages/projects/project_id/wiki/id.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-wiki-id.title",
    },
  },
  {
    path: "/projects/:project_id/wiki/:id/:version",
    name: "projects-project-id-wiki-id-version",
    // "component": () => import("@/pages/projects/project_id/wiki/id/version.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-wiki-id-version.title",
    },
  },
  {
    path: "/projects/:project_id/wiki/:id/:version/annotate",
    name: "projects-project-id-wiki-id-version-annotate",
    // "component": () => import("@/pages/projects/project_id/wiki/id/version/annotate.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-wiki-id-version-annotate.title",
    },
  },
  {
    path: "/projects/:project_id/wiki/:id/:version/diff",
    name: "projects-project-id-wiki-id-version-diff",
    // "component": () => import("@/pages/projects/project_id/wiki/id/version/diff.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-wiki-id-version-diff.title",
    },
  },
  {
    path: "/projects/:project_id/wiki/:id/diff",
    name: "projects-project-id-wiki-id-diff",
    // "component": () => import("@/pages/projects/project_id/wiki/id/diff.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-wiki-id-diff.title",
    },
  },
  {
    path: "/projects/:project_id/wiki/:id/edit",
    name: "projects-project-id-wiki-id-edit",
    // "component": () => import("@/pages/projects/project_id/wiki/id/edit.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-wiki-id-edit.title",
    },
  },
  {
    path: "/projects/:project_id/wiki/:id/history",
    name: "projects-project-id-wiki-id-history",
    // "component": () => import("@/pages/projects/project_id/wiki/id/history.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-wiki-id-history.title",
    },
  },
  {
    path: "/projects/:project_id/wiki/:id/rename",
    name: "projects-project-id-wiki-id-rename",
    // "component": () => import("@/pages/projects/project_id/wiki/id/rename.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-wiki-id-rename.title",
    },
  },
  {
    path: "/projects/:project_id/wiki/date_index",
    name: "projects-project-id-wiki-date-index",
    // "component": () => import("@/pages/projects/project_id/wiki/date_index.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-wiki-date-index.title",
    },
  },
  {
    path: "/projects/:project_id/wiki/export",
    name: "projects-project-id-wiki-export",
    // "component": () => import("@/pages/projects/project_id/wiki/export.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-wiki-export.title",
    },
  },
  {
    path: "/projects/:project_id/wiki/index",
    name: "projects-project-id-wiki-index",
    // "component": () => import("@/pages/projects/project_id/wiki/index.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-wiki-index.title",
    },
  },
  {
    path: "/projects/:project_id/wiki/new",
    name: "projects-project-id-wiki-new",
    // "component": () => import("@/pages/projects/project_id/wiki/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-project-id-wiki-new.title",
    },
  },
  {
    path: "/projects/autocomplete",
    name: "projects-autocomplete",
    // "component": () => import("@/pages/projects/autocomplete.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-autocomplete.title",
    },
  },
  {
    path: "/projects/new",
    name: "projects-new",
    // "component": () => import("@/pages/projects/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.projects-new.title",
    },
  },
  {
    path: "/queries",
    name: "queries",
    // "component": () => import("@/pages/queries.vue")
    component: fourOhFour,
    meta: {
      title: "pages.queries.title",
    },
  },
  {
    path: "/queries/:id/edit",
    name: "queries-id-edit",
    // "component": () => import("@/pages/queries/id/edit.vue")
    component: fourOhFour,
    meta: {
      title: "pages.queries-id-edit.title",
    },
  },
  {
    path: "/queries/filter",
    name: "queries-filter",
    // "component": () => import("@/pages/queries/filter.vue")
    component: fourOhFour,
    meta: {
      title: "pages.queries-filter.title",
    },
  },
  {
    path: "/queries/new",
    name: "queries-new",
    // "component": () => import("@/pages/queries/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.queries-new.title",
    },
  },
  {
    path: "/relations/:id",
    name: "relations-id",
    // "component": () => import("@/pages/relations/id.vue")
    component: fourOhFour,
    meta: {
      title: "pages.relations-id.title",
    },
  },
  {
    path: "/repositories/:id/committers",
    name: "repositories-id-committers",
    // "component": () => import("@/pages/repositories/id/committers.vue")
    component: fourOhFour,
    meta: {
      title: "pages.repositories-id-committers.title",
    },
  },
  {
    path: "/repositories/:id/edit",
    name: "repositories-id-edit",
    // "component": () => import("@/pages/repositories/id/edit.vue")
    component: fourOhFour,
    meta: {
      title: "pages.repositories-id-edit.title",
    },
  },
  {
    path: "/roles",
    name: "roles",
    // "component": () => import("@/pages/roles.vue")
    component: fourOhFour,
    meta: {
      title: "pages.roles.title",
    },
  },
  {
    path: "/roles/:id",
    name: "roles-id",
    // "component": () => import("@/pages/roles/id.vue")
    component: fourOhFour,
    meta: {
      title: "pages.roles-id.title",
    },
  },
  {
    path: "/roles/:id/edit",
    name: "roles-id-edit",
    // "component": () => import("@/pages/roles/id/edit.vue")
    component: fourOhFour,
    meta: {
      title: "pages.roles-id-edit.title",
    },
  },
  {
    path: "/roles/new",
    name: "roles-new",
    // "component": () => import("@/pages/roles/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.roles-new.title",
    },
  },
  {
    path: "/roles/permissions",
    name: "roles-permissions",
    // "component": () => import("@/pages/roles/permissions.vue")
    component: fourOhFour,
    meta: {
      title: "pages.roles-permissions.title",
    },
  },
  {
    path: "/settings",
    name: "settings",
    // "component": () => import("@/pages/settings.vue")
    component: fourOhFour,
    meta: {
      title: "pages.settings.title",
    },
  },
  {
    path: "/settings/edit",
    name: "settings-edit",
    // "component": () => import("@/pages/settings/edit.vue")
    component: fourOhFour,
    meta: {
      title: "pages.settings-edit.title",
    },
  },
  {
    path: "/settings/plugin/:id",
    name: "settings-plugin-id",
    // "component": () => import("@/pages/settings/plugin/id.vue")
    component: fourOhFour,
    meta: {
      title: "pages.settings-plugin-id.title",
    },
  },
  {
    path: "/sys/fetch_changesets",
    name: "sys-fetch-changesets",
    // "component": () => import("@/pages/sys/fetch_changesets.vue")
    component: fourOhFour,
    meta: {
      title: "pages.sys-fetch-changesets.title",
    },
  },
  {
    path: "/sys/projects",
    name: "sys-projects",
    // "component": () => import("@/pages/sys/projects.vue")
    component: fourOhFour,
    meta: {
      title: "pages.sys-projects.title",
    },
  },
  {
    path: "/time_entries",
    name: "time-entries",
    // "component": () => import("@/pages/time_entries.vue")
    component: fourOhFour,
    meta: {
      title: "pages.time-entries.title",
    },
  },
  {
    path: "/time_entries/:id",
    name: "time-entries-id",
    // "component": () => import("@/pages/time_entries/id.vue")
    component: fourOhFour,
    meta: {
      title: "pages.time-entries-id.title",
    },
  },
  {
    path: "/time_entries/:id/edit",
    name: "time-entries-id-edit",
    // "component": () => import("@/pages/time_entries/id/edit.vue")
    component: fourOhFour,
    meta: {
      title: "pages.time-entries-id-edit.title",
    },
  },
  {
    path: "/time_entries/bulk_edit",
    name: "time-entries-bulk-edit",
    // "component": () => import("@/pages/time_entries/bulk_edit.vue")
    component: fourOhFour,
    meta: {
      title: "pages.time-entries-bulk-edit.title",
    },
  },
  {
    path: "/time_entries/context_menu",
    name: "time-entries-context-menu",
    // "component": () => import("@/pages/time_entries/context_menu.vue")
    component: fourOhFour,
    meta: {
      title: "pages.time-entries-context-menu.title",
    },
  },
  {
    path: "/time_entries/imports/new",
    name: "time-entries-imports-new",
    // "component": () => import("@/pages/time_entries/imports/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.time-entries-imports-new.title",
    },
  },
  {
    path: "/time_entries/new",
    name: "time-entries-new",
    // "component": () => import("@/pages/time_entries/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.time-entries-new.title",
    },
  },
  {
    path: "/time_entries/report",
    name: "time-entries-report",
    // "component": () => import("@/pages/time_entries/report.vue")
    component: fourOhFour,
    meta: {
      title: "pages.time-entries-report.title",
    },
  },
  {
    path: "/trackers",
    name: "trackers",
    // "component": () => import("@/pages/trackers.vue")
    component: fourOhFour,
    meta: {
      title: "pages.trackers.title",
    },
  },
  {
    path: "/trackers/:id/edit",
    name: "trackers-id-edit",
    // "component": () => import("@/pages/trackers/id/edit.vue")
    component: fourOhFour,
    meta: {
      title: "pages.trackers-id-edit.title",
    },
  },
  {
    path: "/trackers/fields",
    name: "trackers-fields",
    // "component": () => import("@/pages/trackers/fields.vue")
    component: fourOhFour,
    meta: {
      title: "pages.trackers-fields.title",
    },
  },
  {
    path: "/trackers/new",
    name: "trackers-new",
    // "component": () => import("@/pages/trackers/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.trackers-new.title",
    },
  },
  {
    path: "/users",
    name: "users",
    // "component": () => import("@/pages/users.vue")
    component: fourOhFour,
    meta: {
      title: "pages.users.title",
    },
  },
  {
    path: "/users/:id",
    name: "users-id",
    // "component": () => import("@/pages/users/id.vue")
    component: fourOhFour,
    meta: {
      title: "pages.users-id.title",
    },
  },
  {
    path: "/users/:id/edit",
    name: "users-id-edit",
    // "component": () => import("@/pages/users/id/edit.vue")
    component: fourOhFour,
    meta: {
      title: "pages.users-id-edit.title",
    },
  },
  {
    path: "/users/:user_id/email_addresses",
    name: "users-user-id-email-addresses",
    // "component": () => import("@/pages/users/user_id/email_addresses.vue")
    component: fourOhFour,
    meta: {
      title: "pages.users-user-id-email-addresses.title",
    },
  },
  {
    path: "/users/:user_id/memberships",
    name: "users-user-id-memberships",
    // "component": () => import("@/pages/users/user_id/memberships.vue")
    component: fourOhFour,
    meta: {
      title: "pages.users-user-id-memberships.title",
    },
  },
  {
    path: "/users/:user_id/memberships/:id",
    name: "users-user-id-memberships-id",
    // "component": () => import("@/pages/users/user_id/memberships/id.vue")
    component: fourOhFour,
    meta: {
      title: "pages.users-user-id-memberships-id.title",
    },
  },
  {
    path: "/users/:user_id/memberships/:id/edit",
    name: "users-user-id-memberships-id-edit",
    // "component": () => import("@/pages/users/user_id/memberships/id/edit.vue")
    component: fourOhFour,
    meta: {
      title: "pages.users-user-id-memberships-id-edit.title",
    },
  },
  {
    path: "/users/:user_id/memberships/new",
    name: "users-user-id-memberships-new",
    // "component": () => import("@/pages/users/user_id/memberships/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.users-user-id-memberships-new.title",
    },
  },
  {
    path: "/users/context_menu",
    name: "users-context-menu",
    // "component": () => import("@/pages/users/context_menu.vue")
    component: fourOhFour,
    meta: {
      title: "pages.users-context-menu.title",
    },
  },
  {
    path: "/users/imports/new",
    name: "users-imports-new",
    // "component": () => import("@/pages/users/imports/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.users-imports-new.title",
    },
  },
  {
    path: "/users/new",
    name: "users-new",
    // "component": () => import("@/pages/users/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.users-new.title",
    },
  },
  {
    path: "/versions/:id",
    name: "versions-id",
    // "component": () => import("@/pages/versions/id.vue")
    component: fourOhFour,
    meta: {
      title: "pages.versions-id.title",
    },
  },
  {
    path: "/versions/:id/edit",
    name: "versions-id-edit",
    // "component": () => import("@/pages/versions/id/edit.vue")
    component: fourOhFour,
    meta: {
      title: "pages.versions-id-edit.title",
    },
  },
  {
    path: "/watchers/autocomplete_for_mention",
    name: "watchers-autocomplete-for-mention",
    // "component": () => import("@/pages/watchers/autocomplete_for_mention.vue")
    component: fourOhFour,
    meta: {
      title: "pages.watchers-autocomplete-for-mention.title",
    },
  },
  {
    path: "/watchers/autocomplete_for_user",
    name: "watchers-autocomplete-for-user",
    // "component": () => import("@/pages/watchers/autocomplete_for_user.vue")
    component: fourOhFour,
    meta: {
      title: "pages.watchers-autocomplete-for-user.title",
    },
  },
  {
    path: "/watchers/new",
    name: "watchers-new",
    // "component": () => import("@/pages/watchers/new.vue")
    component: fourOhFour,
    meta: {
      title: "pages.watchers-new.title",
    },
  },
  {
    path: "/wiki_pages/auto_complete",
    name: "wiki-pages-auto-complete",
    // "component": () => import("@/pages/wiki_pages/auto_complete.vue")
    component: fourOhFour,
    meta: {
      title: "pages.wiki-pages-auto-complete.title",
    },
  },
  {
    path: "/workflows",
    name: "workflows",
    // "component": () => import("@/pages/workflows.vue")
    component: fourOhFour,
    meta: {
      title: "pages.workflows.title",
    },
  },
  {
    path: "/workflows/copy",
    name: "workflows-copy",
    // "component": () => import("@/pages/workflows/copy.vue")
    component: fourOhFour,
    meta: {
      title: "pages.workflows-copy.title",
    },
  },
  {
    path: "/workflows/edit",
    name: "workflows-edit",
    // "component": () => import("@/pages/workflows/edit.vue")
    component: fourOhFour,
    meta: {
      title: "pages.workflows-edit.title",
    },
  },
  {
    path: "/workflows/permissions",
    name: "workflows-permissions",
    // "component": () => import("@/pages/workflows/permissions.vue")
    component: fourOhFour,
    meta: {
      title: "pages.workflows-permissions.title",
    },
  },
];

export const router = createRouter({
  history: createWebHistory(),
  routes,
});

router.beforeEach(async (to) => {
  const api = inject<ApiService>("api");
  const toast = inject<ToastService>("toast");
  const ls = inject<LocalStorageService>("localStorage");
  loadAppData(ls, api);
  const props = await loadRouteData(to, api, toast);
  if ("boolean" === typeof props) {
    return props;
  }
  const store = useRouteDataStore();
  store.set(props);
  const appDataStore = useAppDataStore();
  const appData =
    "object" === typeof appDataStore.data &&
    null !== appDataStore.data &&
    Object.keys(appDataStore.data).length > 0
      ? appDataStore.data
      : null;
  if (null !== appData) {
    updateHead(to, appData);
  }
});

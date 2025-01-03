<template>
  <v-container fluid class="page-projects-show">
    <v-card min-height="100" color="surface">
      <v-toolbar color="transparent" density="compact">
        <v-toolbar-title class="font-weight-bold d-flex align-center" tag="h1">
          {{ $t(`pages.${String($route.name)}.title`) }}
        </v-toolbar-title>
      </v-toolbar>
      <v-divider />
      <v-breadcrumbs v-bind="breadcrumbsBindings" />
      <v-divider />
      <v-sheet v-bind="projectHeroBindings">
        <div class="top">
          <v-avatar size="150" :color="accentColor" class="elevation-5">
            <v-img :src="avatarSource" />
          </v-avatar>
        </div>
        <div class="bottom">
          <h1 class="display-1 font-weight-bold mb-3">
            {{ model.name }}
          </h1>
        </div>
      </v-sheet>
      <v-divider />
      <v-toolbar color="transparent">
        <v-slide-group show-arrows class="mx-2">
          <v-slide-group-item v-for="mi in menu" :key="mi.key">
            <template v-if="Array.isArray(mi.children)">
              <v-btn-group
                divided
                :base-color="accentColor"
                density="compact"
                class="mx-1 my-2"
                style="height: 24px; position: relative; top: 1.5px"
              >
                <v-menu>
                  <template #activator="{ props }">
                    <v-btn v-bind="props" size="x-small">
                      <span>{{ mi.title }}</span>
                    </v-btn>
                  </template>
                  <v-card color="surface">
                    <v-list-item
                      v-for="cmi in mi.children"
                      :key="`${mi.key}-${cmi.key}`"
                      :title="cmi.title"
                      :to="cmi.to"
                    />
                  </v-card>
                </v-menu>
                <v-menu>
                  <template #activator="{ props }">
                    <v-btn v-bind="props" icon="mdi-menu-down" size="x-small" />
                  </template>
                  <v-card color="surface">
                    <v-list-item
                      v-for="cmi in mi.children"
                      :key="`${mi.key}-${cmi.key}`"
                      :title="cmi.title"
                      :to="cmi.to"
                    />
                  </v-card>
                </v-menu>
              </v-btn-group>
            </template>
            <template v-else>
              <v-btn
                variant="elevated"
                :color="accentColor"
                size="x-small"
                class="mx-1 my-2"
                height="24px"
                style="position: relative; top: 1px"
                :to="mi.to"
              >
                <span>{{ mi.title }}</span>
              </v-btn>
            </template>
          </v-slide-group-item>
        </v-slide-group>
      </v-toolbar>
      <v-divider />
      <!-- Here we will put the attached files -->
      <UnderConstruction />
    </v-card>
  </v-container>
</template>

<script lang="ts">
import { defineComponent, computed } from "vue";
import { useI18n } from "vue-i18n";
import { useRoute } from "vue-router";
import { useSystemSurfaceColor, useSystemAccentColor } from "@/utils/app";
import { formatDuration } from "@/utils/formatting";
import iconGitLab from "@/assets/images/icon-gitlab.svg?url";
import iconGitHub from "@/assets/images/icon-github.svg?url";
import iconMonday from "@/assets/images/icon-monday.svg?url";
import defaultProjectAvatar from "@/assets/images/default-project-avatar.svg?url";
import defaultProjectBanner from "@/assets/images/default-project-banner.jpg?url";

import UnderConstruction from "@/views/construction.vue";

import type { PropType } from "vue";
import type {
  ProjectModel,
  ProjectMember,
  ProjectIssueCategory,
  ProjectRepository,
  ProjectCustomField,
  ProjectValuesProp,
  ProjectPermissions,
  Principal,
  FridayMenuItem,
  ProjectWikiPageLink,
  ProjectDocumentLink,
  File,
  MondayBoard,
  AttachedFile,
} from "@/friday";

export default defineComponent({
  name: "ProjectsFiles",
  components: {
    UnderConstruction,
  },
  props: {
    formAuthenticityToken: {
      type: String,
      required: true,
    },
    id: {
      type: [String, Number] as PropType<string | number | null | undefined>,
      default: null,
    },
    model: {
      type: Object as PropType<ProjectModel>,
      required: true,
    },
    members: {
      type: Array as PropType<ProjectMember[]>,
      required: true,
    },
    menu: {
      type: Array as PropType<FridayMenuItem[]>,
      required: true,
    },
    issueCategories: {
      type: Array as PropType<ProjectIssueCategory[]>,
      required: true,
    },
    repositories: {
      type: Array as PropType<ProjectRepository[]>,
      required: true,
    },
    customFields: {
      type: Array as PropType<ProjectCustomField[]>,
      required: true,
    },
    values: {
      type: Object as PropType<ProjectValuesProp>,
      required: true,
    },
    permissions: {
      type: Object as PropType<ProjectPermissions>,
      required: true,
    },
    parents: {
      type: Array as PropType<ProjectModel[]>,
      required: true,
    },
    wiki: {
      type: Array as PropType<ProjectWikiPageLink[]>,
      required: true,
    },
    documents: {
      type: Array as PropType<ProjectDocumentLink[]>,
      required: true,
    },
    files: {
      type: Array as PropType<File[]>,
      required: true,
    },
    mondayBoard: {
      type: Object as PropType<MondayBoard | null>,
      default: null,
    },
    attachedFiles: {
      type: Array as PropType<AttachedFile[]>,
      required: true,
    },
  },
  setup(props) {
    // const toast = inject<ToastService>("toast");
    // const ls = inject<LocalStorageService>("ls");
    // const api = inject<ApiService>("api");
    const route = useRoute();
    // const router = useRouter();
    // const reloadRouteDataAction = useReloadRouteData(route, api, toast);
    // const reloadAppDataAction = useReloadAppData(ls, api);
    const surfaceColor = useSystemSurfaceColor();
    const accentColor = useSystemAccentColor();
    const model = computed(() => props.model);
    const values = computed(() => props.values);
    const parents = computed(() => props.parents);
    const permissions = computed(() => props.permissions);
    const enabledModuleNames = computed(() => model.value.enabled_module_names);
    const statuses = computed(() => values.value.statuses);
    const { t } = useI18n({ useScope: "global" });
    const breadcrumbsBindings = computed(() => ({
      items: [
        { title: t("pages.projects.title"), to: { name: "projects" } },
        ...parents.value.map((model) => ({
          title: model.name,
          to: { name: "projects-id", params: { id: model.identifier } },
        })),
        { title: model.value.name },
      ],
    }));
    const bannerSource = computed(() => {
      return model.value.banner || defaultProjectBanner;
    });
    const avatarSource = computed(() => {
      return model.value.avatar || defaultProjectAvatar;
    });
    const projectHeroBindings = computed(() => ({
      class: ["project-hero"],
      height: 300,
      style: {
        "--project-hero-background": `url(${bannerSource.value})`,
      },
    }));
    const publicStatusChip = computed(() => ({
      icon: model.value.is_public ? "mdi-earth" : "mdi-earth-off",
      color: model.value.is_public ? "info" : "success",
      text: model.value.is_public ? t("labels.public") : t("labels.private"),
    }));
    const status = computed(() => {
      return statuses.value.find(
        (status) => status.value === model.value.status,
      )!;
    });
    const prettifiedHomepage = computed(() => {
      if (!model.value.homepage) return null;
      const u = model.value.homepage.startsWith("http")
        ? model.value.homepage
        : `http://${model.value.homepage}`;
      const url = new URL(u);
      return url.hostname;
    });
    const hasModule = (moduleName: string) =>
      enabledModuleNames.value.includes(moduleName);
    const currentUserCan = (action: string) =>
      action in permissions.value &&
      true === permissions.value[action as keyof ProjectPermissions];
    const wiki = computed(() => props.wiki);
    const topLevelWikiPages = computed(() =>
      wiki.value.filter((w) => !w.parent),
    );
    const avatarUrlForPrincipal = (principal: Principal) => {
      if (["group", "group_anonymous"].includes(principal.type)) {
        return `/groups/${principal.id}/avatar`;
      } else {
        return `/users/${principal.id}/avatar`;
      }
    };
    const documents = computed(() => props.documents);
    const documentsByCategory = computed(() =>
      documents.value.reduce(
        (acc, doc) => {
          if (!acc[doc.category]) {
            acc[doc.category] = [];
          }
          acc[doc.category].push(doc);
          return acc;
        },
        {} as Record<string, ProjectDocumentLink[]>,
      ),
    );
    const minDateTime = computed(() => model.value.created_on!);
    const isCurrentRoute = (names: string[]) => {
      return names.includes(route.name as string);
    };
    return {
      breadcrumbsBindings,
      surfaceColor,
      accentColor,
      projectHeroBindings,
      defaultProjectAvatar,
      avatarSource,
      publicStatusChip,
      status,
      prettifiedHomepage,
      hasModule,
      currentUserCan,
      topLevelWikiPages,
      iconGitLab,
      iconGitHub,
      iconMonday,
      avatarUrlForPrincipal,
      formatDuration,
      documentsByCategory,
      minDateTime,
      isCurrentRoute,
    };
  },
});
</script>

<style lang="scss">
.page-projects-show {
  .project-hero {
    position: relative;
    display: flex;
    flex-direction: column;

    &:before {
      content: "";
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 50%;
      background-image: var(--project-hero-background);
      background-size: cover;
      opacity: 0.5;
    }

    > div {
      position: relative;
      z-index: 1;
      flex-grow: 1;
      height: 50%;
      width: 100%;
      display: flex;
      align-items: center;
      padding: 0 16px;

      &.bottom {
        align-items: flex-end;
      }

      > .v-avatar {
        border: solid 2px;
        transform: translateY(75px);
      }

      @media (max-width: 600px) {
        justify-content: center;
        > .v-avatar {
          transform: translateY(30px);
        }
      }
    }
  }

  .v-row {
    &.with-dividing-border {
      @media (min-width: 600px) and (max-width: 959px) {
        > div:not(:first-child):not(:last-child) {
          border-right: 1px solid
            rgba(var(--v-theme-on-surface), var(--v-border-opacity));
        }
      }
      @media (min-width: 960px) {
        > div:not(:last-child) {
          border-right: 1px solid
            rgba(var(--v-theme-on-surface), var(--v-border-opacity));
        }
      }
    }
  }

  .v-card.overflow-y-visible {
    overflow: visible !important;
    position: relative;
  }

  .project-card-label {
    position: absolute;
    top: -10px;
    z-index: 3;
    background-color: rgb(var(--v-theme-surface));
    opacity: 1;
    padding: 0 8px;
  }
}
</style>

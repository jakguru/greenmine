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
                :exact="true"
              >
                <span>{{ mi.title }}</span>
              </v-btn>
            </template>
          </v-slide-group-item>
        </v-slide-group>
      </v-toolbar>
      <v-divider />
      <v-sheet v-bind="projectHeroBindings">
        <div class="top">
          <v-avatar size="150" :color="accentColor">
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
          <v-slide-group-item>
            <v-chip
              :color="publicStatusChip.color"
              variant="elevated"
              size="small"
              class="mx-1"
            >
              <v-icon class="me-2">{{ publicStatusChip.icon }}</v-icon>
              <strong>{{ publicStatusChip.text }}</strong>
            </v-chip>
          </v-slide-group-item>
          <v-slide-group-item>
            <v-chip
              :color="status.color"
              variant="elevated"
              size="small"
              class="mx-1"
            >
              <v-icon class="me-2">{{ status.icon }}</v-icon>
              <strong>{{ status.label }}</strong>
            </v-chip>
          </v-slide-group-item>
          <v-slide-group-item v-if="model.homepage">
            <v-chip
              :color="accentColor"
              variant="elevated"
              size="small"
              class="mx-1"
              :href="model.homepage"
              target="_blank"
            >
              <v-icon class="me-2">mdi-home</v-icon>
              <strong>{{ prettifiedHomepage }}</strong>
            </v-chip>
          </v-slide-group-item>
        </v-slide-group>
      </v-toolbar>
      <v-divider />
      <template v-if="'projects-id' === $route.name">
        <v-container fluid class="pa-0">
          <v-row no-gutters class="with-dividing-border">
            <v-col cols="12" sm="12" md="6" xl="8" order-md="2">
              <v-container>
                <v-row v-if="model.description">
                  <v-col cols="12">
                    <v-card variant="outlined" class="overflow-y-visible">
                      <v-label class="mx-2 project-card-label">
                        <small>{{
                          $t(`pages.projects-id.content.description`)
                        }}</small>
                      </v-label>
                      <v-card-text>
                        <RenderMarkdown
                          v-if="model.description"
                          :raw="model.description"
                        />
                      </v-card-text>
                    </v-card>
                  </v-col>
                </v-row>
                <v-row
                  v-if="
                    hasModule('issue_tracking') && currentUserCan('view_issues')
                  "
                >
                  <v-col cols="12">
                    <v-card variant="outlined" class="overflow-y-visible">
                      <v-label class="mx-2 project-card-label">
                        <small>{{
                          $t(`pages.projects-id.content.issueSummaryByTracker`)
                        }}</small>
                      </v-label>
                      <v-card-text>
                        This is where the project's issue tracking summary will
                        be shown including a theme-river chart of issues by
                        tracker over time
                      </v-card-text>
                    </v-card>
                  </v-col>
                </v-row>
                <v-row
                  v-if="
                    hasModule('issue_tracking') && currentUserCan('view_issues')
                  "
                >
                  <v-col cols="12">
                    <v-card variant="outlined" class="overflow-y-visible">
                      <v-label class="mx-2 project-card-label">
                        <small>{{
                          $t(`pages.projects-id.content.issueSummaryByStatus`)
                        }}</small>
                      </v-label>
                      <v-card-text>
                        This is where the project's issue tracking summary by
                        status will be shown including a theme-river chart of
                        issues by status over time
                      </v-card-text>
                    </v-card>
                  </v-col>
                </v-row>
              </v-container>
            </v-col>
            <v-col cols="12" sm="6" md="3" xl="2" order-md="1">
              <v-container>
                <v-row>
                  <v-col cols="12">
                    <v-card variant="outlined" class="overflow-y-visible">
                      <v-label class="mx-2 project-card-label">
                        <small>{{
                          $t(`pages.projects-id.content.members`)
                        }}</small>
                      </v-label>
                      <v-card-text>
                        This is where the project's members will be shown
                      </v-card-text>
                    </v-card>
                  </v-col>
                </v-row>
                <v-row v-if="subprojects.length">
                  <v-col cols="12">
                    <v-card variant="outlined" class="overflow-y-visible">
                      <v-label class="mx-2 project-card-label">
                        <small>{{
                          $t(`pages.projects-id.content.subprojects`)
                        }}</small>
                      </v-label>
                      <v-list class="bg-transparent pb-0">
                        <v-list-item
                          v-for="sp in subprojects"
                          :key="`subproject-${sp.identifier}`"
                          :title="sp.name"
                          :subtitle="sp.identifier || ''"
                          two-line
                          :to="{
                            name: 'projects-id',
                            params: { id: sp.identifier },
                          }"
                        >
                          <template #prepend>
                            <v-avatar
                              size="24"
                              :image="sp.avatar || defaultProjectAvatar"
                              :color="accentColor"
                            />
                          </template>
                        </v-list-item>
                      </v-list>
                    </v-card>
                  </v-col>
                </v-row>
                <v-row v-if="gitlabProjects.length">
                  <v-col cols="12">
                    <v-card variant="outlined" class="overflow-y-visible">
                      <v-label class="mx-2 project-card-label">
                        <small>{{
                          $t(`pages.projects-id.content.gitlabProjects`)
                        }}</small>
                      </v-label>
                      <v-list class="bg-transparent pb-0">
                        <v-list-item
                          v-for="glp in gitlabProjects"
                          :key="`gitlabProject-${glp.id}`"
                          :title="glp.name_with_namespace"
                          :subtitle="glp.path_with_namespace"
                          two-line
                          :href="glp.web_url"
                          target="_blank"
                        >
                          <template #append>
                            <v-avatar size="24" :image="iconGitlab" />
                          </template>
                        </v-list-item>
                      </v-list>
                    </v-card>
                  </v-col>
                </v-row>
              </v-container>
            </v-col>
            <v-col cols="12" sm="6" md="3" xl="2" order-md="3">
              <v-container>
                <v-row
                  v-if="
                    hasModule('time_tracking') &&
                    currentUserCan('view_time_entries')
                  "
                >
                  <v-col cols="12">
                    <v-card variant="outlined" class="overflow-y-visible">
                      <v-label class="mx-2 project-card-label">
                        <small>{{
                          $t(`pages.projects-id.content.timeSummary`)
                        }}</small>
                      </v-label>
                      <v-card-text>
                        This is where the project's time tracking summary will
                        be shown
                      </v-card-text>
                    </v-card>
                  </v-col>
                </v-row>
                <v-row v-if="hasModule('news') && news.length">
                  <v-col cols="12">
                    <v-card variant="outlined" class="overflow-y-visible">
                      <v-label class="mx-2 project-card-label">
                        <small>{{
                          $t(`pages.projects-id.content.news`)
                        }}</small>
                      </v-label>
                      <v-list class="bg-transparent">
                        <NewsPreview
                          v-for="n in news"
                          :key="n.id"
                          :news="n"
                          in-project
                        />
                      </v-list>
                      <v-divider />
                      <v-card-actions>
                        <v-spacer />
                        <v-btn
                          variant="elevated"
                          :color="accentColor"
                          size="x-small"
                          height="24px"
                          :to="{
                            name: 'projects-project-id-news',
                            params: { project_id: model.identifier },
                          }"
                          :exact="true"
                        >
                          <span>{{
                            $t("pages.projects-id.content.allNews")
                          }}</span>
                        </v-btn>
                      </v-card-actions>
                    </v-card>
                  </v-col>
                </v-row>
                <v-row v-if="hasModule('wiki') && topLevelWikiPages.length">
                  <v-col cols="12">
                    <v-card variant="outlined" class="overflow-y-visible">
                      <v-label class="mx-2 project-card-label">
                        <small>{{
                          $t(`pages.projects-id.content.wikiPages`)
                        }}</small>
                      </v-label>
                      <v-list class="bg-transparent pb-0">
                        <v-list-item
                          v-for="wp in topLevelWikiPages"
                          :key="`wiki-page-${wp.id}`"
                          :title="wp.title"
                          :to="wp.url"
                        />
                      </v-list>
                    </v-card>
                  </v-col>
                </v-row>
              </v-container>
            </v-col>
          </v-row>
        </v-container>
      </template>
    </v-card>
  </v-container>
</template>

<script lang="ts">
import { defineComponent, computed, inject } from "vue";
import { useI18n } from "vue-i18n";
import { useRoute, useRouter } from "vue-router";
import {
  useSystemAccentColor,
  useReloadRouteData,
  useReloadAppData,
} from "@/utils/app";
import iconGitlab from "@/assets/images/icon-gitlab.svg?url";
import defaultProjectAvatar from "@/assets/images/default-project-avatar.svg?url";
import defaultProjectBanner from "@/assets/images/default-project-banner.jpg?url";
import { RenderMarkdown } from "@/components/rendering";
import { NewsPreview } from "@/components/news";

import type { PropType } from "vue";
import type {
  ToastService,
  LocalStorageService,
  ApiService,
} from "@jakguru/vueprint";
import type {
  ProjectModel,
  ProjectMember,
  ProjectIssueCategory,
  ProjectVersion,
  ProjectRepository,
  ProjectCustomField,
  ProjectValuesProp,
  ProjectPermissions,
  Principal,
  News,
  Tracker,
  GitlabProject,
  FridayMenuItem,
  ProjectWikiPageLink,
} from "@/friday";

export default defineComponent({
  name: "ProjectsShow",
  components: {
    RenderMarkdown,
    NewsPreview,
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
    versions: {
      type: Array as PropType<ProjectVersion[]>,
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
    principalsByRole: {
      type: Object as PropType<Record<string, Principal[]>>,
      required: true,
    },
    subprojects: {
      type: Array as PropType<ProjectModel[]>,
      required: true,
    },
    news: {
      type: Array as PropType<News[]>,
      required: true,
    },
    trackers: {
      type: Array as PropType<Tracker[]>,
      required: true,
    },
    openIssuesByTracker: {
      type: Object as PropType<Record<string, number>>,
      required: true,
    },
    totalIssuesByTracker: {
      type: Object as PropType<Record<string, number>>,
      required: true,
    },
    totalHours: {
      type: [String, Number] as PropType<string | number | null>,
      required: true,
    },
    totalEstimatedHours: {
      type: [String, Number] as PropType<string | number | null>,
      required: true,
    },
    gitlabProjects: {
      type: Array as PropType<GitlabProject[]>,
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
  },
  setup(props) {
    const toast = inject<ToastService>("toast");
    const ls = inject<LocalStorageService>("ls");
    const api = inject<ApiService>("api");
    const route = useRoute();
    const router = useRouter();
    const reloadRouteDataAction = useReloadRouteData(route, api, toast);
    const reloadAppDataAction = useReloadAppData(ls, api);
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
    const roles = computed(() => values.value.roles);
    const principalsByRole = computed(() => props.principalsByRole);
    const membershipsToShow = computed(() =>
      Object.keys(principalsByRole.value)
        .map((roleName: string) => {
          const role = roles.value.find((r) => r.label === roleName);
          const principals = principalsByRole.value[roleName];
          if (!role || !role.assignable || role.external) return undefined;
          return {
            role,
            principals,
          };
        })
        .filter((m) => "undefined" !== typeof m),
    );
    const hasModule = (moduleName: string) =>
      enabledModuleNames.value.includes(moduleName);
    const currentUserCan = (action: string) =>
      action in permissions.value &&
      true === permissions.value[action as keyof ProjectPermissions];
    const wiki = computed(() => props.wiki);
    const topLevelWikiPages = computed(() =>
      wiki.value.filter((w) => !w.parent),
    );
    return {
      breadcrumbsBindings,
      accentColor,
      projectHeroBindings,
      defaultProjectAvatar,
      avatarSource,
      publicStatusChip,
      status,
      prettifiedHomepage,
      membershipsToShow,
      hasModule,
      currentUserCan,
      topLevelWikiPages,
      iconGitlab,
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

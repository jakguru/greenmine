<template>
  <v-container fluid>
    <v-card min-height="100" color="surface">
      <v-toolbar color="transparent" density="compact">
        <v-toolbar-title class="font-weight-bold d-flex align-center" tag="h1">
          {{ $t("pages.projects-id.title") }}
        </v-toolbar-title>
      </v-toolbar>
      <v-divider />
      <v-breadcrumbs v-bind="breadcrumbsBindings" />
      <v-divider />
      <v-parallax :src="bannerSource" height="250">
        <v-overlay
          contained
          :model-value="true"
          content-class="w-100 h-100 glass-background-soften-5 bg-transparent"
          opacity="0"
        >
          <v-container fluid class="fill-height">
            <v-row>
              <v-col cols="4" md="2">
                <v-avatar size="90%" class="mx-auto" :color="accentColor">
                  <v-img :src="avatarSource" />
                </v-avatar>
              </v-col>
              <v-col cols="8" md="5">
                <h1 class="display-1 font-weight-bold mb-3">
                  {{ model.name }}
                </h1>
                <div>
                  <v-chip
                    :color="publicStatusChip.color"
                    variant="elevated"
                    size="small"
                    class="me-2"
                  >
                    <v-icon class="me-2">{{ publicStatusChip.icon }}</v-icon>
                    <strong>{{ publicStatusChip.text }}</strong>
                  </v-chip>
                  <v-chip
                    :color="status.color"
                    variant="elevated"
                    size="small"
                    class="me-2"
                  >
                    <v-icon class="me-2">{{ status.icon }}</v-icon>
                    <strong>{{ status.label }}</strong>
                  </v-chip>
                  <v-chip
                    v-if="model.homepage"
                    :color="accentColor"
                    variant="elevated"
                    size="small"
                    class="me-2"
                    :href="model.homepage"
                    target="_blank"
                  >
                    <v-icon class="me-2">mdi-home</v-icon>
                    <strong>{{ prettifiedHomepage }}</strong>
                  </v-chip>
                  <!--  -->
                </div>
              </v-col>
            </v-row>
          </v-container>
        </v-overlay>
      </v-parallax>
      <!-- <v-container fluid>
                    <v-row
                      v-for="m in membershipsToShow"
                      :key="`memberships-for-${m.role.value}`"
                    >
                      <v-col cols="12">
                        <v-label size="small" class="font-weight-bold mb-21">
                          <small>{{ m.role.label }}</small>
                        </v-label>
                        <div
                          :style="{ marginLeft: '-5px', marginRight: '-5px' }"
                        >
                          <v-slide-group show-arrows>
                            <v-slide-group-item
                              v-for="p in m.principals"
                              :key="`memberships-for-${m.role.value}-principal-${p.id}`"
                            >
                              <v-avatar
                                :color="accentColor"
                                size="40"
                                class="mx-1"
                              >
                                <v-img :src="`/users/${p.id}/avatar`" />
                              </v-avatar>
                            </v-slide-group-item>
                          </v-slide-group>
                        </div>
                      </v-col>
                    </v-row>
                  </v-container> -->
    </v-card>
  </v-container>
</template>

<script lang="ts">
import { defineComponent, computed, inject } from "vue";
import { useI18n } from "vue-i18n";
import { useRoute } from "vue-router";
import {
  useSystemAccentColor,
  useReloadRouteData,
  useReloadAppData,
} from "@/utils/app";
import iconGitlab from "@/assets/images/icon-gitlab.svg?url";
import defaultProjectAvatar from "@/assets/images/default-project-avatar.svg?url";
import defaultProjectBanner from "@/assets/images/default-project-banner.jpg?url";

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
} from "@/friday";

export default defineComponent({
  name: "ProjectsShow",
  components: {},
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
  },
  setup(props) {
    const toast = inject<ToastService>("toast");
    const ls = inject<LocalStorageService>("ls");
    const api = inject<ApiService>("api");
    const route = useRoute();
    const reloadRouteDataAction = useReloadRouteData(route, api, toast);
    const reloadAppDataAction = useReloadAppData(ls, api);
    const accentColor = useSystemAccentColor();
    const model = computed(() => props.model);
    const values = computed(() => props.values);
    const parents = computed(() => props.parents);
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
    return {
      breadcrumbsBindings,
      accentColor,
      bannerSource,
      avatarSource,
      publicStatusChip,
      status,
      prettifiedHomepage,
      membershipsToShow,
    };
  },
});
</script>

<template>
  <v-container fluid>
    <v-card min-height="100" color="surface" class="position-relative">
      <v-toolbar color="transparent" density="compact">
        <v-toolbar-title class="font-weight-bold d-flex align-center" tag="h1">
          {{
            !id
              ? $t("pages.admin-integrations-gitlab-id-project.title")
              : $t("pages.admin-integrations-gitlab-id-project.title")
          }}
        </v-toolbar-title>
      </v-toolbar>
      <v-divider />
      <v-breadcrumbs v-bind="breadcrumbsBindings" />
      <v-divider />
      <v-toolbar color="transparent">
        <v-slide-group show-arrows class="mx-2">
          <v-slide-group-item>
            <v-btn
              variant="elevated"
              :color="accentColor"
              size="x-small"
              class="ma-2"
              type="button"
              height="24px"
              style="position: relative; top: 1px"
              :href="model.web_url"
              target="_blank"
            >
              <!-- <v-icon class="me-2">mdi-open-in-app</v-icon> -->
              <v-img
                :src="iconGitLab"
                :aspect-ratio="1"
                width="13"
                height="13"
                class="me-2"
              />
              {{
                $t(
                  "pages.admin-integrations-gitlab-id-project.content.openInGitLab",
                )
              }}
            </v-btn>
          </v-slide-group-item>
          <v-slide-group-item>
            <v-btn
              variant="elevated"
              :color="accentColor"
              size="x-small"
              class="ma-2"
              type="button"
              height="24px"
              style="position: relative; top: 1px"
              @click="copyToClipboard(model.git_http_url)"
            >
              <v-icon class="me-2">mdi-content-copy</v-icon>
              {{
                $t(
                  "pages.admin-integrations-gitlab-id-project.content.copyGitHttpUrl",
                )
              }}
            </v-btn>
          </v-slide-group-item>
          <v-slide-group-item>
            <v-btn
              variant="elevated"
              :color="accentColor"
              size="x-small"
              class="ma-2"
              type="button"
              height="24px"
              style="position: relative; top: 1px"
              @click="copyToClipboard(model.git_ssh_url)"
            >
              <v-icon class="me-2">mdi-content-copy</v-icon>
              {{
                $t(
                  "pages.admin-integrations-gitlab-id-project.content.copyGitSshUrl",
                )
              }}
            </v-btn>
          </v-slide-group-item>
          <v-slide-group-item>
            <v-btn
              variant="elevated"
              color="light-blue-lighten-3"
              size="x-small"
              class="ma-2"
              type="button"
              height="24px"
              style="position: relative; top: 1px"
              :loading="enqueueingJobToInstallWebhooks"
              @click="doEnqueueJobToInstallWebhooks"
            >
              <v-img
                :src="iconWebhooks"
                :aspect-ratio="1"
                width="13"
                height="13"
                class="me-2"
              />
              {{
                $t(
                  "pages.admin-integrations-gitlab-id-project.content.enqueueJobToInstallWebhooks",
                )
              }}
            </v-btn>
          </v-slide-group-item>
          <v-slide-group-item>
            <v-btn
              variant="elevated"
              :color="accentColor"
              size="x-small"
              class="ma-2"
              type="button"
              height="24px"
              :loading="enqueueingJobToFetchEntities"
              style="position: relative; top: 1px"
              @click="doEnqueueJobToFetchEntities"
            >
              <v-icon class="me-2">mdi-source-branch-sync</v-icon>
              {{ $t("pages.admin-integrations-gitlab-id.entities.cta") }}
            </v-btn>
          </v-slide-group-item>
        </v-slide-group>
      </v-toolbar>
      <v-divider />
      <v-toolbar color="transparent" density="compact">
        <v-toolbar-title
          class="font-weight-normal d-flex align-center"
          tag="small"
        >
          {{
            $t(
              "pages.admin-integrations-gitlab-id-project.content.associatedProjects",
            )
          }}
        </v-toolbar-title>
      </v-toolbar>
      <v-divider />
      <v-table>
        <thead>
          <tr>
            <th>
              {{
                $t(
                  "pages.admin-integrations-gitlab-id-project.content.associatedProjectsTable.headers.name",
                )
              }}
            </th>
            <th>
              {{
                $t(
                  "pages.admin-integrations-gitlab-id-project.content.associatedProjectsTable.headers.isAssociated",
                )
              }}
            </th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="p in projectValues" :key="`project-${p.value}`">
            <td>{{ p.label }}</td>
            <td width="100" class="text-center">
              <div class="d-flex w-100 justify-center">
                <v-switch
                  v-model="associatedProjects"
                  color="accent"
                  :value="p.value"
                  multiple
                  hide-details
                />
              </div>
            </td>
          </tr>
        </tbody>
      </v-table>
      <v-fab
        v-show="dirty"
        fixed
        color="accent"
        app
        location="bottom right"
        :loading="saving"
        icon="mdi-content-save"
        :style="{ bottom: '24px', right: '24px' }"
        appear
        @click="doSave"
      />
    </v-card>
  </v-container>
</template>

<script lang="ts">
import {
  defineComponent,
  computed,
  inject,
  ref,
  watch,
  onMounted,
  onBeforeUnmount,
} from "vue";
import { useI18n } from "vue-i18n";
import { useRoute } from "vue-router";
import {
  useSystemAccentColor,
  useReloadRouteData,
  checkObjectEquality,
  useCopyToClipboard,
} from "@/utils/app";
import { useActionCableConsumer } from "@/utils/realtime";
import iconGitLab from "@/assets/images/icon-gitlab.svg?url";
import iconWebhooks from "@/assets/images/icon-webhooks.svg?url";

import type { PropType } from "vue";
import type { ToastService, ApiService, BusService } from "@jakguru/vueprint";
import type {
  GitLabProject,
  GitLabProjectValuesProp,
  QueryResponse,
} from "@/friday";
import type Cable from "@rails/actioncable";

export default defineComponent({
  name: "AdminIntegrationsGitLabProject",
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
    parentName: {
      type: String,
      required: true,
    },
    parentId: {
      type: [String, Number] as PropType<string | number | null | undefined>,
      required: true,
    },
    model: {
      type: Object as PropType<GitLabProject>,
      required: true,
    },
    projects: {
      type: Object as PropType<QueryResponse>,
      required: true,
    },
    values: {
      type: Object as PropType<GitLabProjectValuesProp>,
      required: true,
    },
  },
  setup(props) {
    const { t } = useI18n({ useScope: "global" });
    const toast = inject<ToastService>("toast");
    const api = inject<ApiService>("api");
    const bus = inject<BusService>("bus");
    const route = useRoute();
    const reloadRouteDataAction = useReloadRouteData(route, api, toast);
    const accentColor = useSystemAccentColor();
    const copyToClipboard = useCopyToClipboard(
      t("messages.copiedToClipboard"),
      t("messages.failedToCopyToClipboard"),
    );
    const formAuthenticityToken = computed(() => props.formAuthenticityToken);
    const parentName = computed(() => props.parentName);
    const id = computed(() => props.id);
    const parentId = computed(() => props.parentId);
    const model = computed(() => props.model);
    const values = computed(() => props.values);
    const projectValues = computed(() => values.value.projects);
    const breadcrumbsBindings = computed(() => ({
      items: [
        { title: t("pages.admin.title"), to: { name: "admin" } },
        {
          title: t("pages.admin-integrations.title"),
          to: { name: "admin-integrations" },
        },
        {
          title: t("pages.admin-integrations-gitlab.title"),
          to: { name: "admin-integrations-gitlab" },
        },
        {
          title: parentName.value,
          to: {
            name: "admin-integrations-gitlab-id",
            params: { id: parentId.value },
            query: { tab: "projects" },
          },
        },
        {
          title: model.value.name_with_namespace,
        },
      ],
    }));

    const associatedProjects = ref<number[]>([]);
    watch(
      () => model.value.projects,
      (is) => {
        associatedProjects.value = is;
      },
      { immediate: true, deep: true },
    );
    const dirty = computed(() => {
      return !checkObjectEquality(
        associatedProjects.value,
        model.value.projects,
      );
    });
    const saving = ref(false);
    const doSave = async () => {
      if (!api || !toast) {
        return;
      }
      saving.value = true;
      const { status } = await api.put(
        `/admin/integrations/gitlab/${parentId.value}/projects/${model.value.project_id}`,
        {
          project_ids: associatedProjects.value,
          authenticity_token: formAuthenticityToken.value,
        },
      );
      if (201 === status) {
        toast.fire({
          icon: "success",
          title: t("pages.admin-integrations-gitlab-id-project.onSave.success"),
        });
        reloadRouteDataAction.call();
      } else {
        toast.fire({
          icon: "error",
          title: t("pages.admin-integrations-gitlab-id-project.onSave.error"),
        });
      }
      saving.value = false;
    };
    const enqueueingJobToInstallWebhooks = ref(false);
    const doEnqueueJobToInstallWebhooks = async () => {
      if (!api || !toast) {
        return;
      }
      enqueueingJobToInstallWebhooks.value = true;
      const { status } = await api.post(
        `/admin/integrations/gitlab/${parentId.value}/projects/${model.value.project_id}/actions/install-webhooks`,
        {
          authenticity_token: formAuthenticityToken.value,
        },
      );
      if (202 === status) {
        toast.fire({
          icon: "success",
          title: t(
            "pages.admin-integrations-gitlab-id-project.onEnqueueJobToInstallWebhooks.success",
          ),
        });
      } else {
        toast.fire({
          icon: "error",
          title: t(
            "pages.admin-integrations-gitlab-id-project.onEnqueueJobToInstallWebhooks.error",
          ),
        });
      }
      enqueueingJobToInstallWebhooks.value = false;
    };

    const enqueueingJobToFetchEntities = ref(false);
    const doEnqueueJobToFetchEntities = async () => {
      if (!api || !toast) {
        return;
      }
      enqueueingJobToFetchEntities.value = true;
      const { status } = await api.post(
        `/admin/integrations/gitlab/${parentId.value}/entities/`,
        {
          authenticity_token: formAuthenticityToken.value,
          child: model.value.id,
        },
      );
      if (202 === status) {
        toast.fire({
          icon: "success",
          title: t(
            "pages.admin-integrations-gitlab-id-project.onEnqueueJobToFetchEntities.success",
          ),
        });
      } else {
        toast.fire({
          icon: "error",
          title: t(
            "pages.admin-integrations-gitlab-id-project.onEnqueueJobToFetchEntities.error",
          ),
        });
      }
      enqueueingJobToFetchEntities.value = false;
    };

    const consumer = useActionCableConsumer();
    const projectGitLabProjectSubscription = ref<
      Cable.Subscription | undefined
    >(undefined);
    onMounted(() => {
      if (consumer) {
        if (projectGitLabProjectSubscription.value) {
          projectGitLabProjectSubscription.value.unsubscribe();
        }
        projectGitLabProjectSubscription.value = consumer.subscriptions.create(
          {
            channel: "FridayPlugin::RealTimeUpdatesChannel",
            room: "project_gitlab_project",
          },
          {
            received: (data: {
              gitlab_instance_id: number;
              gitlab_project_id: number;
              from?: string;
            }) => {
              if (
                data.gitlab_instance_id === parentId.value &&
                data.gitlab_project_id === id.value &&
                (!data.from || bus?.uuid !== data.from)
              ) {
                reloadRouteDataAction.call();
              }
            },
          },
        );
      }
    });
    onBeforeUnmount(() => {
      if (projectGitLabProjectSubscription.value) {
        projectGitLabProjectSubscription.value.unsubscribe();
      }
    });
    return {
      breadcrumbsBindings,
      accentColor,
      iconGitLab,
      copyToClipboard,
      associatedProjects,
      projectValues,
      dirty,
      saving,
      doSave,
      iconWebhooks,
      enqueueingJobToInstallWebhooks,
      doEnqueueJobToInstallWebhooks,
      enqueueingJobToFetchEntities,
      doEnqueueJobToFetchEntities,
    };
  },
});
</script>

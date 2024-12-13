<template>
  <v-container fluid>
    <v-card min-height="100" color="surface" class="position-relative">
      <v-toolbar color="transparent" density="compact">
        <v-toolbar-title class="font-weight-bold d-flex align-center" tag="h1">
          {{
            !id
              ? $t("pages.admin-integrations-github-id-repository.title")
              : $t("pages.admin-integrations-github-id-repository.title")
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
                :src="iconGitHub"
                :aspect-ratio="1"
                width="13"
                height="13"
                class="me-2"
              />
              {{
                $t(
                  "pages.admin-integrations-github-id-repository.content.openInGitHub",
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
                  "pages.admin-integrations-github-id-repository.content.copyGitHttpUrl",
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
                  "pages.admin-integrations-github-id-repository.content.copyGitSshUrl",
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
                  "pages.admin-integrations-github-id-repository.content.enqueueJobToInstallWebhooks",
                )
              }}
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
              "pages.admin-integrations-github-id-repository.content.associatedProjects",
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
                  "pages.admin-integrations-github-id-repository.content.associatedProjectsTable.headers.name",
                )
              }}
            </th>
            <th>
              {{
                $t(
                  "pages.admin-integrations-github-id-repository.content.associatedProjectsTable.headers.isAssociated",
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
import iconGitHub from "@/assets/images/icon-github.svg?url";
import iconWebhooks from "@/assets/images/icon-webhooks.svg?url";

import type { PropType } from "vue";
import type { ToastService, ApiService, BusService } from "@jakguru/vueprint";
import type {
  GitHubRepository,
  GitHubRepositoryValuesProp,
  QueryResponse,
} from "@/friday";
import type Cable from "@rails/actioncable";

export default defineComponent({
  name: "AdminIntegrationsGitHubRepository",
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
      type: Object as PropType<GitHubRepository>,
      required: true,
    },
    projects: {
      type: Object as PropType<QueryResponse>,
      required: true,
    },
    values: {
      type: Object as PropType<GitHubRepositoryValuesProp>,
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
          title: t("pages.admin-integrations-github.title"),
          to: { name: "admin-integrations-github" },
        },
        {
          title: parentName.value,
          to: {
            name: "admin-integrations-github-id",
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
        `/admin/integrations/github/${parentId.value}/repositories/${model.value.repository_id}`,
        {
          project_ids: associatedProjects.value,
          authenticity_token: formAuthenticityToken.value,
        },
      );
      if (201 === status) {
        toast.fire({
          icon: "success",
          title: t(
            "pages.admin-integrations-github-id-repository.onSave.success",
          ),
        });
        reloadRouteDataAction.call();
      } else {
        toast.fire({
          icon: "error",
          title: t(
            "pages.admin-integrations-github-id-repository.onSave.error",
          ),
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
        `/admin/integrations/github/${parentId.value}/repositories/${model.value.repository_id}/actions/install-webhooks`,
        {
          authenticity_token: formAuthenticityToken.value,
        },
      );
      if (202 === status) {
        toast.fire({
          icon: "success",
          title: t(
            "pages.admin-integrations-github-id-repository.onEnqueueJobToInstallWebhooks.success",
          ),
        });
      } else {
        toast.fire({
          icon: "error",
          title: t(
            "pages.admin-integrations-github-id-repository.onEnqueueJobToInstallWebhooks.error",
          ),
        });
      }
      enqueueingJobToInstallWebhooks.value = false;
    };

    const consumer = useActionCableConsumer();
    const projectGitHubRepositorySubscription = ref<
      Cable.Subscription | undefined
    >(undefined);
    onMounted(() => {
      if (consumer) {
        if (projectGitHubRepositorySubscription.value) {
          projectGitHubRepositorySubscription.value.unsubscribe();
        }
        projectGitHubRepositorySubscription.value =
          consumer.subscriptions.create(
            {
              channel: "FridayPlugin::RealTimeUpdatesChannel",
              room: "project_github_repository",
            },
            {
              received: (data: {
                github_instance_id: number;
                github_repository_id: number;
                from?: string;
              }) => {
                if (
                  data.github_instance_id === parentId.value &&
                  data.github_repository_id === id.value &&
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
      if (projectGitHubRepositorySubscription.value) {
        projectGitHubRepositorySubscription.value.unsubscribe();
      }
    });
    return {
      breadcrumbsBindings,
      accentColor,
      iconGitHub,
      copyToClipboard,
      associatedProjects,
      projectValues,
      dirty,
      saving,
      doSave,
      iconWebhooks,
      enqueueingJobToInstallWebhooks,
      doEnqueueJobToInstallWebhooks,
    };
  },
});
</script>

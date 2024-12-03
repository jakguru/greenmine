<template>
  <v-container fluid>
    <v-card min-height="100" color="surface">
      <v-toolbar color="transparent" density="compact">
        <v-toolbar-title class="font-weight-bold d-flex align-center" tag="h1">
          {{
            !id
              ? $t("pages.admin-integrations-gitlab-id.title")
              : $t("pages.admin-integrations-gitlab-id.title")
          }}
        </v-toolbar-title>
      </v-toolbar>
      <v-divider />
      <v-breadcrumbs v-bind="breadcrumbsBindings" />
      <v-divider />
      <v-tabs v-bind="vTabBindings" />
      <v-divider />
      <template v-if="tab === 'projects'">
        <v-container fluid>
          <v-toolbar color="transparent">
            <v-slide-group show-arrows class="mx-2">
              <v-slide-group-item v-if="showFiltersMenu">
                <QueriesPartialFilters
                  v-model:model-value="value"
                  :dirty="dirty"
                  :submitting="submitting"
                  @submit="onSubmit"
                />
              </v-slide-group-item>
              <v-slide-group-item v-if="showColumnsMenu">
                <QueriesPartialColumns
                  v-model:model-value="value"
                  :dirty="dirty"
                  :submitting="submitting"
                  @submit="onSubmit"
                />
              </v-slide-group-item>
              <v-slide-group-item v-if="showSortingMenu">
                <QueriesPartialSorting
                  v-model:model-value="value"
                  :dirty="dirty"
                  :submitting="submitting"
                  @submit="onSubmit"
                />
              </v-slide-group-item>
              <v-slide-group-item v-if="showGroupingsMenu">
                <QueriesPartialGroupings
                  v-model:model-value="value"
                  :dirty="dirty"
                  :submitting="submitting"
                  @submit="onSubmit"
                />
              </v-slide-group-item>
              <v-slide-group-item v-if="showAdditional">
                <QueriesPartialOptions
                  v-model:model-value="value"
                  :dirty="dirty"
                  :submitting="submitting"
                  @submit="onSubmit"
                />
              </v-slide-group-item>
              <v-slide-group-item>
                <v-btn
                  variant="elevated"
                  :color="accentColor"
                  size="x-small"
                  class="ma-2"
                  type="submit"
                  height="24px"
                  :disabled="!dirty"
                  :loading="submitting"
                  style="position: relative; top: 1px"
                >
                  <v-icon class="me-2">mdi-check</v-icon>
                  {{ $t("labels.apply") }}
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
                  :loading="submitting"
                  :disabled="!dirty"
                  style="position: relative; top: 1px"
                  @click="onReset"
                >
                  <v-icon class="me-2">mdi-restore</v-icon>
                  {{ $t("labels.reset") }}
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
                  :loading="submitting"
                  style="position: relative; top: 1px"
                  @click="onRefresh"
                >
                  <v-icon class="me-2">mdi-refresh</v-icon>
                  {{ $t("labels.refresh") }}
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
                  :loading="submitting"
                  style="position: relative; top: 1px"
                  @click="doFetchProjects"
                >
                  <v-icon class="me-2">mdi-cloud-sync</v-icon>
                  {{ $t("pages.admin-integrations-gitlab-id.projects.cta") }}
                </v-btn>
              </v-slide-group-item>
            </v-slide-group>
          </v-toolbar>
          <QueriesPartialDataTable
            v-model:model-value="value"
            v-model:payload-value="payloadValue"
            :query="query"
            :payload="payload"
            :submitting="submitting"
            :dirty="dirty"
            filter-to-id-field="gitlab_project_id"
            :get-action-items="getActionMenuItems"
            :parent="modelAsParent"
            @submit="onSubmit"
            @refresh="onRefresh"
          />
        </v-container>
      </template>
      <template v-else-if="tab === 'users'">
        <v-container fluid>
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
                  :loading="submitting"
                  style="position: relative; top: 1px"
                  @click="doFetchUsers"
                >
                  <v-icon class="me-2">mdi-cloud-sync</v-icon>
                  {{ $t("pages.admin-integrations-gitlab-id.users.cta") }}
                </v-btn>
              </v-slide-group-item>
            </v-slide-group>
          </v-toolbar>
          <v-table>
            <thead>
              <tr>
                <th>{{ $t("labels.name") }}</th>
                <th>{{ $t("labels.username") }}</th>
                <th>{{ $t("labels.localUser") }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="user in model.users" :key="user.user_id">
                <td width="25%">{{ user.name }}</td>
                <td width="25%">
                  <a :href="`${model.url}/${user.username}`" target="_blank">
                    @{{ user.username }}
                  </a>
                </td>
                <td width="50%">
                  <v-autocomplete
                    v-model:model-value="
                      userGitlabUserModelValues[user.user_id.toString()]
                    "
                    :items="userValues"
                    :loading="usersSaving.includes(user.user_id)"
                    :clearable="!usersSaving.includes(user.user_id)"
                    :disabled="usersSaving.includes(user.user_id)"
                    :hide-details="true"
                    item-title="label"
                    density="compact"
                  />
                </td>
              </tr>
              <tr v-if="model.users.length === 0">
                <td colspan="3" class="text-center">
                  {{ $t("labels.noData") }}
                </td>
              </tr>
            </tbody>
          </v-table>
        </v-container>
      </template>
      <template v-else>
        <FridayForm
          v-bind="fridayFormBindings"
          ref="renderedForm"
          @success="onSuccess"
          @error="onError"
        >
          <template #afterRows="{ isLoading, submit, reset }">
            <v-row>
              <v-col cols="12">
                <div class="d-flex w-100 justify-end">
                  <v-btn
                    variant="elevated"
                    :color="accentColor"
                    size="x-small"
                    class="ma-2"
                    type="button"
                    height="24px"
                    :loading="isLoading"
                    @click="reset"
                  >
                    <v-icon class="me-2">mdi-restore</v-icon>
                    {{ $t("labels.reset") }}
                  </v-btn>
                  <v-btn
                    variant="elevated"
                    :color="accentColor"
                    size="x-small"
                    class="ma-2 me-0"
                    type="button"
                    height="24px"
                    :loading="isLoading"
                    @click="submit"
                  >
                    <v-icon class="me-2">mdi-check</v-icon>
                    {{ $t("labels.save") }}
                  </v-btn>
                </div>
              </v-col>
            </v-row>
          </template>
        </FridayForm>
      </template>
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
  h,
} from "vue";
import { useI18n } from "vue-i18n";
import { VTextField } from "vuetify/components/VTextField";
import { VSwitch } from "vuetify/components/VSwitch";
import { VListItem } from "vuetify/components/VList";
import { VImg } from "vuetify/components/VImg";
import { VPasswordField } from "@/components/fields";
import { useRoute, useRouter } from "vue-router";
import { makeNewQueryPayloadFromQueryAndQueryPayload } from "@/friday";
import {
  useSystemAccentColor,
  useReloadRouteData,
  useReloadAppData,
  cloneObject,
  checkObjectEquality,
  loadRouteData,
  useOnError,
} from "@/utils/app";
import { useActionCableConsumer } from "@/utils/realtime";
import {
  Joi,
  getFormFieldValidator,
  FridayForm,
  tlds,
} from "@/components/forms";
import {
  QueriesPartialFilters,
  QueriesPartialColumns,
  QueriesPartialSorting,
  QueriesPartialGroupings,
  QueriesPartialOptions,
  QueriesPartialDataTable,
} from "@/components/queries/partials";
import { useRouteDataStore } from "@/stores/routeData";
import iconWebhooks from "@/assets/images/icon-webhooks.svg?url";

import type { PropType } from "vue";
import type {
  FridayFormStructure,
  FridayFormComponent,
} from "@/components/forms";
import type {
  ToastService,
  LocalStorageService,
  ApiService,
  BusService,
  BusEventCallbackSignatures,
} from "@jakguru/vueprint";
import type {
  Gitlab,
  GitlabValuesProp,
  QueryResponse,
  QueryData,
  QueryResponsePayload,
  Item,
} from "@/friday";
import type { RealtimeModelEventPayload } from "@/utils/realtime";
import type Cable from "@rails/actioncable";
import type { ActionMenuItem } from "@/components/queries/partials/action-menu";

export default defineComponent({
  name: "AdminIntegrationsGitlabEdit",
  components: {
    FridayForm,
    QueriesPartialFilters,
    QueriesPartialColumns,
    QueriesPartialSorting,
    QueriesPartialGroupings,
    QueriesPartialOptions,
    QueriesPartialDataTable,
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
      type: Object as PropType<Gitlab>,
      required: true,
    },
    projects: {
      type: Object as PropType<QueryResponse>,
      required: true,
    },
    values: {
      type: Object as PropType<GitlabValuesProp>,
      required: true,
    },
  },
  setup(props) {
    const toast = inject<ToastService>("toast");
    const ls = inject<LocalStorageService>("ls");
    const api = inject<ApiService>("api");
    const bus = inject<BusService>("bus");
    const route = useRoute();
    const router = useRouter();
    const reloadRouteDataAction = useReloadRouteData(route, api, toast);
    const reloadAppDataAction = useReloadAppData(ls, api);
    const accentColor = useSystemAccentColor();
    const formAuthenticityToken = computed(() => props.formAuthenticityToken);
    const id = computed(() => props.id);
    const model = computed(() => props.model);
    const values = computed(() => props.values);
    const userValues = computed(() => values.value.users);
    const modelAsParent = computed<Item>(() => ({
      id: id.value ? Number(id.value) : 0,
      entry: Object.assign(
        {},
        ...Object.keys(model.value).map((k) => ({
          [k]: {
            type: "String",
            display: model.value[k as keyof Gitlab].toString(),
            value: model.value[k as keyof Gitlab],
          },
        })),
      ),
      level: 0,
      group_name: null,
      group_count: null,
      group_totals: {},
    }));
    const { t } = useI18n({ useScope: "global" });
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
          title: t(`pages.admin-integrations-gitlab-id.title`),
        },
      ],
    }));
    const tabs = computed(() =>
      [
        {
          text: t("pages.admin-integrations-gitlab-id.tabs.integration"),
          value: "integration",
        },
        {
          text: t("pages.admin-integrations-gitlab-id.tabs.projects"),
          value: "projects",
        },
        {
          text: t("pages.admin-integrations-gitlab-id.tabs.users"),
          value: "users",
        },
      ].filter((v) => "undefined" !== typeof v),
    );
    const tab = computed({
      get: () => (route.query.tab as string | undefined) ?? "integration",
      set: (v: string) => {
        router.push({ query: Object.assign({}, route.query, { tab: v }) });
      },
    });
    const vTabBindings = computed(() => ({
      modelValue: tab.value,
      items: tabs.value,
      density: "compact" as const,
      mandatory: true,
      showArrows: true,
      sliderColor: "accent",
      "onUpdate:modelValue": (v: unknown) => {
        if (typeof v === "string") {
          tab.value = v;
        }
      },
    }));
    const modifyPayload = (payload: Record<string, unknown>) => {
      return {
        authenticity_token: formAuthenticityToken.value,
        gitlab: {
          ...payload,
        },
      };
    };
    const onSuccess = (_status: number, payload: unknown) => {
      reloadRouteDataAction.call();
      reloadAppDataAction.call();
      if (!toast) {
        alert(t(`pages.admin-integrations-gitlab-id.onSave.success`));
        return;
      } else {
        if (
          "object" === typeof payload &&
          null !== payload &&
          "id" in payload &&
          payload.id !== id.value
        ) {
          router.push({
            name: "admin-integrations-gitlab-id",
            params: {
              id: (payload.id as number).toString(),
            },
          });
        }
        toast.fire({
          title: t(`pages.admin-integrations-gitlab-id.onSave.success`),
          icon: "success",
        });
        return;
      }
    };
    const onError = useOnError("pages.admin-integrations-gitlab-id");
    const renderedForm = ref<FridayFormComponent | null>(null);
    const currentFieldValues = ref<Record<string, unknown>>({});
    const formStructure = computed<FridayFormStructure>(() => [
      [
        {
          cols: 12,
          md: 3,
          fieldComponent: VTextField,
          formKey: "name",
          valueKey: "name",
          label: t(`pages.admin-integrations-gitlab-id.content.fields.name`),
          bindings: {
            label: t(`pages.admin-integrations-gitlab-id.content.fields.name`),
          },
          validator: getFormFieldValidator(
            t,
            Joi.string().required().max(255),
            t(`pages.admin-integrations-gitlab-id.content.fields.name`),
          ),
        },
      ],
      [
        {
          cols: 12,
          md: 3,
          fieldComponent: VTextField,
          formKey: "url",
          valueKey: "url",
          label: t(`pages.admin-integrations-gitlab-id.content.fields.url`),
          bindings: {
            label: t(`pages.admin-integrations-gitlab-id.content.fields.url`),
          },
          validator: getFormFieldValidator(
            t,
            Joi.string()
              .required()
              .uri({
                scheme: ["https"],
                domain: {
                  allowUnicode: false,
                  tlds: {
                    allow: tlds,
                  },
                  minDomainSegments: 2,
                },
              })
              .regex(/^https:\/\/[^/]+$/)
              .messages({
                "string.pattern.base":
                  "Please provide only the base URL of the GitLab instance.",
              }),
            t(`pages.admin-integrations-gitlab-id.content.fields.url`),
          ),
        },
      ],
      [
        {
          cols: 12,
          md: 3,
          fieldComponent: VPasswordField,
          formKey: "api_token",
          valueKey: "api_token",
          label: t(
            `pages.admin-integrations-gitlab-id.content.fields.api_token`,
          ),
          bindings: {
            label: t(
              `pages.admin-integrations-gitlab-id.content.fields.api_token`,
            ),
          },
          validator: getFormFieldValidator(
            t,
            Joi.string()
              .required()
              .regex(/^glpat-.+/) // Ensure the string starts with 'glpat-'
              .messages({
                "string.pattern.base":
                  'The token must be a valid access token starting with "glpat-".',
              }),
            t(`pages.admin-integrations-gitlab-id.content.fields.url`),
          ),
        },
      ],
      [
        {
          cols: 12,
          md: 3,
          fieldComponent: VSwitch,
          formKey: "active",
          valueKey: "active",
          label: t(`pages.admin-integrations-gitlab-id.content.fields.active`),
          bindings: {
            label: t(
              `pages.admin-integrations-gitlab-id.content.fields.active`,
            ),
          },
        },
      ],
    ]);
    const formValues = computed<Record<string, unknown>>(() =>
      cloneObject(model.value as any as Record<string, unknown>),
    );
    const fridayFormBindings = computed(() => ({
      action: `/admin/integrations/gitlab${id.value ? `/${id.value}` : ""}`,
      method: id.value ? "put" : "post",
      structure: formStructure.value.filter(
        (r) => Array.isArray(r) && r.length > 0,
      ),
      // getFieldOverrides: (
      //   formKey: string,
      //   _value: unknown,
      //   values: Record<string, unknown>,
      // ) => {
      //   switch (formKey) {
      //     case "managed_group_ids":
      //       if (values.all_users_managed === true) {
      //         return { disabled: true, readonly: true };
      //       }
      //       break;
      //     case "permissions_all_trackers":
      //     case "permissions_tracker_ids":
      //       return {
      //         model: values,
      //         disabled: !(values.permissions as string[]).includes(
      //           "view_projects",
      //         ),
      //         readonly: !(values.permissions as string[]).includes(
      //           "view_projects",
      //         ),
      //       };
      //     case "permissions":
      //       return {
      //         model: values,
      //       };
      //   }
      //   return {};
      // },
      values: formValues.value,
      modifyPayload,
      validHttpStatus: 201,
      "onUpdate:values": (values: Record<string, unknown>) => {
        if (!checkObjectEquality(values, currentFieldValues.value)) {
          currentFieldValues.value = values;
        }
      },
    }));

    const projects = computed(() => props.projects);
    const query = computed(() => projects.value.query);
    const value = ref<QueryData>(cloneObject(query.value));
    const payload = computed(() => projects.value.payload);
    const payloadValue = ref<QueryResponsePayload>(cloneObject(payload.value));
    const dirty = computed(
      () =>
        !checkObjectEquality(value.value, query.value) ||
        !checkObjectEquality(payloadValue.value, payload.value),
    );
    watch(
      () => query.value,
      (v) => {
        value.value = cloneObject(v);
      },
      { immediate: true, deep: true },
    );
    watch(
      () => payload.value,
      (v) => {
        payloadValue.value = cloneObject(v);
      },
      { immediate: true, deep: true },
    );
    const onReset = () => {
      value.value = cloneObject(query.value);
    };
    const submitting = ref(false);
    const onSubmit = (e?: Event) => {
      if (e) {
        e.preventDefault();
        e.stopPropagation();
      }
      if (submitting.value) {
        return;
      }
      const payload = makeNewQueryPayloadFromQueryAndQueryPayload(
        value.value,
        payloadValue.value,
      );
      submitting.value = true;
      router
        // @ts-expect-error the query object's type is correct, but the router's type is not
        .push({ ...route, query: { tab: tab.value, ...payload } })
        .catch((e) => {
          console.warn(e);
          // noop
        })
        .finally(() => {
          submitting.value = false;
        });
    };
    const routeDataStore = useRouteDataStore();
    const onRefresh = async (e?: Event) => {
      if (e) {
        e.preventDefault();
        e.stopPropagation();
      }
      if (submitting.value) {
        return;
      }
      submitting.value = true;
      try {
        const d = await loadRouteData(route, api, toast);
        value.value = d.query;
        payloadValue.value = d.payload;
        routeDataStore.set(d);
        routeDataStore.store(d);
      } catch {
        // noop
      }
      submitting.value = false;
    };
    const showFiltersMenu = computed(() => {
      return Object.keys(query.value.filters.available).length > 0;
    });
    const showColumnsMenu = computed(() => {
      return (
        query.value.display.current === "list" &&
        query.value.columns.available.inline.length > 0
      );
    });
    const showSortingMenu = computed(() => {
      return (
        query.value.columns.available.sortable &&
        query.value.columns.available.sortable.length > 0
      );
    });
    const showGroupingsMenu = computed(() => {
      return (
        query.value.display.current === "list" &&
        query.value.columns.available.groupable.length > 0
      );
    });
    const showBlockable = computed(() => {
      return query.value.columns.available.block.length > 0;
    });
    const showTotalable = computed(() => {
      return query.value.columns.available.totalable.length > 0;
    });
    const showAdditional = computed(() => {
      return showBlockable.value || showTotalable.value;
    });
    router.afterEach(() => {
      submitting.value = false;
    });
    const modelRealtimeUpdateKey = computed<
      keyof BusEventCallbackSignatures | undefined
    >(() => undefined);
    const onModelRealtimeUpdate = (incoming: RealtimeModelEventPayload) => {
      const currentEntityIds = [...payload.value.items].map((i) => i.id);
      const hasMatch = incoming.updated.some((u) =>
        currentEntityIds.includes(u),
      );
      if (hasMatch) {
        onRefresh();
      }
    };
    watch(
      () => modelRealtimeUpdateKey.value,
      (is, was) => {
        if (bus) {
          if (was) {
            bus.off(was, onModelRealtimeUpdate, { local: true });
          }
          if (is) {
            bus.on(is, onModelRealtimeUpdate, { local: true });
          }
        }
      },
      { immediate: true },
    );
    const doFetchProjects = async () => {
      if (!api) {
        return;
      }
      const { status } = await api.post(
        `/admin/integrations/gitlab/${id.value}/projects`,
      );
      if (status !== 202) {
        toast?.fire({
          title: t("pages.admin-integrations-gitlab-id.projects.onFetch.error"),
          icon: "error",
        });
      } else {
        toast?.fire({
          title: t(
            "pages.admin-integrations-gitlab-id.projects.onFetch.success",
          ),
          icon: "success",
        });
      }
    };
    const doFetchUsers = async () => {
      if (!api) {
        return;
      }
      const { status } = await api.post(
        `/admin/integrations/gitlab/${id.value}/users`,
      );
      if (status !== 202) {
        toast?.fire({
          title: t("pages.admin-integrations-gitlab-id.users.onFetch.error"),
          icon: "error",
        });
      } else {
        toast?.fire({
          title: t("pages.admin-integrations-gitlab-id.users.onFetch.success"),
          icon: "success",
        });
      }
    };
    const consumer = useActionCableConsumer();
    const projectsSubscription = ref<Cable.Subscription | undefined>(undefined);
    const usersSubscription = ref<Cable.Subscription | undefined>(undefined);
    onMounted(() => {
      if (consumer) {
        if (projectsSubscription.value) {
          projectsSubscription.value.unsubscribe();
        }
        if (usersSubscription.value) {
          usersSubscription.value.unsubscribe();
        }
        projectsSubscription.value = consumer.subscriptions.create(
          {
            channel: "FridayPlugin::RealTimeUpdatesChannel",
            room: "gitlab_instance_projects",
          },
          {
            received: (data: { gitlab_instance_id: number; from?: string }) => {
              if (
                data.gitlab_instance_id === id.value &&
                (!data.from || bus?.uuid !== data.from)
              ) {
                onRefresh();
              }
            },
          },
        );
        usersSubscription.value = consumer.subscriptions.create(
          {
            channel: "FridayPlugin::RealTimeUpdatesChannel",
            room: "gitlab_instance_users",
          },
          {
            received: (data: { gitlab_instance_id: number; from?: string }) => {
              if (
                data.gitlab_instance_id === id.value &&
                (!data.from || bus?.uuid !== data.from)
              ) {
                onRefresh();
              }
            },
          },
        );
      }
    });
    onBeforeUnmount(() => {
      if (projectsSubscription.value) {
        projectsSubscription.value.unsubscribe();
      }
      if (usersSubscription.value) {
        usersSubscription.value.unsubscribe();
      }
    });
    const userGitlabUserModelValues = ref<Record<string, number | null>>({});
    watch(
      () => model.value.users,
      (users) => {
        users.forEach((user) => {
          userGitlabUserModelValues.value[user.user_id.toString()] =
            user.redmine_user_id;
        });
      },
      { immediate: true, deep: true },
    );
    const usersSaving = ref<number[]>([]);
    const usersSavingAbortControllersByUserId = ref<
      Record<string, AbortController>
    >({});
    const doSaveUserGitlabUserAssociation = async (
      gitlabUserId: number,
      redmineUserId: number | null,
    ) => {
      if (!api) {
        return;
      }
      if (usersSavingAbortControllersByUserId.value[gitlabUserId]) {
        usersSavingAbortControllersByUserId.value[gitlabUserId].abort();
      }
      usersSavingAbortControllersByUserId.value[gitlabUserId] =
        new AbortController();
      if (!usersSaving.value.includes(gitlabUserId)) {
        usersSaving.value.push(gitlabUserId);
      }
      try {
        const { status } = await api.put(
          `/admin/integrations/gitlab/${id.value}/users`,
          {
            authenticity_token: formAuthenticityToken.value,
            gitlab_user_id: gitlabUserId,
            redmine_user_id: redmineUserId,
          },
          {
            signal:
              usersSavingAbortControllersByUserId.value[gitlabUserId].signal,
          },
        );
        if (201 !== status) {
          toast?.fire({
            title: t("pages.admin-integrations-gitlab-id.users.onSave.error"),
            icon: "error",
          });
          userGitlabUserModelValues.value[gitlabUserId.toString()] =
            model.value.users.find((u) => u.user_id === gitlabUserId)
              ?.redmine_user_id ?? null;
        } else {
          await onRefresh();
        }
      } catch {
        // noop
      }
      const gitlabUserIdSavingIndex = usersSaving.value.indexOf(gitlabUserId);
      if (gitlabUserIdSavingIndex !== -1) {
        usersSaving.value.splice(gitlabUserIdSavingIndex, 1);
      }
    };
    watch(
      () => userGitlabUserModelValues.value,
      (vals) => {
        const differences = Object.keys(vals).filter(
          (k) =>
            model.value.users.find((u) => u.user_id === Number(k))
              ?.redmine_user_id !== vals[k as string],
        );
        differences.forEach((k) => {
          doSaveUserGitlabUserAssociation(Number(k), vals[k as string]);
        });
      },
      { deep: true },
    );

    const doInstallWebhooksForItems = async (items: Item[]) => {
      if (!api || !toast) {
        return;
      }
      const responses = await Promise.all(
        items.map(async (item) => {
          const { status } = await api.post(
            `/admin/integrations/gitlab/${id.value}/projects/${item.entry.project_id.value.toString()}/actions/install-webhooks`,
            {
              authenticity_token: formAuthenticityToken.value,
            },
          );
          return status === 202;
        }),
      );
      if (responses.every((r) => r === true)) {
        toast.fire({
          title: t(
            "pages.admin-integrations-gitlab-id.projects.onEnqueueJobToInstallWebhooks.success",
          ),
          icon: "success",
        });
      } else if (responses.some((r) => r === true) && responses.length > 1) {
        toast.fire({
          title: t(
            "pages.admin-integrations-gitlab-id.projects.onEnqueueJobToInstallWebhooks.warning",
          ),
          icon: "warning",
        });
      } else {
        toast.fire({
          title: t(
            "pages.admin-integrations-gitlab-id.projects.onEnqueueJobToInstallWebhooks.error",
          ),
          icon: "error",
        });
      }
    };

    const getActionMenuItems = (
      gitlabProjects: Item[],
      onDone: () => void,
      onFilterTo: () => void,
    ): ActionMenuItem[] => {
      if (gitlabProjects.length > 1) {
        return [
          {
            component: h(
              VListItem,
              {
                title: t("gitlabProjectActionMenu.installWebhook.title"),
                density: "compact",
                onClick: async () => {
                  await doInstallWebhooksForItems(gitlabProjects);
                  onDone();
                },
              },
              {
                append: () =>
                  h(VImg, {
                    src: iconWebhooks,
                    width: 22,
                    height: 22,
                    aspectRatio: 1,
                  }),
              },
            ),
          },
          {
            component: h(VListItem, {
              title: t("actionMenu.filterTo.title"),
              appendIcon: "mdi-filter",
              density: "compact",
              onClick: () => onFilterTo(),
            }),
          },
        ];
      }
      return [
        {
          component: h(VListItem, {
            title: t("labels.open"),
            prependIcon: "mdi-open-in-app",
            density: "compact",
            to: {
              name: "admin-integrations-gitlab-id-project-id",
              params: {
                id: id.value,
                projectId: gitlabProjects[0].entry.project_id.value.toString(),
              },
            },
          }),
        },
        {
          component: h(
            VListItem,
            {
              title: t("gitlabProjectActionMenu.installWebhook.title"),
              density: "compact",
              onClick: async () => {
                await doInstallWebhooksForItems(gitlabProjects);
                onDone();
              },
            },
            {
              append: () =>
                h(VImg, {
                  src: iconWebhooks,
                  width: 22,
                  height: 22,
                  aspectRatio: 1,
                }),
            },
          ),
        },
        {
          component: h(VListItem, {
            title: t("actionMenu.filterTo.title"),
            appendIcon: "mdi-filter",
            density: "compact",
            onClick: () => onFilterTo(),
          }),
        },
      ];
    };
    return {
      breadcrumbsBindings,
      tab,
      vTabBindings,
      fridayFormBindings,
      accentColor,
      modelAsParent,
      onSuccess,
      onError,
      currentFieldValues,
      renderedForm,
      value,
      dirty,
      submitting,
      onSubmit,
      onReset,
      onRefresh,
      query,
      payload,
      payloadValue,
      showFiltersMenu,
      showColumnsMenu,
      showSortingMenu,
      showGroupingsMenu,
      showAdditional,
      doFetchProjects,
      doFetchUsers,
      userValues,
      usersSaving,
      doSaveUserGitlabUserAssociation,
      userGitlabUserModelValues,
      getActionMenuItems,
    };
  },
});
</script>

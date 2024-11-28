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
      <v-divider />
      <v-list-item
        :title="$t('pages.admin-integrations-gitlab-id.projects.title')"
      >
        <template #append>
          <v-btn
            variant="elevated"
            :color="accentColor"
            @click="doFetchProjects"
          >
            <span
              v-text="$t('pages.admin-integrations-gitlab-id.projects.cta')"
            />
          </v-btn>
        </template>
      </v-list-item>
      <v-divider />
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
          :get-action-items="() => []"
          @submit="onSubmit"
          @refresh="onRefresh"
        />
      </v-container>
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
import { VTextField } from "vuetify/components/VTextField";
import { VSwitch } from "vuetify/components/VSwitch";
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

import type { PropType } from "vue";
import type {
  FridayFormStructure,
  FridayFormComponent,
} from "@/components/forms";
import type {
  SwalService,
  ToastService,
  LocalStorageService,
  ApiService,
  BusService,
  BusEventCallbackSignatures,
} from "@jakguru/vueprint";
import type {
  Gitlab,
  QueryResponse,
  QueryData,
  QueryResponsePayload,
} from "@/friday";
import type { RealtimeModelEventPayload } from "@/utils/realtime";
import type Cable from "@rails/actioncable";

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
  },
  setup(props) {
    const toast = inject<ToastService>("toast");
    const swal = inject<SwalService>("swal");
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
    const onError = (_status: number, payload: unknown) => {
      if (payload instanceof Error) {
        console.error(payload);
      }
      if (!swal) {
        alert(t(`pages.admin-integrations-gitlab-id.onSave.error`));
        return;
      } else {
        swal.fire({
          title: t(`pages.admin-integrations-gitlab-id.onSave.error`),
          icon: "error",
        });
        return;
      }
    };
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
        .push({ ...route, query: { ...payload } })
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
    const consumer = useActionCableConsumer();
    const subscription = ref<Cable.Subscription | undefined>(undefined);
    onMounted(() => {
      if (consumer) {
        if (subscription.value) {
          subscription.value.unsubscribe();
        }
        subscription.value = consumer.subscriptions.create(
          {
            channel: "FridayPlugin::RealTimeUpdatesChannel",
            room: "gitlab_instance_projects",
          },
          {
            received: (data: { gitlab_instance_id: number }) => {
              if (data.gitlab_instance_id === id.value) {
                onRefresh();
              }
            },
          },
        );
      }
    });
    onBeforeUnmount(() => {
      if (subscription.value) {
        subscription.value.unsubscribe();
      }
    });
    return {
      breadcrumbsBindings,
      fridayFormBindings,
      accentColor,
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
    };
  },
});
</script>

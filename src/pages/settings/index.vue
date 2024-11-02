<template>
  <v-container fluid>
    <v-card min-height="100" color="surface">
      <v-toolbar color="transparent" density="compact">
        <v-toolbar-title class="font-weight-bold d-flex align-center" tag="h1">
          <v-icon size="20" class="me-3" style="position: relative; top: -2px"
            >mdi-puzzle</v-icon
          >
          {{ $t("pages.settings.title") }}
        </v-toolbar-title>
      </v-toolbar>
      <v-divider />
      <v-breadcrumbs v-bind="breadcrumbsBindings" />
      <v-divider />
      <v-tabs v-bind="vTabBindings" />
      <v-divider />
      <FridayForm
        v-bind="fridayFormBindings"
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
    </v-card>
  </v-container>
</template>

<script lang="ts">
import { defineComponent, computed, inject, h, onMounted } from "vue";
import { useI18n } from "vue-i18n";
import { VTextField } from "vuetify/components/VTextField";
import { VAutocomplete } from "vuetify/components/VAutocomplete";
import { VSwitch } from "vuetify/components/VSwitch";
import { useRoute, useRouter } from "vue-router";
import {
  useSystemAccentColor,
  useReloadRouteData,
  useReloadAppData,
} from "@/utils/app";
import {
  Joi,
  getFormFieldValidator,
  FridayForm,
  tlds,
} from "@/components/forms";
import {
  VPasswordField,
  VMarkdownField,
  VQueryColumnSelectionField,
  VCSVField,
} from "@/components/fields";

import type { PropType } from "vue";
import type { SettingsPayloadSettings } from "@/friday";
import type {
  FridayFormStructure,
  FridayFormStructureField,
} from "@/components/forms";
import type {
  SwalService,
  ToastService,
  LocalStorageService,
  ApiService,
  BusService,
} from "@jakguru/vueprint";

export default defineComponent({
  name: "SettingsPluginId",
  components: { FridayForm },
  props: {
    errors: {
      type: [Object, Array] as PropType<Array<any> | null>,
      required: true,
    },
    settings: {
      type: Object as PropType<SettingsPayloadSettings>,
      required: true,
    },
    formAuthenticityToken: {
      type: String as PropType<string | undefined>,
      default: undefined,
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
    const settings = computed(() => props.settings);
    const formAuthenticityToken = computed(() => props.formAuthenticityToken);
    const { t } = useI18n({ useScope: "global" });
    const breadcrumbsBindings = computed(() => ({
      items: [
        { title: t("pages.admin.title"), to: { name: "admin" } },
        {
          title: t("pages.settings.title"),
        },
      ],
    }));
    const tabs = computed(() => [
      { text: t("pages.settings.content.tabs.general"), value: "general" },
      { text: t("pages.settings.content.tabs.display"), value: "display" },
      { text: t("pages.settings.content.tabs.users"), value: "users" },
      { text: t("pages.settings.content.tabs.projects"), value: "projects" },
      { text: t("pages.settings.content.tabs.issues"), value: "issues" },
      {
        text: t("pages.settings.content.tabs.activities"),
        value: "activities",
      },
      { text: t("pages.settings.content.tabs.files"), value: "files" },
      {
        text: t("pages.settings.content.tabs.notifications"),
        value: "notifications",
      },
      { text: t("pages.settings.content.tabs.email"), value: "email" },
      { text: t("pages.settings.content.tabs.api"), value: "api" },
      {
        text: t("pages.settings.content.tabs.repositories"),
        value: "repositories",
      },
    ]);
    const tab = computed({
      get: () => (route.query.tab as string | undefined) ?? "general",
      set: (v: string) => {
        router.push({ query: { tab: v } });
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
        settings: payload,
      };
    };
    const onSuccess = () => {
      reloadRouteDataAction.call();
      reloadAppDataAction.call();
      if (!toast) {
        alert(t("pages.settings.onSave.success"));
        return;
      } else {
        toast.fire({
          title: t("pages.settings.onSave.success"),
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
        alert(t("pages.settings.onSave.error"));
        return;
      } else {
        swal.fire({
          title: t("pages.settings.onSave.error"),
          icon: "error",
        });
        return;
      }
    };
    const makeFridayFormFieldFor = (
      key: keyof SettingsPayloadSettings,
      options: {
        cols: number;
        xs?: number;
        sm?: number;
        md?: number;
        lg?: number;
        xl?: number;
        xxl?: number;
        bindings?: Record<string, unknown>;
      },
    ): FridayFormStructureField => {
      const settingsFieldInfo = settings.value[key];
      switch (settingsFieldInfo.type) {
        case "text":
          return {
            cols: options.cols,
            xs: options.xs,
            sm: options.sm,
            md: options.md,
            lg: options.lg,
            xl: options.xl,
            xxl: options.xxl,
            fieldComponent: VTextField,
            formKey: settingsFieldInfo.props.formKey
              ? settingsFieldInfo.props.formKey
              : key,
            valueKey: key,
            label: t(`pages.settings.content.fields.${key}`),
            bindings: {
              ...options.bindings,
              ...settingsFieldInfo.props,
              label: t(`pages.settings.content.fields.${key}`),
            },
            validator: getFormFieldValidator(
              t,
              (() => {
                switch (settingsFieldInfo.props.type) {
                  case "email":
                    return Joi.string()
                      .email({ tlds: { allow: tlds } })
                      .required();
                  case "number":
                    if (
                      settingsFieldInfo.props.min &&
                      settingsFieldInfo.props.max
                    ) {
                      return Joi.number()
                        .min(settingsFieldInfo.props.min)
                        .max(settingsFieldInfo.props.max)
                        .required();
                    } else if (settingsFieldInfo.props.min) {
                      return Joi.number()
                        .min(settingsFieldInfo.props.min)
                        .required();
                    } else if (settingsFieldInfo.props.max) {
                      return Joi.number()
                        .max(settingsFieldInfo.props.max)
                        .required();
                    } else {
                      return Joi.number().required();
                    }
                  default:
                    return Joi.string().required();
                }
              })(),
              t(`pages.settings.content.fields.${key}`),
            ),
          };
        case "checkbox":
          return {
            cols: options.cols,
            xs: options.xs,
            sm: options.sm,
            md: options.md,
            lg: options.lg,
            xl: options.xl,
            xxl: options.xxl,
            fieldComponent: VSwitch,
            formKey: settingsFieldInfo.props.formKey
              ? settingsFieldInfo.props.formKey
              : key,
            valueKey: key,
            label: t(`pages.settings.content.fields.${key}`),
            bindings: {
              ...options.bindings,
              ...settingsFieldInfo.props,
              label: t(`pages.settings.content.fields.${key}`),
              falseValue: "0",
              trueValue: "1",
            },
          };
        case "select":
          return {
            cols: options.cols,
            xs: options.xs,
            sm: options.sm,
            md: options.md,
            lg: options.lg,
            xl: options.xl,
            xxl: options.xxl,
            fieldComponent: VAutocomplete,
            formKey: settingsFieldInfo.props.formKey
              ? settingsFieldInfo.props.formKey
              : key,
            valueKey: key,
            label: t(`pages.settings.content.fields.${key}`),
            bindings: {
              ...options.bindings,
              ...settingsFieldInfo.props,
              items: settingsFieldInfo.props.items.map((i: any) => ({
                label: t(i.label),
                value: i.value,
              })),
              label: t(`pages.settings.content.fields.${key}`),
              itemTitle: "label",
              itemValue: "value",
              chips: true === settingsFieldInfo.props.multiple,
              closableChips: true === settingsFieldInfo.props.multiple,
            },
          };
        case "csv":
          return {
            cols: options.cols,
            xs: options.xs,
            sm: options.sm,
            md: options.md,
            lg: options.lg,
            xl: options.xl,
            xxl: options.xxl,
            fieldComponent: VCSVField,
            formKey: settingsFieldInfo.props.formKey
              ? settingsFieldInfo.props.formKey
              : key,
            valueKey: key,
            label: t(`pages.settings.content.fields.${key}`),
            bindings: {
              ...options.bindings,
              ...settingsFieldInfo.props,
              label: t(`pages.settings.content.fields.${key}`),
            },
          };
        case "markdown":
          return {
            cols: options.cols,
            xs: options.xs,
            sm: options.sm,
            md: options.md,
            lg: options.lg,
            xl: options.xl,
            xxl: options.xxl,
            fieldComponent: VMarkdownField,
            formKey: settingsFieldInfo.props.formKey
              ? settingsFieldInfo.props.formKey
              : key,
            valueKey: key,
            label: t(`pages.settings.content.fields.${key}`),
            bindings: {
              ...options.bindings,
              ...settingsFieldInfo.props,
              label: t(`pages.settings.content.fields.${key}`),
            },
          };
        case "querycolumnselection":
          return {
            cols: options.cols,
            xs: options.xs,
            sm: options.sm,
            md: options.md,
            lg: options.lg,
            xl: options.xl,
            xxl: options.xxl,
            fieldComponent: VQueryColumnSelectionField,
            formKey: settingsFieldInfo.props.formKey
              ? settingsFieldInfo.props.formKey
              : key,
            valueKey: key,
            label: t(`pages.settings.content.fields.${key}`),
            bindings: {
              ...options.bindings,
              ...settingsFieldInfo.props,
              label: t(`pages.settings.content.fields.${key}`),
              items: settingsFieldInfo.props.items.map((i: any) => ({
                label: t(i.label),
                value: i.value,
              })),
            },
          };
        default:
          return {
            cols: options.cols,
            xs: options.xs,
            sm: options.sm,
            md: options.md,
            lg: options.lg,
            xl: options.xl,
            xxl: options.xxl,
            fieldComponent: h("span", {}, [
              "Unknown field type: ",
              h("code", {}, [settingsFieldInfo.type]),
              " for key: ",
              h("code", {}, [key]),
            ]),
            formKey: settingsFieldInfo.props.formKey
              ? settingsFieldInfo.props.formKey
              : key,
            valueKey: key,
            label: t(`pages.settings.content.fields.${key}`),
          };
      }
    };
    const formStructure = computed<FridayFormStructure>(() => {
      switch (tab.value) {
        case "general":
          return [
            [makeFridayFormFieldFor("app_title", { cols: 12 })],
            [makeFridayFormFieldFor("welcome_text", { cols: 12 })],
            [
              makeFridayFormFieldFor("protocol", { cols: 12, md: 6 }),
              makeFridayFormFieldFor("host_name", { cols: 12, md: 6 }),
            ],
          ];
        case "display":
          return [
            [makeFridayFormFieldFor("default_language", { cols: 12, md: 4 })],
            [
              makeFridayFormFieldFor("default_users_time_zone", {
                cols: 12,
                md: 4,
              }),
            ],
            [
              makeFridayFormFieldFor("force_default_language_for_anonymous", {
                cols: 12,
                md: 4,
              }),
            ],
            [
              makeFridayFormFieldFor("force_default_language_for_loggedin", {
                cols: 12,
                md: 4,
              }),
            ],
            [
              makeFridayFormFieldFor("search_results_per_page", {
                cols: 12,
                md: 4,
              }),
            ],
            [
              makeFridayFormFieldFor("activity_days_default", {
                cols: 12,
                md: 4,
              }),
            ],
            [makeFridayFormFieldFor("feeds_limit", { cols: 12, md: 4 })],
            [
              makeFridayFormFieldFor("wiki_compression", {
                cols: 12,
                md: 4,
              }),
            ],
            [
              makeFridayFormFieldFor("login_required", {
                cols: 12,
                sm: 6,
                md: 4,
              }),
            ],
            [
              makeFridayFormFieldFor("user_format", {
                cols: 12,
                sm: 6,
                md: 4,
              }),
              makeFridayFormFieldFor("gravatar_default", {
                cols: 12,
                sm: 6,
                md: 4,
              }),
              makeFridayFormFieldFor("gravatar_enabled", {
                cols: 12,
                sm: 6,
                md: 4,
              }),
            ],
            [
              makeFridayFormFieldFor("display_subprojects_issues", {
                cols: 12,
                sm: 6,
                md: 4,
              }),
            ],
            [
              makeFridayFormFieldFor("gantt_items_limit", {
                cols: 12,
                sm: 6,
                md: 4,
              }),
              makeFridayFormFieldFor("gantt_months_limit", {
                cols: 12,
                sm: 6,
                md: 4,
              }),
            ],
          ];
        case "users":
          return [
            [
              makeFridayFormFieldFor("self_registration", {
                cols: 12,
                sm: 6,
                md: 4,
              }),
              makeFridayFormFieldFor("show_custom_fields_on_registration", {
                cols: 12,
                sm: 6,
                md: 4,
              }),
              makeFridayFormFieldFor("unsubscribe", {
                cols: 12,
                sm: 6,
                md: 4,
              }),
            ],
            [
              makeFridayFormFieldFor("max_additional_emails", {
                cols: 12,
                sm: 6,
                md: 4,
              }),
            ],
            [
              makeFridayFormFieldFor("password_min_length", {
                cols: 12,
                sm: 6,
                md: 4,
              }),
              makeFridayFormFieldFor("password_required_char_classes", {
                cols: 12,
                sm: 6,
                md: 4,
              }),
            ],
            [
              makeFridayFormFieldFor("email_domains_allowed", {
                cols: 12,
              }),
            ],
            [
              makeFridayFormFieldFor("email_domains_denied", {
                cols: 12,
              }),
            ],
            [
              makeFridayFormFieldFor("password_max_age", {
                cols: 12,
                sm: 6,
                md: 4,
              }),
              makeFridayFormFieldFor("twofa", {
                cols: 12,
                sm: 6,
                md: 4,
              }),
              makeFridayFormFieldFor("lost_password", {
                cols: 12,
                sm: 6,
                md: 4,
              }),
            ],
            [
              makeFridayFormFieldFor("session_lifetime", {
                cols: 12,
                sm: 6,
                md: 4,
              }),
            ],
          ];
        case "api":
          return [
            [
              makeFridayFormFieldFor("rest_api_enabled", {
                cols: 12,
                sm: 6,
              }),
              makeFridayFormFieldFor("jsonp_enabled", {
                cols: 12,
                sm: 6,
              }),
            ],
          ];
        case "projects":
          return [
            [
              makeFridayFormFieldFor("default_projects_public", {
                cols: 12,
                sm: 6,
                md: 4,
              }),
              makeFridayFormFieldFor("sequential_project_identifiers", {
                cols: 12,
                sm: 6,
                md: 4,
              }),
            ],
            [
              makeFridayFormFieldFor("default_projects_modules", {
                cols: 12,
                sm: 6,
                md: 4,
              }),
              makeFridayFormFieldFor("default_projects_tracker_ids", {
                cols: 12,
                sm: 6,
                md: 4,
              }),
              makeFridayFormFieldFor("new_project_user_role_id", {
                cols: 12,
                sm: 6,
                md: 4,
              }),
            ],
            [
              makeFridayFormFieldFor("default_project_query", {
                cols: 12,
              }),
            ],
            [
              makeFridayFormFieldFor("project_list_defaults.column_names", {
                cols: 12,
              }),
            ],
          ];
        case "issues":
          return [
            [
              makeFridayFormFieldFor("issue_group_assignment", {
                cols: 12,
                sm: 6,
                md: 3,
              }),
            ],
            [
              makeFridayFormFieldFor("cross_project_subtasks", {
                cols: 12,
                sm: 6,
                md: 3,
              }),
              makeFridayFormFieldFor("cross_project_issue_relations", {
                cols: 12,
                sm: 6,
                md: 4,
              }),
            ],
            [
              makeFridayFormFieldFor("link_copied_issue", {
                cols: 12,
                sm: 6,
                md: 4,
              }),
              makeFridayFormFieldFor("close_duplicate_issues", {
                cols: 12,
                sm: 6,
                md: 3,
              }),
            ],
            [
              makeFridayFormFieldFor("non_working_week_days", {
                cols: 12,
                sm: 6,
                md: 4,
              }),
              makeFridayFormFieldFor(
                "default_issue_start_date_to_creation_date",
                {
                  cols: 12,
                  sm: 6,
                  md: 4,
                },
              ),
            ],
            [
              makeFridayFormFieldFor("issue_done_ratio", {
                cols: 12,
                sm: 6,
                md: 4,
              }),
              makeFridayFormFieldFor("parent_issue_dates", {
                cols: 12,
                sm: 6,
                md: 4,
              }),
              makeFridayFormFieldFor("parent_issue_done_ratio", {
                cols: 12,
                sm: 6,
                md: 4,
              }),
            ],
            [
              makeFridayFormFieldFor("default_issue_query", {
                cols: 12,
                sm: 6,
              }),
              makeFridayFormFieldFor("issue_list_default_totals", {
                cols: 12,
                sm: 6,
              }),
            ],
            [
              makeFridayFormFieldFor("issue_list_default_columns", {
                cols: 12,
              }),
            ],
          ];
        case "activities":
          return [];
        case "files":
          return [];
        case "notifications":
          return [];
        case "email":
          return [];
        case "repositories":
          return [];
        default:
          return [];
      }
    });
    const formValues = computed<Record<string, unknown>>(() =>
      Object.assign(
        {},
        ...Object.keys(settings.value).map((k) => ({
          [k]: settings.value[k as keyof typeof settings.value].value,
        })),
      ),
    );
    const fridayFormBindings = computed(() => ({
      action: router.resolve({ name: "settings-edit" }).href,
      method: "post",
      structure: formStructure.value,
      values: formValues.value,
      modifyPayload,
      validHttpStatus: 201,
    }));
    const onRtuApplication = () => {
      reloadRouteDataAction.call();
    };
    onMounted(() => {
      if (bus) {
        bus.on("rtu:application", onRtuApplication, { local: true });
      }
    });
    return {
      breadcrumbsBindings,
      vTabBindings,
      fridayFormBindings,
      accentColor,
      onSuccess,
      onError,
    };
  },
});
</script>

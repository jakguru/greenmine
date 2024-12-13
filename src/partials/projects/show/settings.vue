<template>
  <v-container fluid class="pa-0 page-projects-show-partial-settings">
    <v-tabs v-bind="vTabBindings" />
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
  </v-container>
</template>

<script lang="ts">
import { defineComponent, computed, inject, ref } from "vue";
import { useI18n } from "vue-i18n";
import { useRoute, useRouter } from "vue-router";
import {
  useReloadRouteData,
  useReloadAppData,
  cloneObject,
  checkObjectEquality,
  useOnError,
} from "@/utils/app";
import { Joi, getFormFieldValidator, FridayForm } from "@/components/forms";
import { VAutocomplete } from "vuetify/components/VAutocomplete";
import { VTextField } from "vuetify/components/VTextField";
import { VSwitch } from "vuetify/components/VSwitch";
import {
  VMarkdownField,
  VBase64EncodedImageField,
  VPrincipalMembershipField,
  VIssueCategoriesField,
} from "@/components/fields";

import type { PropType } from "vue";
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
  GitLabProject,
  GitHubRepository,
  FridayMenuItem,
  ProjectWikiPageLink,
  PrincipalRole,
  ProjectDocumentLink,
  File,
  MondayBoard,
  SelectableListItem,
} from "@/friday";
import type {
  FridayFormStructure,
  FridayFormComponent,
} from "@/components/forms";
import type {
  ToastService,
  LocalStorageService,
  ApiService,
} from "@jakguru/vueprint";

export default defineComponent({
  name: "ProjectsShowSettingsPartial",
  components: {
    FridayForm,
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
      type: Array as PropType<
        Array<{
          role: PrincipalRole;
          principals: Principal[];
        }>
      >,
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
      type: Array as PropType<GitLabProject[]>,
      required: true,
    },
    githubRepositories: {
      type: Array as PropType<GitHubRepository[]>,
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
      required: true,
    },
    surfaceColor: {
      type: String,
      required: true,
    },
    accentColor: {
      type: String,
      required: true,
    },
    hasModule: {
      type: Function as PropType<(input: string) => boolean>,
      required: true,
    },
    currentUserCan: {
      type: Function as PropType<(input: string) => boolean>,
      required: true,
    },
    possibleGitHubRepositories: {
      type: Array as PropType<SelectableListItem<number>[]>,
      required: true,
    },
    possibleGitLabProjects: {
      type: Array as PropType<SelectableListItem<number>[]>,
      required: true,
    },
  },
  setup(props) {
    const toast = inject<ToastService>("toast");
    const ls = inject<LocalStorageService>("ls");
    const api = inject<ApiService>("api");
    const model = computed(() => props.model);
    const values = computed(() => props.values);
    const route = useRoute();
    const router = useRouter();
    const reloadRouteDataAction = useReloadRouteData(route, api, toast);
    const reloadAppDataAction = useReloadAppData(ls, api);
    const formAuthenticityToken = computed(() => props.formAuthenticityToken);
    const id = computed(() => props.id);
    const parents = computed(() => values.value.parents);
    const modules = computed(() => values.value.modules);
    const activities = computed(() => values.value.activities);
    const members = computed(() => values.value.members);
    const roles = computed(() => values.value.roles);
    const trackers = computed(() => values.value.trackers);
    const issueCustomFields = computed(() => values.value.issueCustomFields);
    const versions = computed(() => values.value.versions);
    const assignees = computed(() => values.value.assignees);
    const queries = computed(() => values.value.queries);
    const possibleGitHubRepositories = computed(
      () => props.possibleGitHubRepositories,
    );
    const possibleGitLabProjects = computed(() => props.possibleGitLabProjects);
    const { t } = useI18n({ useScope: "global" });
    const tabs = computed(() => [
      { text: t("pages.projects-id-settings.tabs.project"), value: "info" },
      { text: t("pages.projects-id-settings.tabs.members"), value: "members" },
      { text: t("pages.projects-id-settings.tabs.issues"), value: "issues" },
      // {
      //   text: t("pages.projects-id-settings.tabs.categories"),
      //   value: "categories",
      // },
      // {
      //   text: t("pages.projects-id-settings.tabs.activities"),
      //   value: "activities",
      // },
      // {
      //   text: t("pages.projects-id-settings.tabs.versions"),
      //   value: "versions",
      // },
      // {
      //   text: t("pages.projects-id-settings.tabs.repositories"),
      //   value: "repositories",
      // },
      // {
      //   text: t("pages.projects-id-settings.tabs.sprints"),
      //   value: "sprints",
      // },
      {
        text: t("pages.projects-id-settings.tabs.github"),
        value: "github",
      },
      {
        text: t("pages.projects-id-settings.tabs.gitlab"),
        value: "gitlab",
      },
      // {
      //   text: t("pages.projects-id-settings.tabs.monday"),
      //   value: "monday",
      // },
      // { text: t("pages.projects-id-settings.tabs.boards"), value: "boards" },
    ]);
    const tab = computed({
      get: () => (route.params.tab as string | undefined) ?? "info",
      set: (v: string) => {
        if (v === "general") {
          router.push({
            name: "projects-id-settings",
            params: {
              id: route.params.id,
            },
          });
        } else {
          router.push({
            name: "projects-id-settings-tab",
            params: {
              id: route.params.id,
              tab: v,
            },
          });
        }
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
      const ret: any = {
        authenticity_token: formAuthenticityToken.value,
        project: {
          ...payload,
        },
      };
      if ("issue_categories" in ret.project) {
        ret.issue_categories = ret.project.issue_categories;
        delete ret.project.issue_categories;
      }
      return ret;
    };
    const onSuccess = (_status: number, payload: unknown) => {
      reloadRouteDataAction.call();
      reloadAppDataAction.call();
      if (!toast) {
        alert(t(`pages.projects-new.onSave.success`));
        return;
      } else {
        if (
          "object" === typeof payload &&
          null !== payload &&
          "id" in payload &&
          payload.id !== id.value &&
          "identifier" in payload
        ) {
          router.push({
            name: "projects-id-settings",
            params: {
              id: (payload.identifier as string).toString(),
            },
          });
        }
        toast.fire({
          title: t(`pages.projects-new.onSave.success`),
          icon: "success",
        });
        return;
      }
    };
    const onError = useOnError("pages.projects-new");
    const renderedForm = ref<FridayFormComponent | null>(null);
    const currentFieldValues = ref<Record<string, unknown>>({});
    const formStructure = computed<FridayFormStructure>(() => {
      switch (tab.value) {
        case "info":
          return [
            [
              {
                cols: 12,
                md: 6,
                lg: 8,
                fieldComponent: VTextField,
                formKey: "name",
                valueKey: "name",
                label: t(`pages.projects-id-settings.content.fields.name`),
                bindings: {
                  label: t(`pages.projects-id-settings.content.fields.name`),
                },
                validator: getFormFieldValidator(
                  t,
                  Joi.string().required().max(255),
                  t(`pages.projects-id-settings.content.fields.name`),
                ),
              },
              {
                cols: 12,
                md: 6,
                lg: 4,
                fieldComponent: VTextField,
                formKey: "identifier",
                valueKey: "identifier",
                label: t(
                  `pages.projects-id-settings.content.fields.identifier`,
                ),
                bindings: {
                  label: t(
                    `pages.projects-id-settings.content.fields.identifier`,
                  ),
                  readonly: true,
                  disabled: true,
                },
              },
            ],
            [
              {
                cols: 12,
                fieldComponent: VMarkdownField,
                formKey: "description",
                valueKey: "description",
                label: t(
                  `pages.projects-id-settings.content.fields.description`,
                ),
                bindings: {
                  label: t(
                    `pages.projects-id-settings.content.fields.description`,
                  ),
                },
              },
            ],
            [
              {
                cols: 12,
                md: 4,
                fieldComponent: VBase64EncodedImageField,
                formKey: "avatar",
                valueKey: "avatar",
                label: t(`pages.projects-id-settings.content.fields.avatar`),
                bindings: {
                  label: t(`pages.projects-id-settings.content.fields.avatar`),
                  height: 200,
                  clearable: true,
                },
              },
              {
                cols: 12,
                md: 8,
                fieldComponent: VBase64EncodedImageField,
                formKey: "banner",
                valueKey: "banner",
                label: t(`pages.projects-id-settings.content.fields.banner`),
                bindings: {
                  label: t(`pages.projects-id-settings.content.fields.banner`),
                  height: 200,
                  clearable: true,
                },
              },
            ],
            [
              {
                cols: 12,
                md: 9,
                fieldComponent: VTextField,
                formKey: "homepage",
                valueKey: "homepage",
                label: t(`pages.projects-id-settings.content.fields.homepage`),
                bindings: {
                  label: t(
                    `pages.projects-id-settings.content.fields.homepage`,
                  ),
                },
                validator: getFormFieldValidator(
                  t,
                  Joi.string().uri().allow("", null),
                  t(`pages.projects-id-settings.content.fields.homepage`),
                ),
              },
              {
                cols: 12,
                md: 3,
                fieldComponent: VSwitch,
                formKey: "is_public",
                valueKey: "is_public",
                label: t(`pages.projects-id-settings.content.fields.is_public`),
                bindings: {
                  label: t(
                    `pages.projects-id-settings.content.fields.is_public`,
                  ),
                },
              },
            ],
            [
              {
                cols: 12,
                md: 9,
                fieldComponent: VAutocomplete,
                formKey: "parent_id",
                valueKey: "parent_id",
                label: t(`pages.projects-id-settings.content.fields.parent_id`),
                bindings: {
                  label: t(
                    `pages.projects-id-settings.content.fields.parent_id`,
                  ),
                  items: parents.value,
                  itemTitle: "label",
                },
              },
              {
                cols: 12,
                md: 3,
                fieldComponent: VSwitch,
                formKey: "inherit_members",
                valueKey: "inherit_members",
                label: t(
                  `pages.projects-id-settings.content.fields.inherit_members`,
                ),
                bindings: {
                  label: t(
                    `pages.projects-id-settings.content.fields.inherit_members`,
                  ),
                },
              },
            ],
            [
              {
                cols: 12,
                fieldComponent: VAutocomplete,
                formKey: "enabled_module_names",
                valueKey: "enabled_module_names",
                label: t(
                  `pages.projects-id-settings.content.fields.enabled_module_names`,
                ),
                bindings: {
                  label: t(
                    `pages.projects-id-settings.content.fields.enabled_module_names`,
                  ),
                  items: modules.value,
                  itemTitle: "label",
                  multiple: true,
                  chips: true,
                  closableChips: true,
                },
              },
            ],
            [
              {
                cols: 12,
                fieldComponent: VAutocomplete,
                formKey: "activities",
                valueKey: "activities",
                label: t(
                  `pages.projects-id-settings.content.fields.activities`,
                ),
                bindings: {
                  label: t(
                    `pages.projects-id-settings.content.fields.activities`,
                  ),
                  items: activities.value,
                  itemTitle: "name",
                  itemValue: "id",
                  multiple: true,
                  chips: true,
                  closableChips: true,
                },
              },
            ],
          ];
        case "members":
          return [
            [
              {
                cols: 12,
                fieldComponent: VPrincipalMembershipField,
                formKey: "memberships",
                valueKey: "memberships",
                label: t(
                  `pages.projects-id-settings.content.fields.memberships`,
                ),
                bindings: {
                  label: t(
                    `pages.projects-id-settings.content.fields.memberships`,
                  ),
                  principals: members.value,
                  roles: roles.value,
                  itemTitle: "name",
                  multiple: true,
                  chips: true,
                  closableChips: true,
                },
              },
            ],
          ];
        case "issues":
          return [
            [
              {
                cols: 12,
                fieldComponent: VAutocomplete,
                formKey: "tracker_ids",
                valueKey: "tracker_ids",
                label: t(
                  `pages.projects-id-settings.content.fields.tracker_ids`,
                ),
                bindings: {
                  label: t(
                    `pages.projects-id-settings.content.fields.tracker_ids`,
                  ),
                  items: trackers.value,
                  itemTitle: "name",
                  itemValue: "id",
                  multiple: true,
                  chips: true,
                  closableChips: true,
                },
              },
            ],
            [
              {
                cols: 12,
                fieldComponent: VAutocomplete,
                formKey: "issue_custom_field_ids",
                valueKey: "issue_custom_field_ids",
                label: t(
                  `pages.projects-id-settings.content.fields.issue_custom_field_ids`,
                ),
                bindings: {
                  label: t(
                    `pages.projects-id-settings.content.fields.issue_custom_field_ids`,
                  ),
                  items: issueCustomFields.value,
                  itemTitle: "description",
                  itemValue: "id",
                  multiple: true,
                  chips: true,
                  closableChips: true,
                },
              },
            ],
            [
              {
                cols: 12,
                md: 4,
                fieldComponent: VAutocomplete,
                formKey: "default_version_id",
                valueKey: "default_version_id",
                label: t(
                  `pages.projects-id-settings.content.fields.default_version_id`,
                ),
                bindings: {
                  label: t(
                    `pages.projects-id-settings.content.fields.default_version_id`,
                  ),
                  items: versions.value,
                  itemTitle: "label",
                },
              },
              {
                cols: 12,
                md: 4,
                fieldComponent: VAutocomplete,
                formKey: "default_assigned_to_id",
                valueKey: "default_assigned_to_id",
                label: t(
                  `pages.projects-id-settings.content.fields.default_assigned_to_id`,
                ),
                bindings: {
                  label: t(
                    `pages.projects-id-settings.content.fields.default_assigned_to_id`,
                  ),
                  items: assignees.value,
                  itemTitle: "label",
                },
              },
              {
                cols: 12,
                md: 4,
                fieldComponent: VAutocomplete,
                formKey: "default_issue_query_id",
                valueKey: "default_issue_query_id",
                label: t(
                  `pages.projects-id-settings.content.fields.default_issue_query_id`,
                ),
                bindings: {
                  label: t(
                    `pages.projects-id-settings.content.fields.default_issue_query_id`,
                  ),
                  items: queries.value,
                  itemTitle: "label",
                },
              },
            ],
            [
              {
                cols: 12,
                fieldComponent: VIssueCategoriesField,
                formKey: "issue_categories",
                valueKey: "issue_categories",
                label: t(
                  `pages.projects-id-settings.content.fields.issue_categories`,
                ),
                bindings: {
                  label: t(
                    `pages.projects-id-settings.content.fields.issue_categories`,
                  ),
                  assignees: assignees.value,
                  roles: roles.value,
                },
              },
            ],
          ];
        // case "activities":
        //   return [];
        // case "versions":
        //   return [];
        case "github":
          return [
            [
              {
                cols: 12,
                fieldComponent: VAutocomplete,
                formKey: "github_repository_ids",
                valueKey: "github_repository_ids",
                label: t(
                  `pages.projects-id-settings.content.fields.github_repository_ids`,
                ),
                bindings: {
                  label: t(
                    `pages.projects-id-settings.content.fields.github_repository_ids`,
                  ),
                  items: possibleGitHubRepositories.value,
                  itemTitle: "label",
                  multiple: true,
                  chips: true,
                  closableChips: true,
                },
              },
            ],
          ];
        case "gitlab":
          return [
            [
              {
                cols: 12,
                fieldComponent: VAutocomplete,
                formKey: "gitlab_project_ids",
                valueKey: "gitlab_project_ids",
                label: t(
                  `pages.projects-id-settings.content.fields.gitlab_project_ids`,
                ),
                bindings: {
                  label: t(
                    `pages.projects-id-settings.content.fields.gitlab_project_ids`,
                  ),
                  items: possibleGitLabProjects.value,
                  itemTitle: "label",
                  multiple: true,
                  chips: true,
                  closableChips: true,
                },
              },
            ],
          ];
        default:
          return [];
      }
    });
    const formValues = computed<Record<string, unknown>>(() => {
      const ret = cloneObject(model.value as any as Record<string, unknown>);
      if (route.query.parent_id) {
        ret.parent_id = Number(route.query.parent_id);
      }
      return ret;
    });
    const fridayFormBindings = computed(() => ({
      action: `/projects/${model.value.identifier}`,
      method: "put",
      structure: formStructure.value.filter(
        (r) => Array.isArray(r) && r.length > 0,
      ),
      getFieldOverrides: (
        formKey: string,
        _value: unknown,
        values: Record<string, unknown>,
      ) => {
        switch (formKey) {
          case "inherit_members":
            if (!values.parent_id) {
              return { disabled: true, readonly: true, modelValue: false };
            }
            break;
        }
        return {};
      },
      values: formValues.value,
      modifyPayload,
      validHttpStatus: 201,
      "onUpdate:values": (values: Record<string, unknown>) => {
        if (!checkObjectEquality(values, currentFieldValues.value)) {
          currentFieldValues.value = values;
        }
      },
    }));
    return {
      vTabBindings,
      fridayFormBindings,
      onSuccess,
      onError,
      renderedForm,
    };
  },
});
</script>

<style lang="scss">
.page-projects-show-partial-settings {
}
</style>

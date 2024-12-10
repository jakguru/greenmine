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
  GitlabProject,
  FridayMenuItem,
  ProjectWikiPageLink,
  PrincipalRole,
  ProjectDocumentLink,
  File,
  MondayBoard,
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
    const identifierMaxLength = computed(
      () => values.value.identifierMaxLength,
    );
    const parents = computed(() => values.value.parents);
    const modules = computed(() => values.value.modules);
    const { t } = useI18n({ useScope: "global" });
    const tabs = computed(() => [
      { text: t("pages.projects-id-settings.tabs.project"), value: "info" },
      { text: t("pages.projects-id-settings.tabs.members"), value: "members" },
      { text: t("pages.projects-id-settings.tabs.issues"), value: "issues" },
      {
        text: t("pages.projects-id-settings.tabs.categories"),
        value: "categories",
      },
      {
        text: t("pages.projects-id-settings.tabs.activities"),
        value: "activities",
      },
      {
        text: t("pages.projects-id-settings.tabs.versions"),
        value: "versions",
      },
      {
        text: t("pages.projects-id-settings.tabs.repositories"),
        value: "repositories",
      },
      {
        text: t("pages.projects-id-settings.tabs.gitlab"),
        value: "gitlab",
      },
      { text: t("pages.projects-id-settings.tabs.boards"), value: "boards" },
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
      return {
        authenticity_token: formAuthenticityToken.value,
        project: {
          ...payload,
        },
      };
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
    const identifierFieldValidator = computed(() =>
      getFormFieldValidator(
        t,
        Joi.string()
          .required()
          .max(identifierMaxLength.value)
          .regex(/^[a-z0-9-_]+$/)
          .messages({
            "string.pattern.base":
              "Only lower case letters (a-z), numbers, dashes, and underscores are allowed.",
          }),
        t(`pages.users-id-edit.content.fields.mail`),
      ),
    );
    const formStructure = computed<FridayFormStructure>(() => []);
    const formValues = computed<Record<string, unknown>>(() => {
      const ret = cloneObject(model.value as any as Record<string, unknown>);
      if (route.query.parent_id) {
        ret.parent_id = Number(route.query.parent_id);
      }
      return ret;
    });
    const fridayFormBindings = computed(() => ({
      action: window.location.href,
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

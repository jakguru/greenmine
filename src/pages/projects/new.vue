<template>
  <v-container fluid>
    <v-card min-height="100" color="surface">
      <v-toolbar color="transparent" density="compact">
        <v-toolbar-title class="font-weight-bold d-flex align-center" tag="h1">
          {{ $t("pages.projects-new.title") }}
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
    </v-card>
  </v-container>
</template>

<script lang="ts">
import { defineComponent, computed, inject, ref } from "vue";
import { useI18n } from "vue-i18n";
import { VTextField } from "vuetify/components/VTextField";
import { VSwitch } from "vuetify/components/VSwitch";
import {
  VMarkdownField,
  VRedmineCustomField,
  VBase64EncodedImageField,
} from "@/components/fields";
import { useRoute, useRouter } from "vue-router";
import {
  useSystemAccentColor,
  useReloadRouteData,
  useReloadAppData,
  cloneObject,
  checkObjectEquality,
  useOnError,
} from "@/utils/app";
import { Joi, getFormFieldValidator, FridayForm } from "@/components/forms";

import type { PropType } from "vue";
import type {
  FridayFormStructure,
  FridayFormComponent,
} from "@/components/forms";
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
} from "@/friday";
import { VAutocomplete } from "vuetify/components";

export default defineComponent({
  name: "ProjectsNew",
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
    const formAuthenticityToken = computed(() => props.formAuthenticityToken);
    const id = computed(() => props.id);
    const customFields = computed(() => props.customFields);
    const model = computed(() => props.model);
    const values = computed(() => props.values);
    const identifierMaxLength = computed(
      () => values.value.identifierMaxLength,
    );
    const parents = computed(() => values.value.parents);
    const modules = computed(() => values.value.modules);
    const { t } = useI18n({ useScope: "global" });
    const breadcrumbsBindings = computed(() => ({
      items: [
        { title: t("pages.projects.title"), to: { name: "projects" } },
        {
          title: t(`pages.projects-new.title`),
        },
      ],
    }));
    const parentId = computed({
      get: () => {
        return model.value.parent_id;
      },
      set: (value: number | null) => {
        router.push({
          name: route.name,
          params: route.params,
          query: Object.assign({}, route.query, {
            project: Object.assign({}, route.query.project, {
              parent_id: value,
            }),
          }),
        });
      },
    });
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
    const customFieldsForFormStructure = computed(() =>
      [...customFields.value].map((f) => [
        {
          cols: 12,
          fieldComponent: VRedmineCustomField,
          formKey: `custom_field_values.${f.id}`,
          valueKey: `custom_field_values_${f.id}`,
          label: f.name,
          bindings: {
            fieldConfiguration: f,
          },
        },
      ]),
    );
    const formStructure = computed<FridayFormStructure>(() => [
      [
        {
          cols: 12,
          md: 6,
          lg: 8,
          fieldComponent: VTextField,
          formKey: "name",
          valueKey: "name",
          label: t(`pages.projects-new.content.fields.name`),
          bindings: {
            label: t(`pages.projects-new.content.fields.name`),
          },
          validator: getFormFieldValidator(
            t,
            Joi.string().required().max(255),
            t(`pages.projects-new.content.fields.name`),
          ),
        },
        {
          cols: 12,
          md: 6,
          lg: 4,
          fieldComponent: VTextField,
          formKey: "identifier",
          valueKey: "identifier",
          label: t(`pages.projects-new.content.fields.identifier`),
          bindings: {
            label: t(`pages.projects-new.content.fields.identifier`),
          },
          validator: identifierFieldValidator.value,
        },
      ],
      [
        {
          cols: 12,
          fieldComponent: VMarkdownField,
          formKey: "description",
          valueKey: "description",
          label: t(`pages.projects-new.content.fields.description`),
          bindings: {
            label: t(`pages.projects-new.content.fields.description`),
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
          label: t(`pages.projects-new.content.fields.avatar`),
          bindings: {
            label: t(`pages.projects-new.content.fields.avatar`),
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
          label: t(`pages.projects-new.content.fields.banner`),
          bindings: {
            label: t(`pages.projects-new.content.fields.banner`),
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
          label: t(`pages.projects-new.content.fields.homepage`),
          bindings: {
            label: t(`pages.projects-new.content.fields.homepage`),
          },
          validator: getFormFieldValidator(
            t,
            Joi.string().uri().allow("", null),
            t(`pages.projects-new.content.fields.homepage`),
          ),
        },
        {
          cols: 12,
          md: 3,
          fieldComponent: VSwitch,
          formKey: "is_public",
          valueKey: "is_public",
          label: t(`pages.projects-new.content.fields.is_public`),
          bindings: {
            label: t(`pages.projects-new.content.fields.is_public`),
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
          label: t(`pages.projects-new.content.fields.parent_id`),
          bindings: {
            label: t(`pages.projects-new.content.fields.parent_id`),
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
          label: t(`pages.projects-new.content.fields.inherit_members`),
          bindings: {
            label: t(`pages.projects-new.content.fields.inherit_members`),
          },
        },
      ],
      [
        {
          cols: 12,
          fieldComponent: VAutocomplete,
          formKey: "enabled_module_names",
          valueKey: "enabled_module_names",
          label: t(`pages.projects-new.content.fields.enabled_module_names`),
          bindings: {
            label: t(`pages.projects-new.content.fields.enabled_module_names`),
            items: modules.value,
            itemTitle: "label",
            multiple: true,
            chips: true,
            closableChips: true,
          },
        },
      ],
    ]);
    const formValues = computed<Record<string, unknown>>(() =>
      cloneObject(model.value as any as Record<string, unknown>),
    );
    const fridayFormBindings = computed(() => ({
      action: `/projects${id.value ? `/${model.value.identifier}/settings` : ""}`,
      method: id.value ? "put" : "post",
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
        const valuesParentId = values.parent_id ? values.parent_id : null;
        const parentIdValue = parentId.value ? parentId.value : null;
        if (valuesParentId !== parentIdValue) {
          parentId.value = valuesParentId as number;
        }
      },
    }));
    return {
      breadcrumbsBindings,
      fridayFormBindings,
      accentColor,
      onSuccess,
      onError,
      currentFieldValues,
      renderedForm,
      customFieldsForFormStructure,
    };
  },
});
</script>

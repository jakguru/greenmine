<template>
  <v-container fluid>
    <v-card min-height="100" color="surface">
      <v-toolbar color="transparent" density="compact">
        <v-toolbar-title class="font-weight-bold d-flex align-center" tag="h1">
          {{
            !id
              ? $t("pages.admin-integrations-github-new.title")
              : $t("pages.admin-integrations-github-new.title")
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
    </v-card>
  </v-container>
</template>

<script lang="ts">
import { defineComponent, computed, inject, ref } from "vue";
import { useI18n } from "vue-i18n";
import { VTextField } from "vuetify/components/VTextField";
import { VSwitch } from "vuetify/components/VSwitch";
import { VPasswordField } from "@/components/fields";
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
import type { GitLab } from "@/friday";

export default defineComponent({
  name: "AdminIntegrationsGitLabNew",
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
      type: Object as PropType<GitLab>,
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
          title: t("pages.admin-integrations-github.title"),
          to: { name: "admin-integrations-github" },
        },
        {
          title: t(`pages.admin-integrations-github-new.title`),
        },
      ],
    }));
    const modifyPayload = (payload: Record<string, unknown>) => {
      return {
        authenticity_token: formAuthenticityToken.value,
        github: {
          ...payload,
        },
      };
    };
    const onSuccess = (_status: number, payload: unknown) => {
      reloadRouteDataAction.call();
      reloadAppDataAction.call();
      if (!toast) {
        alert(t(`pages.admin-integrations-github-new.onSave.success`));
        return;
      } else {
        if (
          "object" === typeof payload &&
          null !== payload &&
          "id" in payload &&
          payload.id !== id.value
        ) {
          router.push({
            name: "admin-integrations-github-id",
            params: {
              id: (payload.id as number).toString(),
            },
          });
        }
        toast.fire({
          title: t(`pages.admin-integrations-github-new.onSave.success`),
          icon: "success",
        });
        return;
      }
    };
    const onError = useOnError("pages.admin-integrations-github-new");
    const renderedForm = ref<FridayFormComponent | null>(null);
    const currentFieldValues = ref<Record<string, unknown>>({});
    const formStructure = computed<FridayFormStructure>(() => [
      [
        {
          cols: 12,
          md: 4,
          fieldComponent: VTextField,
          formKey: "name",
          valueKey: "name",
          label: t(`pages.admin-integrations-github-new.content.fields.name`),
          bindings: {
            label: t(`pages.admin-integrations-github-new.content.fields.name`),
          },
          validator: getFormFieldValidator(
            t,
            Joi.string().required().max(255),
            t(`pages.admin-integrations-github-new.content.fields.name`),
          ),
        },
      ],
      [
        {
          cols: 12,
          md: 4,
          fieldComponent: VPasswordField,
          formKey: "api_token",
          valueKey: "api_token",
          label: t(
            `pages.admin-integrations-github-new.content.fields.api_token`,
          ),
          bindings: {
            label: t(
              `pages.admin-integrations-github-new.content.fields.api_token`,
            ),
          },
          validator: getFormFieldValidator(
            t,
            Joi.string()
              .required()
              .regex(/^ghp_.+/) // Ensure the string starts with 'ghp_'
              .messages({
                "string.pattern.base":
                  'The token must be a valid access token starting with "ghp_".',
              }),
            t(`pages.admin-integrations-github-new.content.fields.api_token`),
          ),
        },
      ],
      [
        {
          cols: 12,
          md: 4,
          fieldComponent: VSwitch,
          formKey: "active",
          valueKey: "active",
          label: t(`pages.admin-integrations-github-new.content.fields.active`),
          bindings: {
            label: t(
              `pages.admin-integrations-github-new.content.fields.active`,
            ),
          },
        },
      ],
    ]);
    const formValues = computed<Record<string, unknown>>(() =>
      cloneObject(model.value as any as Record<string, unknown>),
    );
    const fridayFormBindings = computed(() => ({
      action: `/admin/integrations/github${id.value ? `/${id.value}` : ""}`,
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
      //           "view_issues",
      //         ),
      //         readonly: !(values.permissions as string[]).includes(
      //           "view_issues",
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
    return {
      breadcrumbsBindings,
      fridayFormBindings,
      accentColor,
      onSuccess,
      onError,
      currentFieldValues,
      renderedForm,
    };
  },
});
</script>

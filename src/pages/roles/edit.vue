<template>
  <v-container fluid>
    <v-card min-height="100" color="surface">
      <v-toolbar color="transparent" density="compact">
        <v-toolbar-title class="font-weight-bold d-flex align-center" tag="h1">
          {{
            !id ? $t("pages.roles-new.title") : $t("pages.roles-id-edit.title")
          }}
        </v-toolbar-title>
      </v-toolbar>
      <v-divider />
      <v-breadcrumbs v-bind="breadcrumbsBindings" />
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
import { defineComponent, computed, inject, ref } from "vue";
import { useI18n } from "vue-i18n";
import { VTextField } from "vuetify/components/VTextField";
import { VAutocomplete } from "vuetify/components/VAutocomplete";
import { VSwitch } from "vuetify/components/VSwitch";
import {
  VPermissionsObjectField,
  VPermissionsGroupedField,
  VPermissionsObjectGroupedField,
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
import type { FridayFormStructure } from "@/components/forms";
import type {
  ToastService,
  LocalStorageService,
  ApiService,
} from "@jakguru/vueprint";
import type { Role, RoleValuesProp } from "@/friday";

export default defineComponent({
  name: "RoleEdit",
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
      type: Object as PropType<Role>,
      required: true,
    },
    values: {
      type: Object as PropType<RoleValuesProp>,
      required: true,
    },
    anonymous: {
      type: Boolean,
      default: false,
    },
    builtin: {
      type: Boolean,
      default: false,
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
    const values = computed(() => props.values);
    const groups = computed(() => values.value.groups);
    const issueVisibilities = computed(() => values.value.issueVisibilities);
    const permissions = computed(() => values.value.permissions);
    const roles = computed(() => values.value.roles);
    const timeEntryVisibilities = computed(
      () => values.value.timeEntryVisibilities,
    );
    const trackers = computed(() => values.value.trackers);
    const userVisibilities = computed(() => values.value.userVisibilities);
    const activities = computed(() => values.value.activities);
    const { t } = useI18n({ useScope: "global" });
    const i18nPrefix = computed(() =>
      id.value ? "pages.roles-id-edit" : "pages.roles-new",
    );
    const breadcrumbsBindings = computed(() => ({
      items: [
        { title: t("pages.admin.title"), to: { name: "admin" } },
        {
          title: t("pages.roles.title"),
          to: { name: "roles" },
        },
        {
          title: t(`${i18nPrefix.value}.title`),
        },
      ],
    }));
    const modifyPayload = (payload: Record<string, unknown>) => {
      return {
        authenticity_token: formAuthenticityToken.value,
        role: {
          ...payload,
        },
      };
    };
    const onSuccess = (_status: number, payload: unknown) => {
      reloadRouteDataAction.call();
      reloadAppDataAction.call();
      if (!toast) {
        alert(t(`${i18nPrefix.value}.onSave.success`));
        return;
      } else {
        if (
          "object" === typeof payload &&
          null !== payload &&
          "id" in payload &&
          payload.id !== id.value
        ) {
          router.push({
            name: "roles-id-edit",
            params: {
              id: (payload.id as number).toString(),
            },
          });
        }
        toast.fire({
          title: t(`${i18nPrefix.value}.onSave.success`),
          icon: "success",
        });
        return;
      }
    };
    const onError = useOnError(i18nPrefix.value);
    const currentFieldValues = ref<Record<string, unknown>>({});
    const formStructure = computed<FridayFormStructure>(() => {
      return [
        [
          {
            cols: 12,
            fieldComponent: VTextField,
            formKey: "name",
            valueKey: "name",
            label: t(`${i18nPrefix.value}.content.fields.name`),
            bindings: {
              label: t(`${i18nPrefix.value}.content.fields.name`),
            },
            validator: getFormFieldValidator(
              t,
              Joi.string().required().max(255),
              t(`${i18nPrefix.value}.content.fields.name`),
            ),
          },
        ],
        [
          {
            cols: 12,
            sm: 6,
            fieldComponent: VAutocomplete,
            formKey: "default_time_entry_activity_id",
            valueKey: "default_time_entry_activity_id",
            label: t(
              `${i18nPrefix.value}.content.fields.default_time_entry_activity_id`,
            ),
            bindings: {
              label: t(
                `${i18nPrefix.value}.content.fields.default_time_entry_activity_id`,
              ),
              items: activities.value,
              itemTitle: "label",
            },
          },
          {
            cols: 12,
            sm: 6,
            fieldComponent: VSwitch,
            formKey: "assignable",
            valueKey: "assignable",
            label: t(`${i18nPrefix.value}.content.fields.assignable`),
            bindings: {
              label: t(`${i18nPrefix.value}.content.fields.assignable`),
            },
          },
        ],
        [
          {
            cols: 12,
            md: 4,
            fieldComponent: VAutocomplete,
            formKey: "issues_visibility",
            valueKey: "issues_visibility",
            label: t(`${i18nPrefix.value}.content.fields.issues_visibility`),
            bindings: {
              label: t(`${i18nPrefix.value}.content.fields.issues_visibility`),
              items: issueVisibilities.value,
              itemTitle: "label",
            },
          },
          {
            cols: 12,
            md: 4,
            fieldComponent: VAutocomplete,
            formKey: "time_entries_visibility",
            valueKey: "time_entries_visibility",
            label: t(
              `${i18nPrefix.value}.content.fields.time_entries_visibility`,
            ),
            bindings: {
              label: t(
                `${i18nPrefix.value}.content.fields.time_entries_visibility`,
              ),
              items: timeEntryVisibilities.value,
              itemTitle: "label",
            },
          },
          {
            cols: 12,
            md: 4,
            fieldComponent: VAutocomplete,
            formKey: "users_visibility",
            valueKey: "users_visibility",
            label: t(`${i18nPrefix.value}.content.fields.users_visibility`),
            bindings: {
              label: t(`${i18nPrefix.value}.content.fields.users_visibility`),
              items: userVisibilities.value,
              itemTitle: "label",
            },
          },
        ],
        [
          {
            cols: 12,
            sm: 3,
            fieldComponent: VSwitch,
            formKey: "all_roles_managed",
            valueKey: "all_roles_managed",
            label: t(`${i18nPrefix.value}.content.fields.all_roles_managed`),
            bindings: {
              label: t(`${i18nPrefix.value}.content.fields.all_roles_managed`),
            },
          },
          {
            cols: 12,
            md: 9,
            fieldComponent: VAutocomplete,
            formKey: "managed_role_ids",
            valueKey: "managed_role_ids",
            label: t(`${i18nPrefix.value}.content.fields.managed_role_ids`),
            bindings: {
              label: t(`${i18nPrefix.value}.content.fields.managed_role_ids`),
              items: roles.value,
              multiple: true,
              itemTitle: "label",
              chips: true,
              closableChips: true,
            },
          },
        ],
        [
          {
            cols: 12,
            fieldComponent: VPermissionsGroupedField,
            formKey: "permissions",
            valueKey: "permissions",
            label: t(`${i18nPrefix.value}.content.fields.permissions`),
            bindings: {
              label: t(`${i18nPrefix.value}.content.fields.permissions`),
              permissions: permissions.value,
              groups: groups.value,
            },
          },
        ],
        [
          {
            cols: 12,
            fieldComponent: VPermissionsObjectField,
            formKey: "permissions_all_trackers",
            valueKey: "permissions_all_trackers",
            label: t(
              `${i18nPrefix.value}.content.fields.permissions_all_trackers`,
            ),
            bindings: {
              label: t(
                `${i18nPrefix.value}.content.fields.permissions_all_trackers`,
              ),
              permissions: permissions.value,
            },
          },
        ],
        [
          {
            cols: 12,
            fieldComponent: VPermissionsObjectGroupedField,
            formKey: "permissions_tracker_ids",
            valueKey: "permissions_tracker_ids",
            label: t(
              `${i18nPrefix.value}.content.fields.permissions_tracker_ids`,
            ),
            bindings: {
              label: t(
                `${i18nPrefix.value}.content.fields.permissions_tracker_ids`,
              ),
              permissions: permissions.value,
              trackers: trackers.value,
            },
          },
        ],
      ];
    });
    const formValues = computed<Record<string, unknown>>(() =>
      cloneObject(model.value as any as Record<string, unknown>),
    );
    const fridayFormBindings = computed(() => ({
      action: `/roles${id.value ? `/${id.value}` : ""}`,
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
          case "managed_role_ids":
            if (values.all_roles_managed === true) {
              return { disabled: true, readonly: true };
            }
            break;
          case "permissions_all_trackers":
          case "permissions_tracker_ids":
            return {
              model: values,
              disabled: !(values.permissions as string[]).includes(
                "view_issues",
              ),
              readonly: !(values.permissions as string[]).includes(
                "view_issues",
              ),
            };
          case "permissions":
            return {
              model: values,
            };
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
      breadcrumbsBindings,
      fridayFormBindings,
      accentColor,
      onSuccess,
      onError,
      currentFieldValues,
    };
  },
});
</script>

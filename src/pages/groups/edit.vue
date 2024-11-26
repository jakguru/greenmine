<template>
  <v-container fluid>
    <v-card min-height="100" color="surface">
      <v-toolbar color="transparent" density="compact">
        <v-toolbar-title class="font-weight-bold d-flex align-center" tag="h1">
          {{
            !id
              ? $t("pages.groups-new.title")
              : $t("pages.groups-id-edit.title")
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
  VBase64EncodedImageField,
  VProjectMembershipField,
} from "@/components/fields";
import { useRoute, useRouter } from "vue-router";
import {
  useSystemAccentColor,
  useReloadRouteData,
  useReloadAppData,
  cloneObject,
  checkObjectEquality,
} from "@/utils/app";
import { Joi, getFormFieldValidator, FridayForm } from "@/components/forms";

import type { PropType } from "vue";
import type { FridayFormStructure } from "@/components/forms";
import type {
  SwalService,
  ToastService,
  LocalStorageService,
  ApiService,
} from "@jakguru/vueprint";
import type { Group, GroupValuesProp } from "@/friday";

export default defineComponent({
  name: "GroupEdit",
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
      type: Object as PropType<Group>,
      required: true,
    },
    values: {
      type: Object as PropType<GroupValuesProp>,
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
    const swal = inject<SwalService>("swal");
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
    const roles = computed(() => values.value.roles);
    const projects = computed(() => values.value.projects);
    const users = computed(() => values.value.users);
    const { t } = useI18n({ useScope: "global" });
    const i18nPrefix = computed(() =>
      id.value ? "pages.groups-id-edit" : "pages.groups-new",
    );
    const breadcrumbsBindings = computed(() => ({
      items: [
        { title: t("pages.admin.title"), to: { name: "admin" } },
        {
          title: t("pages.groups.title"),
          to: { name: "groups" },
        },
        {
          title: t(`${i18nPrefix.value}.title`),
        },
      ],
    }));
    const modifyPayload = (payload: Record<string, unknown>) => {
      return {
        authenticity_token: formAuthenticityToken.value,
        group: {
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
            name: "groups-id-edit",
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
    const onError = (_status: number, payload: unknown) => {
      if (payload instanceof Error) {
        console.error(payload);
      }
      if (!swal) {
        alert(t(`${i18nPrefix.value}.onSave.error`));
        return;
      } else {
        swal.fire({
          title: t(`${i18nPrefix.value}.onSave.error`),
          icon: "error",
        });
        return;
      }
    };
    const currentFieldValues = ref<Record<string, unknown>>({});
    const formStructure = computed<FridayFormStructure>(() => {
      return [
        [
          {
            cols: 12,
            md: 9,
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
          {
            cols: 12,
            sm: 3,
            fieldComponent: VSwitch,
            formKey: "twofa_required",
            valueKey: "twofa_required",
            label: t(`${i18nPrefix.value}.content.fields.twofa_required`),
            bindings: {
              label: t(`${i18nPrefix.value}.content.fields.twofa_required`),
            },
          },
        ],
        [
          {
            cols: 12,
            fieldComponent: VBase64EncodedImageField,
            formKey: "avatar",
            valueKey: "avatar",
            label: t(`${i18nPrefix.value}.content.fields.avatar`),
            bindings: {
              label: t(`${i18nPrefix.value}.content.fields.avatar`),
              height: 200,
              clearable: true,
            },
          },
        ],
        [
          {
            cols: 12,
            fieldComponent: VAutocomplete,
            formKey: "users",
            valueKey: "users",
            label: t(`${i18nPrefix.value}.content.fields.users`),
            bindings: {
              label: t(`${i18nPrefix.value}.content.fields.users`),
              items: users.value,
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
            fieldComponent: VProjectMembershipField,
            formKey: "memberships",
            valueKey: "memberships",
            label: t(`${i18nPrefix.value}.content.fields.memberships`),
            bindings: {
              label: t(`${i18nPrefix.value}.content.fields.memberships`),
              roles: roles.value,
              projects: projects.value,
            },
          },
        ],
      ];
    });
    const formValues = computed<Record<string, unknown>>(() =>
      cloneObject(model.value as any as Record<string, unknown>),
    );
    const fridayFormBindings = computed(() => ({
      action: `/groups${id.value ? `/${id.value}` : ""}`,
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
      //       if (values.all_groups_managed === true) {
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
    };
  },
});
</script>

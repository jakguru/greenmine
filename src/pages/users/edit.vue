<template>
  <v-container fluid>
    <v-card min-height="100" color="surface">
      <v-toolbar color="transparent" density="compact">
        <v-toolbar-title class="font-weight-bold d-flex align-center" tag="h1">
          {{
            !id ? $t("pages.users-new.title") : $t("pages.users-id-edit.title")
          }}
        </v-toolbar-title>
      </v-toolbar>
      <v-divider />
      <v-breadcrumbs v-bind="breadcrumbsBindings" />
      <v-divider />
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
    </v-card>
  </v-container>
</template>

<script lang="ts">
import { defineComponent, computed, inject, ref, h } from "vue";
import { useI18n } from "vue-i18n";
import { VTextField } from "vuetify/components/VTextField";
import { VAutocomplete } from "vuetify/components/VAutocomplete";
import { VSwitch } from "vuetify/components/VSwitch";
import { VBtn } from "vuetify/components/VBtn";
import {
  VPasswordField,
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
import * as genPass from "generate-password-browser";

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
} from "@jakguru/vueprint";
import type { User, UserValuesProp } from "@/friday";

export default defineComponent({
  name: "UserEdit",
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
      type: Object as PropType<User>,
      required: true,
    },
    values: {
      type: Object as PropType<UserValuesProp>,
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
    const commmentsSortingOptions = computed(
      () => values.value.commmentsSortingOptions,
    );
    const defaultIssueQueryOptions = computed(
      () => values.value.defaultIssueQueryOptions,
    );
    const defaultProjectQueryOptions = computed(
      () => values.value.defaultProjectQueryOptions,
    );
    const groups = computed(() => values.value.groups);
    const historyDefaultTabOptions = computed(
      () => values.value.historyDefaultTabOptions,
    );
    const languages = computed(() => values.value.languages);
    const mailNotificationOptions = computed(
      () => values.value.mailNotificationOptions,
    );
    const passwordMinLength = computed(() => values.value.passwordMinLength);
    const passwordRequiredCharClasses = computed(
      () => values.value.passwordRequiredCharClasses,
    );
    const projects = computed(() => values.value.projects);
    const roles = computed(() => values.value.roles);
    const timezones = computed(() => values.value.timezones);
    const userStatusOptions = computed(() => values.value.userStatusOptions);
    const autoWatchOnOptions = computed(() => [
      { value: "issue_created", label: t("labels.autoWatchOn.issue_created") },
      {
        value: "issue_contributed_to",
        label: t("labels.autoWatchOn.issue_contributed_to"),
      },
    ]);
    const { t } = useI18n({ useScope: "global" });
    const i18nPrefix = computed(() =>
      id.value ? "pages.users-id-edit" : "pages.users-new",
    );
    const breadcrumbsBindings = computed(() => ({
      items: [
        { title: t("pages.admin.title"), to: { name: "admin" } },
        {
          title: t("pages.users.title"),
          to: { name: "users" },
        },
        {
          title: t(`${i18nPrefix.value}.title`),
        },
      ],
    }));
    const tabs = computed(() => [
      {
        text: t(`${i18nPrefix.value}.content.tabs.information`),
        value: "information",
      },
      {
        text: t(`${i18nPrefix.value}.content.tabs.authentication`),
        value: "authentication",
      },
      {
        text: t(`${i18nPrefix.value}.content.tabs.password`),
        value: "password",
      },
      {
        text: t(`${i18nPrefix.value}.content.tabs.notifications`),
        value: "notifications",
      },
      {
        text: t(`${i18nPrefix.value}.content.tabs.preferences`),
        value: "preferences",
      },
      {
        text: t(`${i18nPrefix.value}.content.tabs.memberships`),
        value: "memberships",
      },
    ]);
    const tab = computed({
      get: () => (route.query.tab as string | undefined) ?? "information",
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
            name: "users-id-edit",
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
    const passwordFieldValidator = computed(() => {
      let schema = Joi.string().required().min(Number(passwordMinLength.value));
      if (passwordRequiredCharClasses.value.includes("uppercase")) {
        schema = schema.concat(
          Joi.string().pattern(
            new RegExp("(?=.*[A-Z])"),
            t("labels.charclasses.uppercase"),
          ),
        );
      }
      if (passwordRequiredCharClasses.value.includes("lowercase")) {
        schema = schema.concat(
          Joi.string().pattern(
            new RegExp("(?=.*[a-z])"),
            t("labels.charclasses.lowercase"),
          ),
        );
      }
      if (passwordRequiredCharClasses.value.includes("digits")) {
        schema = schema.concat(
          Joi.string().pattern(
            new RegExp("(?=.*[0-9])"),
            t("labels.charclasses.digits"),
          ),
        );
      }
      if (passwordRequiredCharClasses.value.includes("special_chars")) {
        schema = schema.concat(
          Joi.string().pattern(
            new RegExp("(?=.*[\x21-\x2F\x3A-\x40\x5B-\x60\x7B-\x7E])"),
            t("labels.charclasses.specialChars"),
          ),
        );
      }
      return getFormFieldValidator(
        t,
        schema,
        t(`${i18nPrefix.value}.content.fields.password`),
      );
    });
    const renderedForm = ref<FridayFormComponent | null>(null);
    const doGeneratePassword = () => {
      if (!renderedForm.value) {
        if (toast) {
          toast.fire({
            title: t(`${i18nPrefix.value}.onGeneratePassword.error`),
            icon: "error",
          });
        } else {
          alert(t(`${i18nPrefix.value}.onGeneratePassword.error`));
        }
        return;
      }
      const generated = genPass.generate({
        length: Number(passwordMinLength.value),
        numbers: passwordRequiredCharClasses.value.includes("digits"),
        symbols: passwordRequiredCharClasses.value.includes("special_chars"),
        uppercase: passwordRequiredCharClasses.value.includes("uppercase"),
        excludeSimilarCharacters: true,
        strict: true,
      });
      renderedForm.value.setValue("password", generated);
      renderedForm.value.setValue("must_change_passwd", true);
    };
    const currentFieldValues = ref<Record<string, unknown>>({});
    const formStructure = computed<FridayFormStructure>(() => {
      switch (tab.value) {
        case "information":
          return [
            [
              {
                cols: 12,
                md: 6,
                fieldComponent: VTextField,
                formKey: "firstname",
                valueKey: "firstname",
                label: t(`${i18nPrefix.value}.content.fields.firstname`),
                bindings: {
                  label: t(`${i18nPrefix.value}.content.fields.firstname`),
                },
                validator: getFormFieldValidator(
                  t,
                  Joi.string().required().max(255),
                  t(`${i18nPrefix.value}.content.fields.firstname`),
                ),
              },
              {
                cols: 12,
                md: 6,
                fieldComponent: VTextField,
                formKey: "lastname",
                valueKey: "lastname",
                label: t(`${i18nPrefix.value}.content.fields.lastname`),
                bindings: {
                  label: t(`${i18nPrefix.value}.content.fields.lastname`),
                },
                validator: getFormFieldValidator(
                  t,
                  Joi.string().required().max(255),
                  t(`${i18nPrefix.value}.content.fields.lastname`),
                ),
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
          ];
        case "authentication":
          return [
            [
              {
                cols: 12,
                md: 4,
                fieldComponent: VTextField,
                formKey: "login",
                valueKey: "login",
                label: t(`${i18nPrefix.value}.content.fields.login`),
                bindings: {
                  label: t(`${i18nPrefix.value}.content.fields.login`),
                },
                validator: getFormFieldValidator(
                  t,
                  Joi.string().required().max(255),
                  t(`${i18nPrefix.value}.content.fields.login`),
                ),
              },
            ],
            [
              {
                cols: 12,
                md: 4,
                fieldComponent: VAutocomplete,
                formKey: "status",
                valueKey: "status",
                label: t(`${i18nPrefix.value}.content.fields.status`),
                bindings: {
                  label: t(`${i18nPrefix.value}.content.fields.status`),
                  items: userStatusOptions.value,
                  itemTitle: "label",
                },
                validator: getFormFieldValidator(
                  t,
                  Joi.string().required().max(255),
                  t(`${i18nPrefix.value}.content.fields.status`),
                ),
              },
            ],
            [
              {
                cols: 12,
                md: 4,
                fieldComponent: VSwitch,
                formKey: "admin",
                valueKey: "admin",
                label: t(`${i18nPrefix.value}.content.fields.admin`),
                bindings: {
                  label: t(`${i18nPrefix.value}.content.fields.admin`),
                },
              },
            ],
          ];
        case "password":
          return [
            [
              {
                cols: 12,
                md: 4,
                fieldComponent: VPasswordField,
                formKey: "password",
                valueKey: "password",
                label: t(`${i18nPrefix.value}.content.fields.password`),
                bindings: {
                  label: t(`${i18nPrefix.value}.content.fields.password`),
                },
                validator: passwordFieldValidator.value,
              },
              {
                cols: 12,
                md: 2,
                fieldComponent: h(
                  VBtn,
                  {
                    color: accentColor.value,
                    height: "56px",
                    onClick: doGeneratePassword,
                  },
                  `labels.generate`,
                ),
                formKey: "password_generator",
                valueKey: "password_generator",
                label: t(
                  `${i18nPrefix.value}.content.fields.password_generator`,
                ),
              },
            ],
            [
              {
                cols: 12,
                md: 4,
                fieldComponent: VSwitch,
                formKey: "must_change_passwd",
                valueKey: "must_change_passwd",
                label: t(
                  `${i18nPrefix.value}.content.fields.must_change_passwd`,
                ),
                bindings: {
                  label: t(
                    `${i18nPrefix.value}.content.fields.must_change_passwd`,
                  ),
                },
              },
            ],
          ];
        case "notifications":
          return [
            [
              {
                cols: 12,
                md: 4,
                fieldComponent: VAutocomplete,
                formKey: "mail_notification",
                valueKey: "mail_notification",
                label: t(
                  `${i18nPrefix.value}.content.fields.mail_notification`,
                ),
                bindings: {
                  label: t(
                    `${i18nPrefix.value}.content.fields.mail_notification`,
                  ),
                  items: mailNotificationOptions.value,
                  itemTitle: "label",
                },
                validator: getFormFieldValidator(
                  t,
                  Joi.string().required().max(255),
                  t(`${i18nPrefix.value}.content.fields.mail_notification`),
                ),
              },
            ],
            [
              {
                cols: 12,
                md: 4,
                fieldComponent: VAutocomplete,
                formKey: "auto_watch_on",
                valueKey: "auto_watch_on",
                label: t(`${i18nPrefix.value}.content.fields.auto_watch_on`),
                bindings: {
                  label: t(`${i18nPrefix.value}.content.fields.auto_watch_on`),
                  items: autoWatchOnOptions.value,
                  itemTitle: "label",
                  multiple: true,
                  chips: true,
                  closableChips: true,
                },
                validator: getFormFieldValidator(
                  t,
                  Joi.string().required().max(255),
                  t(`${i18nPrefix.value}.content.fields.auto_watch_on`),
                ),
              },
            ],
            [
              {
                cols: 12,
                md: 4,
                fieldComponent: VSwitch,
                formKey: "no_self_notified",
                valueKey: "no_self_notified",
                label: t(`${i18nPrefix.value}.content.fields.no_self_notified`),
                bindings: {
                  label: t(
                    `${i18nPrefix.value}.content.fields.no_self_notified`,
                  ),
                  trueValue: "1",
                  falseValue: "0",
                },
              },
            ],
          ];
        case "preferences":
          return [
            [
              {
                cols: 12,
                md: 4,
                fieldComponent: VAutocomplete,
                formKey: "language",
                valueKey: "language",
                label: t(`${i18nPrefix.value}.content.fields.language`),
                bindings: {
                  label: t(`${i18nPrefix.value}.content.fields.language`),
                  items: languages.value,
                  itemTitle: "label",
                },
                validator: getFormFieldValidator(
                  t,
                  Joi.string().required().max(255),
                  t(`${i18nPrefix.value}.content.fields.language`),
                ),
              },
            ],
            [
              {
                cols: 12,
                md: 4,
                fieldComponent: VAutocomplete,
                formKey: "timezone",
                valueKey: "timezone",
                label: t(`${i18nPrefix.value}.content.fields.timezone`),
                bindings: {
                  label: t(`${i18nPrefix.value}.content.fields.timezone`),
                  items: timezones.value,
                  itemTitle: "label",
                },
                validator: getFormFieldValidator(
                  t,
                  Joi.string().required().max(255),
                  t(`${i18nPrefix.value}.content.fields.timezone`),
                ),
              },
            ],
          ];
        case "memberships":
          return [
            [
              {
                cols: 12,
                fieldComponent: VAutocomplete,
                formKey: "groups",
                valueKey: "groups",
                label: t(`${i18nPrefix.value}.content.fields.groups`),
                bindings: {
                  label: t(`${i18nPrefix.value}.content.fields.groups`),
                  items: groups.value,
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
        default:
          return [];
      }
    });
    const formValues = computed<Record<string, unknown>>(() =>
      cloneObject(model.value as any as Record<string, unknown>),
    );
    const fridayFormBindings = computed(() => ({
      action: `/users${id.value ? `/${id.value}` : ""}`,
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
      vTabBindings,
      renderedForm,
    };
  },
});
</script>

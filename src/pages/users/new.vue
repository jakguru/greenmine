<template>
  <v-container fluid>
    <v-card min-height="100" color="surface">
      <v-toolbar color="transparent" density="compact">
        <v-toolbar-title class="font-weight-bold d-flex align-center" tag="h1">
          {{ !id ? $t("pages.users-new.title") : $t("pages.users-new.title") }}
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
import { defineComponent, computed, inject, ref, h } from "vue";
import { useI18n } from "vue-i18n";
import { VTextField } from "vuetify/components/VTextField";
import { VAutocomplete } from "vuetify/components/VAutocomplete";
import { VSwitch } from "vuetify/components/VSwitch";
import { VBtn } from "vuetify/components/VBtn";
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
import {
  Joi,
  tlds,
  getFormFieldValidator,
  FridayForm,
  FridayFormStructureField,
} from "@/components/forms";
import * as genPass from "generate-password-browser";

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
import type { User, UserValuesProp } from "@/friday";

export default defineComponent({
  name: "UserNew",
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
    const passwordMinLength = computed(() => values.value.passwordMinLength);
    const passwordRequiredCharClasses = computed(
      () => values.value.passwordRequiredCharClasses,
    );
    const userStatusOptions = computed(() => values.value.userStatusOptions);
    const emailDomainsAllowed = computed(
      () => values.value.emailDomainsAllowed,
    );
    const emailDomainsDenied = computed(() => values.value.emailDomainsDenied);
    const emailDomainsAllowedArray = computed(() =>
      "string" === typeof emailDomainsAllowed.value
        ? emailDomainsAllowed.value
            .trim()
            .split(",")
            .map((v: string) => v.trim())
            .filter((v: string) => v.length > 0)
        : [],
    );
    const emailDomainsDeniedArray = computed(() =>
      "string" === typeof emailDomainsDenied.value
        ? emailDomainsDenied.value
            .trim()
            .split(",")
            .map((v: string) => v.trim())
            .filter((v: string) => v.length > 0)
        : [],
    );
    const { t } = useI18n({ useScope: "global" });
    const breadcrumbsBindings = computed(() => ({
      items: [
        { title: t("pages.admin.title"), to: { name: "admin" } },
        {
          title: t("pages.users.title"),
          to: { name: "users" },
        },
        {
          title: t(`pages.users-new.title`),
        },
      ],
    }));
    const modifyPayload = (payload: Record<string, unknown>) => {
      return {
        authenticity_token: formAuthenticityToken.value,
        send_information: payload.send_information,
        user: {
          ...payload,
          send_information: undefined,
        },
      };
    };
    const onSuccess = (_status: number, payload: unknown) => {
      reloadRouteDataAction.call();
      reloadAppDataAction.call();
      if (!toast) {
        alert(t(`pages.users-new.onSave.success`));
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
          title: t(`pages.users-new.onSave.success`),
          icon: "success",
        });
        return;
      }
    };
    const onError = useOnError("pages.users-new");
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
        t(`pages.users-new.content.fields.password`),
      );
    });
    const emailAddressSchema = computed(() => {
      let schema = Joi.string().required();
      if (
        emailDomainsAllowedArray.value.length > 0 ||
        emailDomainsDeniedArray.value.length > 0
      ) {
        if (emailDomainsAllowedArray.value.length > 0) {
          schema = schema.concat(
            Joi.string().email({
              tlds: { allow: emailDomainsAllowedArray.value },
            }),
          );
        } else {
          schema = schema.concat(
            Joi.string().email({
              tlds: { deny: emailDomainsDeniedArray.value },
            }),
          );
        }
      } else {
        schema = schema.concat(Joi.string().email({ tlds: { allow: tlds } }));
      }
      return schema;
    });
    const mailFieldValidator = computed(() =>
      getFormFieldValidator(
        t,
        emailAddressSchema.value,
        t(`pages.users-id-edit.content.fields.mail`),
      ),
    );
    const renderedForm = ref<FridayFormComponent | null>(null);
    const doGeneratePassword = () => {
      if (!renderedForm.value) {
        if (toast) {
          toast.fire({
            title: t(`pages.users-new.onGeneratePassword.error`),
            icon: "error",
          });
        } else {
          alert(t(`pages.users-new.onGeneratePassword.error`));
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
    const formStructure = computed<FridayFormStructure>(() => [
      [
        {
          cols: 12,
          md: 4,
          fieldComponent: VTextField,
          formKey: "firstname",
          valueKey: "firstname",
          label: t(`pages.users-id-edit.content.fields.firstname`),
          bindings: {
            label: t(`pages.users-id-edit.content.fields.firstname`),
          },
          validator: getFormFieldValidator(
            t,
            Joi.string().required().max(255),
            t(`pages.users-id-edit.content.fields.firstname`),
          ),
        },
      ],
      [
        {
          cols: 12,
          md: 4,
          fieldComponent: VTextField,
          formKey: "lastname",
          valueKey: "lastname",
          label: t(`pages.users-id-edit.content.fields.lastname`),
          bindings: {
            label: t(`pages.users-id-edit.content.fields.lastname`),
          },
          validator: getFormFieldValidator(
            t,
            Joi.string().required().max(255),
            t(`pages.users-id-edit.content.fields.lastname`),
          ),
        },
      ],
      [
        {
          cols: 12,
          md: 4,
          fieldComponent: VTextField,
          formKey: "mail",
          valueKey: "mail",
          label: t(`pages.users-id-edit.content.fields.mail`),
          bindings: {
            label: t(`pages.users-id-edit.content.fields.mail`),
          },
          validator: mailFieldValidator.value,
        },
      ],
      [
        {
          cols: 12,
          md: 4,
          fieldComponent: VTextField,
          formKey: "login",
          valueKey: "login",
          label: t(`pages.users-id-edit.content.fields.login`),
          bindings: {
            label: t(`pages.users-id-edit.content.fields.login`),
          },
          validator: getFormFieldValidator(
            t,
            Joi.string().required().max(255),
            t(`pages.users-id-edit.content.fields.login`),
          ),
        },
      ],
      [
        {
          cols: 12,
          md: 4,
          fieldComponent: VPasswordField,
          formKey: "password",
          valueKey: "password",
          label: t(`pages.users-id-edit.content.fields.password`),
          bindings: {
            label: t(`pages.users-id-edit.content.fields.password`),
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
            t(`labels.generate`),
          ),
          formKey: "password_generator",
          valueKey: "password_generator",
          label: t(`pages.users-id-edit.content.fields.password_generator`),
        } as FridayFormStructureField,
      ],
      [
        {
          cols: 12,
          md: 4,
          fieldComponent: VAutocomplete,
          formKey: "status",
          valueKey: "status",
          label: t(`pages.users-id-edit.content.fields.status`),
          bindings: {
            label: t(`pages.users-id-edit.content.fields.status`),
            items: userStatusOptions.value,
            itemTitle: "label",
          },
        },
      ],
      [
        {
          cols: 12,
          md: 4,
          fieldComponent: VSwitch,
          formKey: "admin",
          valueKey: "admin",
          label: t(`pages.users-id-edit.content.fields.admin`),
          bindings: {
            label: t(`pages.users-id-edit.content.fields.admin`),
          },
        },
      ],
      [
        {
          cols: 12,
          md: 4,
          fieldComponent: VSwitch,
          formKey: "must_change_passwd",
          valueKey: "must_change_passwd",
          label: t(`pages.users-id-edit.content.fields.must_change_passwd`),
          bindings: {
            label: t(`pages.users-id-edit.content.fields.must_change_passwd`),
          },
        },
      ],
      [
        {
          cols: 12,
          md: 4,
          fieldComponent: VSwitch,
          formKey: "send_information",
          valueKey: "send_information",
          label: t(`pages.users-id-edit.content.fields.send_information`),
          bindings: {
            label: t(`pages.users-id-edit.content.fields.send_information`),
          },
        },
      ],
    ]);
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
      renderedForm,
    };
  },
});
</script>

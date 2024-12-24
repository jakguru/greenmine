<template>
  <v-container fluid>
    <v-card min-height="100" color="surface">
      <v-toolbar color="transparent" density="compact">
        <v-toolbar-title class="font-weight-bold d-flex align-center" tag="h1">
          {{ $t("pages.my-password.title") }}
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
import { VBtn } from "vuetify/components/VBtn";
import { VPasswordField } from "@/components/fields";
import {
  useRoute,
  // useRouter
} from "vue-router";
import {
  useSystemAccentColor,
  useReloadRouteData,
  useReloadAppData,
  checkObjectEquality,
  useOnError,
} from "@/utils/app";
import {
  Joi,
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
import type { UserValuesProp } from "@/friday";

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
    error: {
      type: String as PropType<string | null>,
      required: true,
    },
    passwordMinLength: {
      type: Number,
      required: true,
    },
    passwordRequiredCharClasses: {
      type: Array as PropType<UserValuesProp["passwordRequiredCharClasses"]>,
      required: true,
    },
  },
  setup(props) {
    const toast = inject<ToastService>("toast");
    const ls = inject<LocalStorageService>("ls");
    const api = inject<ApiService>("api");
    const route = useRoute();
    // const router = useRouter();
    const reloadRouteDataAction = useReloadRouteData(route, api, toast);
    const reloadAppDataAction = useReloadAppData(ls, api);
    const accentColor = useSystemAccentColor();
    const formAuthenticityToken = computed(() => props.formAuthenticityToken);
    const { t } = useI18n({ useScope: "global" });
    const breadcrumbsBindings = computed(() => ({
      items: [
        { title: t("pages.my-account.title"), to: { name: "my-account" } },
        {
          title: t(`pages.my-password.title`),
        },
      ],
    }));
    const modifyPayload = (payload: Record<string, unknown>) => {
      return {
        authenticity_token: formAuthenticityToken.value,
        ...payload,
      };
    };
    const onSuccess = (_status: number, _payload: unknown) => {
      reloadRouteDataAction.call();
      reloadAppDataAction.call();
      if (!toast) {
        alert(t(`pages.my-password.onSave.success`));
        return;
      } else {
        toast.fire({
          title: t(`pages.my-password.onSave.success`),
          icon: "success",
        });
        return;
      }
    };
    const onError = useOnError("pages.my-password");
    const renderedForm = ref<FridayFormComponent | null>(null);
    const currentFieldValues = ref<Record<string, unknown>>({});
    const passwordMinLength = computed(() => props.passwordMinLength);
    const passwordRequiredCharClasses = computed(
      () => props.passwordRequiredCharClasses,
    );
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
      renderedForm.value.setValue("new_password", generated);
      renderedForm.value.setValue("new_password_confirmation", generated);
    };
    const formStructure = computed<FridayFormStructure>(() => [
      [
        {
          cols: 12,
          md: 4,
          fieldComponent: VPasswordField,
          formKey: "password",
          valueKey: "password",
          label: t(`pages.my-password.content.fields.password`),
          bindings: {
            label: t(`pages.my-password.content.fields.password`),
          },
        },
      ],
      [
        {
          cols: 12,
          md: 4,
          fieldComponent: VPasswordField,
          formKey: "new_password",
          valueKey: "new_password",
          label: t(`pages.my-password.content.fields.new_password`),
          bindings: {
            label: t(`pages.my-password.content.fields.new_password`),
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
          fieldComponent: VPasswordField,
          formKey: "new_password_confirmation",
          valueKey: "new_password_confirmation",
          label: t(
            `pages.my-password.content.fields.new_password_confirmation`,
          ),
          bindings: {
            label: t(
              `pages.my-password.content.fields.new_password_confirmation`,
            ),
          },
          validator: passwordFieldValidator.value,
        },
      ],
    ]);
    const formValues = computed<Record<string, unknown>>(() => ({
      password: "",
      new_password: "",
      new_password_confirmation: "",
    }));
    const fridayFormBindings = computed(() => ({
      action: window.location.pathname,
      method: "post",
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

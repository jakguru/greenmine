<template>
  <v-container class="page-login fill-height" :fluid="true">
    <v-row justify="center">
      <v-col cols="12" sm="6" md="4" lg="3" xxl="2">
        <v-card
          ref="form"
          color="surface"
          tag="form"
          :action="formAction"
          method="post"
          accept-charset="UTF-8"
          @submit.stop="submit"
        >
          <v-toolbar :color="systemAppBarColor" density="compact">
            <v-toolbar-title>{{
              $t("pages.login.content.form.header", { name: appData.name })
            }}</v-toolbar-title>
          </v-toolbar>
          <v-divider />
          <v-container>
            <v-row>
              <v-col cols="12">
                <v-text-field v-bind="fields.username" />
              </v-col>
            </v-row>
            <v-row>
              <v-col cols="12">
                <VPasswordField v-bind="fields.password" />
              </v-col>
              <v-col
                v-if="lostPassword && lostPasswordPath"
                cols="12"
                class="d-flex justify-end"
              >
                <RouterLink :to="lostPasswordPath">{{
                  $t("labels.forgotPassword")
                }}</RouterLink>
              </v-col>
            </v-row>
            <v-row>
              <v-col cols="12" class="d-flex justify-end">
                <v-btn v-bind="submitBtnBindings">
                  {{ $t("actions.login") }}
                </v-btn>
              </v-col>
            </v-row>
          </v-container>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script lang="ts">
import { defineComponent, computed, ref, watch, inject } from "vue";
import {
  useSystemAppBarColor,
  useSystemSurfaceColor,
  loadAppData,
  useAppData,
} from "@/utils/app";
import { useForm } from "vee-validate";
import { useI18n } from "vue-i18n";
import { getFormFieldValidator, vuetifyConfig } from "@/utils/validation";
import { useDefaults } from "@/utils/vuetify";
import Joi from "joi";
import { VPasswordField } from "@/components/fields";
import { RouterLink, useRouter } from "vue-router";

import type { PropType } from "vue";
import type { VCard } from "vuetify/components";
import type { FieldValidationMetaInfo } from "@/types";
import type {
  ApiService,
  ToastService,
  SwalService,
  LocalStorageService,
} from "@jakguru/vueprint";
export default defineComponent({
  name: "LoginPage",
  components: {
    VPasswordField,
    RouterLink,
  },
  props: {
    homeUrl: {
      type: String as PropType<string | undefined>,
      default: undefined,
    },
    signinPath: {
      type: String as PropType<string | undefined>,
      default: undefined,
    },
    params: {
      type: Object as PropType<Record<string, string>>,
      default: () => ({}),
    },
    lostPassword: {
      type: Boolean as PropType<boolean>,
      default: false,
    },
    lostPasswordPath: {
      type: String as PropType<string | undefined>,
      default: undefined,
    },
    autologin: {
      type: Boolean as PropType<boolean>,
      default: false,
    },
    formAuthenticityToken: {
      type: String as PropType<string | undefined>,
      default: undefined,
    },
    backUrl: {
      type: [String, Boolean] as PropType<string | false | undefined>,
      default: false,
    },
  },
  setup(props) {
    const { t } = useI18n();
    const router = useRouter();
    const api = inject<ApiService>("api");
    const swal = inject<SwalService>("swal");
    const toast = inject<ToastService>("toast");
    const ls = inject<LocalStorageService>("ls");
    const systemAppBarColor = useSystemAppBarColor();
    const systemSurfaceColor = useSystemSurfaceColor();
    const appData = useAppData();
    const signinPath = computed(() => props.signinPath);
    const formAction = computed(() => signinPath.value || "#");
    const form = ref<VCard | null>(null);
    const backUrl = computed(() => props.backUrl);
    const homeUrl = computed(() => props.homeUrl);
    const backToUrl = computed(() => backUrl.value || homeUrl.value || "/");
    const usernameFieldValidator = computed(() =>
      getFormFieldValidator<string>(
        t,
        Joi.string().required(),
        t(`fields.username`),
      ),
    );
    const passwordFieldValidator = computed(() =>
      getFormFieldValidator<string>(
        t,
        Joi.string().required(),
        t(`fields.password`),
      ),
    );
    const formAuthenticityToken = computed(() => props.formAuthenticityToken);
    const {
      handleSubmit: handleFormSubmit,
      isSubmitting: formIsSubmitting,
      isValidating: formIsValidating,
      defineComponentBinds: defineFormComponentBinds,
      errors: formErrors,
      resetForm: resetFormFields,
      resetField: resetFormField,
      setFieldValue: setFormFieldValue,
      setFieldTouched: setFormFieldTouched,
      setTouched: setFormTouched,
      values: formValues,
    } = useForm({
      initialValues: {
        username: "",
        password: "",
        utf8: "✓",
        authenticity_token: formAuthenticityToken.value,
        back_url: backToUrl.value,
        login: "login",
      },
      validationSchema: {
        username: (val: string, ctx: FieldValidationMetaInfo) =>
          usernameFieldValidator.value(val, ctx),
        password: (val: string, ctx: FieldValidationMetaInfo) =>
          passwordFieldValidator.value(val, ctx),
      },
    });
    const fieldsAreDisabled = computed(
      () => formIsSubmitting.value || appData.value.identity.authenticated,
    );
    const fieldsAreaClearable = computed(() => !fieldsAreDisabled.value);
    const fieldCommon = computed(() => ({
      disabled: fieldsAreDisabled.value,
      clearable: fieldsAreaClearable.value,
      autocapitalize: "off",
      spellcheck: false,
    }));
    const textFieldDefaults = useDefaults({} as any, "VTextField");
    const usernameInFocus = ref(false);
    const passwordInFocus = ref(false);
    const usernameComponentBinds = defineFormComponentBinds(
      "username",
      (state: any) => vuetifyConfig(state, usernameInFocus.value),
    );
    const passwordComponentBinds = defineFormComponentBinds(
      "password",
      (state: any) => vuetifyConfig(state, passwordInFocus.value),
    );
    const fields = computed(() => ({
      username: {
        ...usernameComponentBinds.value,
        ...textFieldDefaults,
        ...fieldCommon.value,
        label: t(`fields.username`),
        onFocus: () => {
          usernameInFocus.value = true;
        },
        onBlur: () => {
          usernameInFocus.value = false;
          usernameComponentBinds.value.onBlur();
        },
        autocomplete: "username",
      },
      password: {
        ...textFieldDefaults,
        ...passwordComponentBinds.value,
        ...fieldCommon.value,
        label: t(`fields.password`),
        onFocus: () => {
          passwordInFocus.value = true;
        },
        onBlur: () => {
          passwordInFocus.value = false;
          passwordComponentBinds.value.onBlur();
        },
        autocomplete: "current-password",
      },
    }));
    const isSubmitting = ref(false);
    let submissionAbortController: AbortController = new AbortController();
    const submitForm = handleFormSubmit(
      async (values: {
        username: string;
        password: string;
        utf8: string;
        authenticity_token: string | undefined;
        back_url: string | false | undefined;
        login: string;
      }) => {
        if (isSubmitting.value || !values || !api || !signinPath.value) return;
        if (submissionAbortController) {
          submissionAbortController.abort();
        }
        const payload = { ...values };
        submissionAbortController = new AbortController();
        submissionAbortController.signal.addEventListener("abort", () => {
          isSubmitting.value = false;
        });
        isSubmitting.value = true;
        const { status, data, headers } = await api.post(
          formAction.value,
          payload,
          {
            signal: submissionAbortController.signal,
          },
        );
        console.log({ status, data, headers });
        if (status >= 200 && status < 300) {
          if (toast) {
            toast.fire({
              icon: "success",
              title: t("pages.login.dialog.success.title"),
              text: t("pages.login.dialog.success.text"),
            });
            await loadAppData(ls, api);
            router.push(backToUrl.value).catch(() => {});
          }
        } else {
          if (swal) {
            swal.fire({
              icon: "error",
              title: t("errors.generic.title"),
              text: t("errors.generic.text"),
            });
          }
        }
        isSubmitting.value = false;
      },
    );
    const submit = (event: Event) => {
      event.preventDefault();
      submitForm();
    };
    const formIsProcessing = computed(
      () => formIsSubmitting.value || isSubmitting.value,
    );
    const btnDefaults = useDefaults({} as any, "VBtn");
    const submitBtnBindings = computed(() => ({
      ...btnDefaults,
      type: "submit",
      loading: formIsProcessing.value,
      disabled: appData.value.identity.authenticated,
      color: systemAppBarColor.value,
    }));
    const params = computed(() => props.params);
    watch(
      () => params.value,
      (is, _was) => {
        if (is) {
          if (is.username) {
            setFormFieldValue("username", is.username);
          }
          if (is.password) {
            setFormFieldValue("password", is.password);
          }
        }
      },
      { immediate: true, deep: true },
    );
    return {
      systemAppBarColor,
      systemSurfaceColor,
      appData,
      formAction,
      form,
      backToUrl,
      fields,
      submitBtnBindings,
      submit,
      formIsValidating,
      formErrors,
      resetFormFields,
      resetFormField,
      setFormFieldTouched,
      setFormTouched,
      formValues,
    };
  },
});
</script>

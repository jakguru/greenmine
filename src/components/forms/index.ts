import dot from "dot-object";
import Joi from "joi";
import { tlds } from "@hapi/tlds";
import {
  defineComponent,
  h,
  computed,
  ref,
  shallowRef,
  triggerRef,
  watch,
  inject,
} from "vue";
import { useForm } from "vee-validate";
import { useI18n } from "vue-i18n";
import { getFormFieldValidator } from "@/utils/validation";
import { VContainer, VRow, VCol } from "vuetify/components/VGrid";
import { cloneObject } from "@/utils/app";

import type { PropType } from "vue";
import type { FormFieldValidator } from "@/types";
import type { FormContext } from "vee-validate";
import type { ApiService } from "@jakguru/vueprint";

export { Joi, tlds, useI18n, getFormFieldValidator };

export interface FridayFormStructureField {
  cols: number;
  xs?: number;
  sm?: number;
  md?: number;
  lg?: number;
  xl?: number;
  xxl?: number;
  fieldComponent:
    | ReturnType<typeof defineComponent>
    | string
    | ReturnType<typeof h>;
  formKey: string;
  valueKey: string;
  label: string;
  validator?: FormFieldValidator;
  bindings?: Record<string, unknown>;
  validateOnBlur?: boolean;
  validateOnChange?: boolean;
  validateOnInput?: boolean;
  validateOnModelUpdate?: boolean;
}

export type FridayFormStructureRows =
  | []
  | [FridayFormStructureField]
  | [FridayFormStructureField, FridayFormStructureField]
  | [
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
    ]
  | [
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
    ]
  | [
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
    ]
  | [
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
    ]
  | [
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
    ]
  | [
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
    ]
  | [
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
    ]
  | [
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
    ]
  | [
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
    ]
  | [
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
      FridayFormStructureField,
    ];

export type FridayFormStructure = Array<FridayFormStructureRows>;

export const FridayForm = defineComponent({
  name: "FridayForm",
  props: {
    action: {
      type: String,
      required: true,
    },
    method: {
      type: String,
      default: "POST",
    },
    structure: {
      type: Array as PropType<FridayFormStructure>,
      required: true,
    },
    values: {
      type: Object as PropType<Record<string, unknown>>,
      required: true,
    },
    validateOnMount: {
      type: Boolean,
      default: true,
    },
    validHttpStatus: {
      type: Number,
      default: 200,
    },
    modifyPayload: {
      type: Function as PropType<
        (
          payload: Record<string, unknown>,
        ) => Record<string, unknown> | undefined
      >,
      default: undefined,
    },
    noHttp: {
      type: Boolean,
      default: false,
    },
    getFieldOverrides: {
      type: Function as PropType<
        (
          formKey: string,
          value: unknown,
          values: Record<string, unknown>,
        ) => Record<string, unknown> | undefined
      >,
      default: undefined,
    },
  },
  emits: {
    loading: (payload: boolean) => {
      if ("boolean" === typeof payload) {
        return true;
      }
      return false;
    },
    success: (status: number, payload: unknown) => {
      if ("number" === typeof status && "undefined" !== typeof payload) {
        return true;
      }
      return false;
    },
    error: (status: number, payload: unknown) => {
      if ("number" === typeof status && "undefined" !== typeof payload) {
        return true;
      }
      return false;
    },
    submit: (_payload: Record<string, unknown> | undefined) => true,
    "update:values": (payload: Record<string, unknown>) => {
      if ("object" === typeof payload) {
        return true;
      }
      return false;
    },
  },
  setup(props, { emit, slots, expose }) {
    const api = inject<ApiService>("api");
    const action = computed(() => props.action);
    const method = computed(() => props.method);
    const structure = computed(() => props.structure);
    const rawValues = computed(() => props.values);
    const values = computed(() => {
      const ret: Record<string, unknown> = {};
      const raw = cloneObject(rawValues.value);
      Object.keys(raw).forEach((key) => {
        if (key.includes(".")) {
          const keys = key.split(".");
          const rootKey = keys.shift()!;
          const remaining = keys.join(".");
          const dotted = {
            [remaining]: raw[key],
          };
          if (ret[rootKey]) {
            ret[rootKey] = Object.assign({}, ret[rootKey], dot.object(dotted));
          } else {
            ret[rootKey] = dot.object(dotted);
          }
        } else {
          ret[key] = raw[key];
        }
      });
      return ret;
    });
    const validateOnMount = computed(() => props.validateOnMount);
    const validHttpStatus = computed(() => props.validHttpStatus);
    const modifyPayload = computed(
      () => props.modifyPayload || ((v: Record<string, unknown>) => v),
    );
    const makeValidationSchema = () => {
      const ret: Record<string, FormFieldValidator> = {};
      structure.value.forEach((row) => {
        row.forEach((field) => {
          const { formKey, validator } = field;
          ret[formKey] = validator || (() => true);
        });
      });
      return ret;
    };
    const makeInitialValues = () => {
      const ret: Record<string, unknown> = {};
      const vals = cloneObject(values.value);
      structure.value.forEach((row) => {
        row.forEach((field) => {
          const { formKey, valueKey } = field;
          ret[formKey] = dot.pick(valueKey, vals);
        });
      });
      return ret;
    };
    const makeForm = () => {
      return useForm({
        initialValues: cloneObject(makeInitialValues()),
        validationSchema: makeValidationSchema(),
        validateOnMount: validateOnMount.value,
      });
    };
    const formContext = shallowRef<FormContext>(makeForm());
    watch(
      () => structure.value,
      () => {
        formContext.value = makeForm();
        triggerRef(formContext);
      },
      { deep: true, immediate: true },
    );
    watch(
      () => values.value,
      () => {
        const toUpdate = makeInitialValues();
        formContext.value.setValues(toUpdate);
        formContext.value.setTouched(
          Object.assign(
            {},
            ...Object.keys(toUpdate).map((key) => ({ [key]: false })),
          ),
        );
      },
    );
    const submitAbortController = ref<AbortController | undefined>(undefined);
    const doFormSubmit = computed(() => {
      return formContext.value.handleSubmit(async (values) => {
        if (!api) {
          emit("error", 0, new Error("API not found"));
          return;
        }
        if (submitAbortController.value) {
          submitAbortController.value.abort();
        }
        submitAbortController.value = new AbortController();
        const payloadValues: Record<string, unknown> = {};
        Object.keys(values).forEach((key) => {
          const field: FridayFormStructureField | undefined = structure.value
            .flat()
            .find((v) => v.formKey === key);
          if (!field) {
            return;
          }
          const { valueKey } = field;
          if (valueKey.includes(".")) {
            const keys = valueKey.split(".");
            const rootKey = keys.shift()!;
            const remaining = keys.join(".");
            const dotted = {
              [remaining]: values[key],
            };
            if (payloadValues[rootKey]) {
              payloadValues[rootKey] = Object.assign(
                {},
                payloadValues[rootKey],
                dot.object(dotted),
              );
            } else {
              payloadValues[rootKey] = dot.object(dotted);
            }
          } else {
            payloadValues[valueKey] = values[key];
          }
        });
        const payload = modifyPayload.value(payloadValues);
        if (props.noHttp) {
          emit("submit", payload);
          return;
        }
        try {
          const { status, data } = await api.request({
            method: method.value,
            url: action.value,
            data: ["post", "put", "patch"].includes(method.value.toLowerCase())
              ? payload
              : undefined,
            params: !["post", "put", "path"].includes(
              method.value.toLowerCase(),
            )
              ? payload
              : undefined,
            signal: submitAbortController.value.signal,
          });
          if (status === validHttpStatus.value) {
            emit("success", status, data);
            return;
          } else {
            emit("error", status, data);
            return;
          }
        } catch (e) {
          if (submitAbortController.value.signal.aborted) {
            return;
          }
          if (e instanceof Error) {
            if ("response" in e) {
              emit(
                "error",
                (e.response as any).status,
                (e.response as any).data,
              );
            } else {
              emit("error", 0, e);
            }
            return;
          } else {
            emit("error", 0, new Error("Unknown error"));
            return;
          }
        }
      });
    });
    const onFormSubmit = (e?: Event) => {
      if (e) {
        e.preventDefault();
      }
      doFormSubmit.value();
    };
    const onFormReset = (e?: Event) => {
      if (e) {
        e.preventDefault();
      }
      formContext.value.resetForm();
    };
    const isSubmitting = computed(() => formContext.value.isSubmitting.value);
    const isValidating = computed(() => formContext.value.isValidating.value);
    const isLoading = computed(() => isSubmitting.value || isValidating.value);
    const isTouched = computed(() => formContext.value.meta.value.touched);
    const isDirty = computed(() => formContext.value.meta.value.dirty);
    const isValid = computed(() => formContext.value.meta.value.valid);
    const isPending = computed(() => formContext.value.meta.value.pending);
    const errors = computed(() => formContext.value.errors.value);
    watch(
      () => isLoading.value,
      (value) => {
        emit("loading", value);
      },
    );
    watch(
      () => formContext.value,
      (ctx) => {
        emit("update:values", cloneObject(ctx.values));
      },
      { deep: true, immediate: true },
    );
    watch(
      () => formContext.value.values,
      (is) => {
        emit("update:values", cloneObject(is));
      },
      { deep: true },
    );
    const focusedRef = ref<Record<string, boolean>>({});
    const focused = computed(() => {
      const ret: Record<string, boolean> = {};
      structure.value.forEach((row) => {
        row.forEach((field) => {
          ret[field.formKey] = focusedRef.value[field.formKey] || false;
        });
      });
      return ret;
    });
    const isFocused = computed(() => {
      return Object.values(focused.value).some((v) => v);
    });
    const canSubmit = computed(() => {
      return !isLoading.value && isValid.value;
    });
    const slotProps = computed(() => ({
      isLoading: isLoading.value,
      isSubmitting: isSubmitting.value,
      isValidating: isValidating.value,
      isTouched: isTouched.value,
      isDirty: isDirty.value,
      isValid: isValid.value,
      isPending: isPending.value,
      isFocused: isFocused.value,
      errors: errors.value,
      canSubmit: canSubmit.value,
      submit: onFormSubmit,
      reset: onFormReset,
    }));
    const hyperscriptForField = (field: FridayFormStructureField) => {
      const props = bindings.value[field.formKey];
      if ("project_list_defaults.column_names" === field.formKey) {
        console.log(field.formKey, { props });
      }
      if ("string" === typeof field.fieldComponent) {
        switch (field.fieldComponent) {
          default:
            return h(
              "span",
              `Unknown field component: ${field.fieldComponent}`,
            );
        }
      } else if (field.fieldComponent instanceof Function) {
        return field.fieldComponent;
      } else {
        return h(field.fieldComponent, props);
      }
    };
    const bindings = computed(() => {
      const ret: Record<string, Record<string, unknown>> = {};
      structure.value.forEach((row) => {
        row.forEach((field) => {
          const [modelValue, fieldProps] = formContext.value.defineField(
            field.formKey,
            {
              props: (state) => {
                const fieldProps: Record<string, unknown> = {};
                if ("function" === typeof props.getFieldOverrides) {
                  const overrides = props.getFieldOverrides(
                    field.formKey,
                    "object" === typeof modelValue.value &&
                      null !== modelValue.value
                      ? cloneObject(modelValue.value)
                      : modelValue.value,
                    "object" === typeof formContext.value.values &&
                      null !== formContext.value.values
                      ? cloneObject(formContext.value.values)
                      : formContext.value.values,
                  );
                  if (overrides) {
                    Object.keys(overrides).forEach((key) => {
                      fieldProps[key] = overrides[key];
                    });
                  }
                }
                if (field.bindings) {
                  Object.keys(field.bindings).forEach((key) => {
                    fieldProps[key] = field.bindings![key];
                  });
                }
                fieldProps.errorMessages = state.touched
                  ? state.errors.filter(
                      (v: unknown) =>
                        typeof v === "string" && v.trim().length > 0,
                    )
                  : [];
                fieldProps.hideDetails =
                  !state.touched ||
                  focused.value[field.formKey] ||
                  state.errors.filter(
                    (v: unknown) =>
                      typeof v === "string" && v.trim().length > 0,
                  ).length === 0
                    ? true
                    : "auto";
                fieldProps.onFocus = () => {
                  focusedRef.value[field.formKey] = true;
                };
                fieldProps.onBlur = () => {
                  focusedRef.value[field.formKey] = false;
                };
                const originalDisabled = fieldProps.disabled;
                fieldProps.disabled = isSubmitting.value || originalDisabled;
                const originalClearable = fieldProps.clearable;
                fieldProps.clearable = !isLoading.value && originalClearable;
                fieldProps.autocapitalize = "off";
                fieldProps.spellcheck = false;
                const originalOnUpdateModelValue =
                  fieldProps["onUpdate:modelValue"];
                fieldProps["onUpdate:modelValue"] = (v: unknown) => {
                  if (originalOnUpdateModelValue) {
                    // @ts-ignore
                    originalOnUpdateModelValue(v);
                  }
                  modelValue.value = v;
                };
                const originalOnUpdateModelDashValue =
                  fieldProps["onUpdate:model-value"];
                fieldProps["onUpdate:model-value"] = (v: unknown) => {
                  if (originalOnUpdateModelDashValue) {
                    // @ts-ignore
                    originalOnUpdateModelDashValue(v);
                  }
                  modelValue.value = v;
                };
                return fieldProps;
              },
              label: field.label,
              validateOnBlur:
                "undefined" === typeof field.validateOnBlur
                  ? true
                  : field.validateOnBlur,
              validateOnChange:
                "undefined" === typeof field.validateOnChange
                  ? true
                  : field.validateOnChange,
              validateOnInput:
                "undefined" === typeof field.validateOnInput
                  ? false
                  : field.validateOnInput,
              validateOnModelUpdate:
                "undefined" === typeof field.validateOnModelUpdate
                  ? true
                  : field.validateOnModelUpdate,
            },
          );
          ret[field.formKey] = {
            ...fieldProps.value,
            modelValue: modelValue.value,
          };
        });
      });
      return ret;
    });
    const setValue = (key: string, value: unknown) => {
      formContext.value.setFieldValue(key, value);
    };
    const setValues = (values: Record<string, unknown>) => {
      formContext.value.setValues(values);
    };
    expose({
      setValue,
      setValues,
    });
    return () =>
      h(
        "form",
        {
          action: action.value,
          method: method.value,
          onSubmit: onFormSubmit,
        },
        [
          h("input", { type: "submit", style: { display: "none" } }),
          slots.before ? slots.before(slotProps.value) : null,
          h(VContainer, { fluid: true }, [
            slots.beforeRows ? slots.beforeRows(slotProps.value) : null,
            ...structure.value.map((row, rowIndex) =>
              h(
                VRow,
                { key: rowIndex },
                row.map((field, fieldIndex) =>
                  h(
                    VCol,
                    {
                      key: fieldIndex,
                      cols: field.cols,
                      xs: field.xs,
                      sm: field.sm,
                      md: field.md,
                      lg: field.lg,
                      xl: field.xl,
                      xxl: field.xxl,
                    },
                    hyperscriptForField(field),
                  ),
                ),
              ),
            ),
            slots.afterRows ? slots.afterRows(slotProps.value) : null,
          ]),
          slots.after ? slots.after(slotProps.value) : null,
        ],
      );
  },
});

export type FridayFormComponent = typeof FridayForm;

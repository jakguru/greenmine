import Joi from "joi";
import { defineComponent, h, computed } from "vue";
import { useForm } from "vee-validate";
import { useI18n } from "vue-i18n";
import { getFormFieldValidator, vuetifyConfig } from "@/utils/validation";
import { useDefaults } from "@/utils/vuetify";
import { VContainer, VRow, VCol } from "vuetify/components/VGrid";

import type { PropType } from "vue";
import type { FormFieldValidator, FieldValidationMetaInfo } from "@/types";

export { Joi, useI18n, getFormFieldValidator };

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
  validator?: FormFieldValidator;
  bindings?: Record<string, unknown>;
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
  },
  emits: {
    loading: (payload: boolean) => {
      if ("boolean" === typeof payload) {
        return true;
      }
      return false;
    },
  },
  setup(props, { emit }) {
    const action = computed(() => props.action);
    const method = computed(() => props.method);
    const structure = computed(() => props.structure);
    const values = computed(() => props.values);
    const onFormSubmit = (e?: Event) => {
      if (e) {
        e.preventDefault();
      }
    };
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
          h(
            VContainer,
            { fluid: true },
            structure.value.map((row, rowIndex) =>
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
                    [field.formKey],
                  ),
                ),
              ),
            ),
          ),
          h("pre", JSON.stringify(structure.value, null, 2)),
          h("pre", JSON.stringify(values.value, null, 2)),
        ],
      );
  },
});

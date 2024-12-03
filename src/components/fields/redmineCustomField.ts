import { defineComponent, computed, h } from "vue";

import { VTextField } from "vuetify/components/VTextField";
import { VTextarea } from "vuetify/components";
import { VSwitch } from "vuetify/components/VSwitch";
import { VFileInput } from "vuetify/components/VFileInput";
import { VAutocomplete } from "vuetify/components";

import type { PropType, Component } from "vue";
import type { ProjectCustomField } from "@/friday";

export const VRedmineCustomField = defineComponent({
  name: "VRedmineCustomField",
  props: {
    appendIcon: {
      type: [String, Object, Function] as PropType<any | undefined>,
      default: undefined,
    },
    density: {
      type: String as PropType<"default" | "comfortable" | "compact">,
      default: "default",
    },
    fieldConfiguration: {
      type: Object as PropType<ProjectCustomField>,
      required: true,
    },
    id: {
      type: String as PropType<string | undefined>,
      default: undefined,
    },
    loading: {
      type: Boolean,
      default: false,
    },
    maxErrors: {
      type: [String, Number] as PropType<string | number>,
      default: 1,
    },
    maxWidth: {
      type: [String, Number] as PropType<string | number | undefined>,
      default: undefined,
    },
    modelValue: {
      type: [String, Number, Boolean, Object, Array] as PropType<
        any | any[] | undefined
      >,
      default: undefined,
    },
    persistentHint: {
      type: Boolean,
      default: false,
    },
    prependIcon: {
      type: [String, Object, Function] as PropType<any | undefined>,
      default: undefined,
    },
    readonly: {
      type: Boolean,
      default: false,
    },
    theme: {
      type: String as PropType<string | undefined>,
      default: undefined,
    },
    validateOn: {
      type: String as PropType<
        | "eager"
        | "lazy"
        | "blur"
        | "input"
        | "submit"
        | "invalid-input"
        | "blur lazy"
        | "input lazy"
        | "submit lazy"
        | "invalid-input lazy"
        | "blur eager"
        | "input eager"
        | "submit eager"
        | "invalid-input eager"
        | "lazy blur"
        | "lazy input"
        | "lazy submit"
        | "lazy invalid-input"
        | "eager blur"
        | "eager input"
        | "eager submit"
        | "eager invalid-input"
        | undefined
      >,
      default: undefined,
    },
    validationValue: {
      type: String as PropType<string | undefined>,
      default: undefined,
    },
    variant: {
      type: String as PropType<"outlined">,
      default: "outlined",
    },
    width: {
      type: [String, Number] as PropType<string | number | undefined>,
      default: undefined,
    },
    onChange: {
      type: Function as PropType<() => void>,
      default: undefined,
    },
    onFocus: {
      type: Function as PropType<() => void>,
      default: undefined,
    },
    onBlur: {
      type: Function as PropType<() => void>,
      default: undefined,
    },
    onInput: {
      type: Function as PropType<() => void>,
      default: undefined,
    },
  },
  setup(props) {
    const fieldConfiguration = computed(() => props.fieldConfiguration);
    const component = computed<Component>(() => {
      switch (fieldConfiguration.value.field_format) {
        case "attachment":
          return VFileInput;
        case "enumeration":
        case "list":
        case "user":
        case "version":
          return VAutocomplete;
        case "bool":
          return VSwitch;
        case "text":
          return VTextarea;
        case "string":
        case "int":
        case "float":
        case "link":
        case "date":
        default:
          return VTextField;
      }
    });
    const fieldFormatOptions = computed(() => {
      switch (fieldConfiguration.value.field_format) {
        case "attachment":
          return {};
        case "enumeration":
          return {
            items: [...fieldConfiguration.value.enumerations]
              .sort((a, b) => a.position - b.position)
              .map((item) => ({
                value: item.id,
                label: item.name,
                disabled: !item.active,
              })),
            multiple: fieldConfiguration.value.multiple,
          };
        case "list":
          return {
            items: [...fieldConfiguration.value.possible_values!].map(
              (item) => ({
                value: item,
                label: item,
              }),
            ),
            multiple: fieldConfiguration.value.multiple,
          };
        case "user":
        case "version":
          return {
            items: [...fieldConfiguration.value.enumerations]
              .sort((a, b) => a.position - b.position)
              .map((item) => ({
                value: item.id,
                label: item.name,
                disabled: !item.active,
              })),
            multiple: fieldConfiguration.value.multiple,
          };
        case "bool":
          return {
            trueValue: "1",
            falseValue: "0",
          };
        case "text":
          return {};
        case "string":
          return {};
        case "int":
          return {
            type: "number",
            steps: 1,
          };
        case "float":
          return {
            type: "number",
            steps: "any",
          };
        case "link":
          return {
            type: "url",
          };
        case "date":
          return {
            type: "date",
          };
        default:
          return {};
      }
    });
    const bindings = computed(() => ({
      ...fieldFormatOptions.value,
      appendIcon: props.appendIcon,
      density: props.density,
      id: props.id,
      loading: props.loading,
      maxErrors: props.maxErrors,
      maxWidth: props.maxWidth,
      modelValue: props.modelValue,
      persistentHint: props.persistentHint,
      prependIcon: props.prependIcon,
      readonly: props.readonly,
      theme: props.theme,
      validateOn: props.validateOn,
      validationValue: props.validationValue,
      variant: props.variant,
      width: props.width,
      onChange: props.onChange,
      onFocus: props.onFocus,
      onBlur: props.onBlur,
      onInput: props.onInput,
      label: fieldConfiguration.value.name,
      hint: fieldConfiguration.value.description,
    }));
    return () => h(component.value, bindings.value);
  },
});

/* eslint-disable vue/one-component-per-file */
import { defineComponent, computed, h, watch } from "vue";
import { VTextField } from "vuetify/components/VTextField";
import { VAutocomplete } from "vuetify/components/VAutocomplete";
import { VCombobox } from "vuetify/components/VCombobox";
import { appDebug } from "@/utils/app";

import type { PropType } from "vue";

interface ValuesCellComponentConfiguration {
  component: string;
  bindings: Record<string, any>;
  onUpdateModelValue?: (value: any) => void;
  modelValue: any;
}

interface ValuesGlueCellComponentConfiguration {
  component: "GlueCell";
  bindings: Record<string, any>;
}

export type ValuesCellConfiguration =
  | ValuesCellComponentConfiguration
  | ValuesGlueCellComponentConfiguration;

export const GlueCell = defineComponent({
  name: "GlueCell",
  props: {
    text: {
      type: String,
      default: "",
    },
  },
  setup(props) {
    const text = computed(() => props.text);
    return () =>
      h(
        "div",
        {
          class: "glue-cell",
        },
        [h("span", text.value)],
      );
  },
});

export const ValuesCellComponent = defineComponent({
  name: "ValuesCellComponent",
  props: {
    configuration: {
      type: Object as PropType<ValuesCellConfiguration>,
      required: true,
    },
  },
  setup(props) {
    const configuration = computed(() => props.configuration);
    watch(
      () => configuration.value,
      (value) => {
        appDebug("ValuesCellComponent configuration changed", value);
      },
      { deep: true },
    );
    const componentName = computed(() => configuration.value.component);
    const bindings = computed(() => configuration.value.bindings);
    const onUpdateModelValue = computed(
      () =>
        (configuration.value as ValuesCellComponentConfiguration)
          .onUpdateModelValue,
    );
    const modelValue = computed({
      get: () =>
        "undefined" !==
        typeof (configuration.value as ValuesCellComponentConfiguration)
          .modelValue
          ? (configuration.value as ValuesCellComponentConfiguration).modelValue
          : undefined,
      set: (value) => {
        if (onUpdateModelValue.value) {
          onUpdateModelValue.value(value);
        }
      },
    });
    return () => {
      switch (componentName.value) {
        case "VAutocomplete":
          return h(VAutocomplete, {
            ...bindings.value,
            modelValue: modelValue.value,
            "onUpdate:modelValue": onUpdateModelValue.value,
          });
        case "VCombobox":
          return h(VCombobox, {
            ...bindings.value,
            modelValue: modelValue.value,
            "onUpdate:modelValue": onUpdateModelValue.value,
          });
        case "VTextField":
          return h(VTextField, {
            ...bindings.value,
            modelValue: modelValue.value,
            "onUpdate:modelValue": onUpdateModelValue.value,
          });
        case "GlueCell":
          return h(GlueCell, {
            ...bindings.value,
          });
        default:
          return h("span", [
            `Unknown component: `,
            h("code", componentName.value),
          ]);
      }
    };
  },
});

<template>
  <v-input v-bind="vInputBindings" ref="vInput">
    <div v-bind="vInputChildBindings">
      <div v-show="loading" class="v-field__loader">
        <v-progress-linear indeterminate color="primary" height="2" />
      </div>
      <v-sheet v-bind="vFieldFieldBindings">
        <label v-if="label" class="v-label v-field-label">{{ label }}</label>
        <v-container fluid>
          <v-row v-for="group in grouped" :key="group.value">
            <v-col cols="12">
              <v-subheader class="mb-2">{{ group.label }}</v-subheader>
              <fieldset class="d-flex flex-wrap w-100 pa-3">
                <v-switch
                  v-for="p in group.permissions"
                  :key="`${group.value}-${p.value}`"
                  v-model:model-value="value"
                  :value="p.value"
                  :label="p.label"
                  class="me-3"
                />
              </fieldset>
            </v-col>
          </v-row>
        </v-container>
      </v-sheet>
      <div class="v-field__outline">
        <div class="v-field__outline__start"></div>
        <div class="v-field__outline__notch">
          <label
            v-if="label"
            class="v-label v-field-label v-field-label--floating"
          >
            {{ label }}
          </label>
        </div>
        <div class="v-field__outline__end"></div>
      </div>
    </div>
  </v-input>
</template>

<script lang="ts">
import { defineComponent, computed, ref, watch } from "vue";
import { useTheme, useLocale } from "vuetify";
import {
  checkObjectEquality,
  cloneObject,
  useSystemAccentColor,
} from "@/utils/app";
import type { PropType } from "vue";
import type { VInput } from "vuetify/components/VInput";
import type { RoleValuesProp, Role } from "@/friday";

export default defineComponent({
  name: "PermissionsGroupedField",
  components: {},
  props: {
    appendIcon: {
      type: [String, Object, Function] as PropType<any | undefined>,
      default: undefined,
    },
    density: {
      type: String as PropType<"default" | "comfortable" | "compact">,
      default: "default",
    },
    disabled: {
      type: Boolean,
      default: false,
    },
    error: {
      type: Boolean,
      default: false,
    },
    errorMessages: {
      type: [String, Array] as PropType<string | string[]>,
      default: () => [],
    },
    focused: {
      type: Boolean,
      default: false,
    },
    hideDetails: {
      type: Boolean,
      default: false,
    },
    hideSpinButtons: {
      type: Boolean,
      default: false,
    },
    hint: {
      type: String as PropType<string | undefined>,
      default: undefined,
    },
    id: {
      type: String as PropType<string | undefined>,
      default: undefined,
    },
    label: {
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
    messages: {
      type: [String, Array] as PropType<string | string[]>,
      default: () => [],
    },
    minWidth: {
      type: [String, Number] as PropType<string | number | undefined>,
      default: undefined,
    },
    modelValue: {
      type: Array as PropType<Array<string>>,
      default: () => [],
    },
    name: {
      type: String as PropType<string | undefined>,
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
    rules: {
      type: Array as PropType<any[] | undefined>,
      default: undefined,
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
    permissions: {
      type: Array as PropType<RoleValuesProp["permissions"]>,
      default: () => [],
    },
    groups: {
      type: Array as PropType<RoleValuesProp["groups"]>,
      default: () => [],
    },
    model: {
      type: Object as PropType<Role>,
      default: () => ({}),
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
  emits: {
    "update:modelValue": (val: Array<string>) => Array.isArray(val),
    "update:model-value": (val: Array<string>) => Array.isArray(val),
    update: (val: Array<string>) => Array.isArray(val),
  },
  setup(props, { emit }) {
    const onChange = computed(() => props.onChange);
    const onFocus = computed(() => props.onFocus);
    const onBlur = computed(() => props.onBlur);
    const onInput = computed(() => props.onInput);
    const theme = useTheme();
    const locale = useLocale();
    const fieldInFocus = ref(false);
    const vInputBindings = computed(() => ({
      appendIcon: props.appendIcon,
      density: props.density,
      disabled: props.disabled,
      error: props.error,
      errorMessages: props.errorMessages,
      focused: props.focused || fieldInFocus.value,
      hideDetails: props.hideDetails,
      hideSpinButtons: props.hideSpinButtons,
      hint: props.hint,
      id: props.id,
      label: props.label,
      maxErrors: props.maxErrors,
      maxWidth: props.maxWidth,
      messages: props.messages,
      minWidth: props.minWidth,
      modelValue: props.modelValue,
      name: props.name,
      persistentHint: props.persistentHint,
      prependIcon: props.prependIcon,
      readonly: props.readonly,
      rules: props.rules,
      theme: props.theme,
      validateOn: props.validateOn,
      validationValue: props.validationValue,
      width: props.width,
      onFocus: onFocus.value,
      onBlur: onBlur.value,
    }));
    const vInput = ref<VInput | null>(null);
    const vInputChildBindings = computed(() => ({
      class: [
        "v-field",
        "v-column-selector",
        "v-field--active",
        "v-field--top-affix",
        `v-field--variant-${props.variant}`,
        `v-theme--${theme.global.name.value}`,
        `v-locale--is-${locale.isRtl.value ? "rtl" : "ltr"}`,
      ],
    }));
    const vFieldFieldBindings = computed(() => ({
      class: ["v-field__field", "v-repository-commit-update-keywords__field"],
      minHeight: "48px",
      color: "transparent",
    }));
    const value = ref<Array<string>>(props.modelValue);
    watch(
      () => props.modelValue,
      (is, was) => {
        if (checkObjectEquality(is, was)) {
          return;
        }
        value.value = cloneObject(is);
      },
      { immediate: true, deep: true },
    );
    watch(
      () => value.value,
      (is) => {
        emit("update:modelValue", is);
        emit("update:model-value", is);
        if (onInput.value) {
          onInput.value();
        }
        if (onChange.value) {
          onChange.value();
        }
      },
      { deep: true },
    );
    const accentColor = useSystemAccentColor();
    const permissions = computed(() => props.permissions);
    const groups = computed(() => props.groups);
    const grouped = computed(() =>
      [...groups.value].map((group) => ({
        ...group,
        permissions: [...permissions.value].filter(
          (p) => p.group === group.value,
        ),
      })),
    );
    return {
      vInputBindings,
      vInput,
      vInputChildBindings,
      vFieldFieldBindings,
      value,
      accentColor,
      grouped,
    };
  },
});
</script>

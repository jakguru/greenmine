<template>
  <v-input v-bind="vInputBindings" ref="vInput">
    <div v-bind="vInputChildBindings">
      <div v-show="loading" class="v-field__loader">
        <v-progress-linear indeterminate color="primary" height="2" />
      </div>
      <div v-bind="vFieldFieldBindings">
        <label v-if="label" class="v-label v-field-label">{{ label }}</label>
        <v-row no-gutters>
          <v-col cols="12" sm="6">
            <v-sheet color="transparent" class="px-3 py-2">
              <VAceEditor
                ref="aceEditor"
                v-bind="binding"
                v-model:value="value"
                @init="onInit"
              />
            </v-sheet>
          </v-col>
          <v-col cols="12" sm="6">
            <v-sheet
              color="surface"
              style="overflow-x: auto; overflow-y: auto"
              class="px-3 py-2 elevation-5"
            >
              <v-sheet color="transparent" height="500">
                <RenderMarkdown :raw="value" />
              </v-sheet>
            </v-sheet>
          </v-col>
        </v-row>
      </div>
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
import ace from "ace-builds";
import "ace-builds/src-noconflict/theme-dreamweaver";
import "ace-builds/src-noconflict/theme-monokai";
import "ace-builds/src-noconflict/ext-linking";
import "ace-builds/src-noconflict/mode-markdown";
import "ace-builds/src-noconflict/ext-language_tools";

import { defineComponent, computed, ref, watch } from "vue";
import { useTheme, useLocale } from "vuetify";
import { VAceEditor } from "vue3-ace-editor";
import { RenderMarkdown } from "@/components/rendering";

import themeDreamweaverUrl from "ace-builds/src-noconflict/theme-dreamweaver?url";
import themeMonokaiUrl from "ace-builds/src-noconflict/theme-monokai?url";
import modeMarkdownUrl from "ace-builds/src-noconflict/mode-markdown?url";

ace.config.setModuleUrl("ace/theme/monokai", themeMonokaiUrl);
ace.config.setModuleUrl("ace/theme/dreamweaver", themeDreamweaverUrl);
ace.config.setModuleUrl("ace/mode/markdown", modeMarkdownUrl);

import type { Ace } from "ace-builds";
import type { PropType } from "vue";
import type { VInput } from "vuetify/components/VInput";

export default defineComponent({
  name: "MarkdownField",
  components: {
    VAceEditor,
    RenderMarkdown,
  },
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
      type: String,
      required: true,
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
    "update:modelValue": (val: string) => "string" === typeof val,
    "update:model-value": (val: string) => "string" === typeof val,
    update: (val: string) => "string" === typeof val,
  },
  setup(props, { emit }) {
    const onChange = computed(() => props.onChange);
    const onFocus = computed(() => props.onFocus);
    const onBlur = computed(() => props.onBlur);
    const onInput = computed(() => props.onInput);
    const theme = useTheme();
    const locale = useLocale();
    const themeIsDark = computed(
      () => theme.global.name.value === "friday-dark",
    );
    const aceEditor = ref<any | null>(null);
    const binding = computed(() => ({
      style: {
        height: "500px",
        width: "100%",
      },
      readonly: props.disabled || props.readonly,
      wrap: false,
      theme: themeIsDark.value ? "monokai" : "dreamweaver",
      lang: "markdown",
      options: {
        useWorker: true,
        wrap: true,
        showPrintMargin: false,
        showGutter: false,
      },
      onFocus: () => {
        editorInFocus.value = true;
        if (onFocus.value) {
          onFocus.value();
        }
      },
      onBlur: () => {
        editorInFocus.value = false;
        if (onBlur.value) {
          onBlur.value();
        }
      },
    }));
    const editorInFocus = ref(false);
    const vInputBindings = computed(() => ({
      appendIcon: props.appendIcon,
      density: props.density,
      disabled: props.disabled,
      error: props.error,
      errorMessages: props.errorMessages,
      focused: props.focused || editorInFocus.value,
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
    }));
    const vInput = ref<VInput | null>(null);
    const vInputChildBindings = computed(() => ({
      class: [
        "v-field",
        "v-markdown-field",
        editorInFocus.value || props.focused || value.value.length > 0
          ? "v-field--active"
          : "v-field--inactive",
        "v-field--top-affix",
        `v-field--variant-${props.variant}`,
        `v-theme--${theme.global.name.value}`,
        `v-locale--is-${locale.isRtl.value ? "rtl" : "ltr"}`,
      ],
    }));
    const vFieldFieldBindings = computed(() => ({
      class: ["v-field__field", "v-markdown-field__field"],
      style: {
        backgroundColor: themeIsDark.value ? "#272822" : "#FFFFFF",
      },
    }));
    const value = ref<string>(props.modelValue);
    watch(
      () => props.modelValue,
      (val) => {
        value.value = val;
      },
      { immediate: true },
    );
    watch(
      () => value.value,
      (val) => {
        emit("update:modelValue", val);
        emit("update:model-value", val);
        if (onInput.value) {
          onInput.value();
        }
        if (onChange.value) {
          onChange.value();
        }
      },
    );
    const onInit = (editor: Ace.Editor) => {
      if (editor) {
        // noop
      }
    };
    return {
      vInputBindings,
      vInput,
      vInputChildBindings,
      vFieldFieldBindings,
      value,
      binding,
      aceEditor,
      onInit,
    };
  },
});
</script>

<style lang="scss">
.v-markdown-field__field {
  overflow-y: hidden;
}
</style>

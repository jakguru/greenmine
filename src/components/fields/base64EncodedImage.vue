<template>
  <v-input v-bind="vInputBindings" ref="vInput">
    <input
      ref="fileInputField"
      type="file"
      accept="image/*"
      class="d-none"
      @change="onFileInputFieldChange"
    />
    <div v-bind="vInputChildBindings">
      <div v-show="loading" class="v-field__loader">
        <v-progress-linear indeterminate color="primary" height="2" />
      </div>
      <div v-bind="vFieldFieldBindings">
        <label v-if="label" class="v-label v-field-label">{{ label }}</label>
        <v-row no-gutters>
          <v-col cols="12" class="position-relative">
            <v-responsive v-bind="vResponsiveBindings">
              <v-img v-if="value" :src="value" v-bind="vResponsiveBindings" />
            </v-responsive>
            <div
              class="d-flex w-100 h-100 position-absolute justify-center align-center"
              :style="{ top: 0, left: 0 }"
            >
              <div class="d-flex flex-column">
                <v-btn
                  variant="elevated"
                  color="accent"
                  :style="{
                    opacity: value ? 0.35 : 1,
                  }"
                  @click="doOpenFilePicker"
                >
                  <v-icon class="me-2">mdi-image</v-icon>
                  <span>{{ $t("labels.openFilePicker") }}</span>
                </v-btn>
              </div>
            </div>
            <v-btn
              v-if="clearable && value"
              icon
              class="v-btn--icon v-btn--icon--clear position-absolute"
              :style="{ top: '0', right: '0' }"
              variant="plain"
              @click="value = null"
            >
              <v-icon>mdi-close</v-icon>
            </v-btn>
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
import { defineComponent, computed, ref, watch } from "vue";
import { useTheme, useLocale } from "vuetify";

import type { PropType } from "vue";
import type { VInput } from "vuetify/components/VInput";

export default defineComponent({
  name: "Base64EncodedImage",
  props: {
    appendIcon: {
      type: [String, Object, Function] as PropType<any | undefined>,
      default: undefined,
    },
    aspectRatio: {
      type: [String, Number] as PropType<string | number | undefined>,
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
    clearable: {
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
    height: {
      type: [String, Number] as PropType<string | number | undefined>,
      default: undefined,
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
    maxHeight: {
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
    minHeight: {
      type: [String, Number] as PropType<string | number | undefined>,
      default: undefined,
    },
    modelValue: {
      type: String as PropType<string | null>,
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
    "update:modelValue": (val: string | null) =>
      "string" === typeof val || null === val,
    "update:model-value": (val: string | null) =>
      "string" === typeof val || null === val,
    update: (val: string | null) => "string" === typeof val || null === val,
  },
  setup(props, { emit }) {
    // const { t } = useI18n({ useScope: "global" });
    const onChange = computed(() => props.onChange);
    // const onFocus = computed(() => props.onFocus);
    // const onBlur = computed(() => props.onBlur);
    const onInput = computed(() => props.onInput);
    const theme = useTheme();
    const locale = useLocale();
    const themeIsDark = computed(
      () => theme.global.name.value === "friday-dark",
    );
    const isDragging = ref(false);
    const vInputBindings = computed(() => ({
      appendIcon: props.appendIcon,
      density: props.density,
      disabled: props.disabled,
      error: props.error,
      errorMessages: props.errorMessages,
      focused: props.focused || isDragging.value,
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
    const value = ref<string | null>(props.modelValue);
    const handleFile = (file: File) => {
      const reader = new FileReader();
      reader.onload = () => {
        value.value = reader.result as string;
      };
      reader.onerror = () => {};
      reader.readAsDataURL(file);
    };
    const onFileInputFieldChange = (e: Event) => {
      const target = e.target as HTMLInputElement;
      if (!target.files || target.files.length === 0) return;
      for (const file of target.files) {
        handleFile(file);
      }
      target.value = "";
    };
    const vInputChildBindings = computed(() => ({
      class: [
        "v-field",
        "v-base64-encoded-image-field",
        isDragging.value === true ||
        props.focused ||
        ("string" === typeof value.value && value.value.length > 0)
          ? "v-field--active"
          : "v-field--inactive",
        "v-field--top-affix",
        `v-field--variant-${props.variant}`,
        `v-theme--${theme.global.name.value}`,
        `v-locale--is-${locale.isRtl.value ? "rtl" : "ltr"}`,
      ],
      onDrop: (e: DragEvent) => {
        e.preventDefault();
        e.stopPropagation();
        isDragging.value = false;
        if (
          e.dataTransfer &&
          e.dataTransfer.files &&
          e.dataTransfer.files.length
        ) {
          for (const file of e.dataTransfer.files) {
            handleFile(file);
          }
        }
      },
      onDragover: (e: DragEvent) => {
        e.preventDefault();
        e.stopPropagation();
        if (
          e.dataTransfer &&
          e.dataTransfer.files &&
          e.dataTransfer.files.length
        ) {
          isDragging.value = true;
        }
      },
      onDragenter: (e: DragEvent) => {
        e.preventDefault();
        e.stopPropagation();
        if (
          e.dataTransfer &&
          e.dataTransfer.files &&
          e.dataTransfer.files.length
        ) {
          isDragging.value = true;
        }
      },
      onDragleave: (e: DragEvent) => {
        e.preventDefault();
        e.stopPropagation();
        isDragging.value = false;
      },
    }));
    const vFieldFieldBindings = computed(() => ({
      class: [
        "v-field__field",
        "v-base64-encoded-image-field__field",
        isDragging.value
          ? "v-base64-encoded-image-field__field--dragging"
          : undefined,
      ].filter((c) => "string" === typeof c),
      style: {
        backgroundColor: isDragging.value
          ? themeIsDark.value
            ? "#272822"
            : "#FFFFFF"
          : undefined,
      },
    }));
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
    const fileInputField = ref<HTMLInputElement | null>(null);
    const vResponsiveBindings = computed(() => ({
      aspectRatio: props.aspectRatio,
      maxHeight: props.maxHeight,
      maxWidth: props.maxWidth,
      minHeight: props.minHeight,
      minWidth: props.minWidth,
      height: props.height,
      width: props.width,
    }));
    const doOpenFilePicker = () => {
      if (fileInputField.value) {
        fileInputField.value.click();
      }
    };
    return {
      vInputBindings,
      vInput,
      onFileInputFieldChange,
      vInputChildBindings,
      vFieldFieldBindings,
      value,
      fileInputField,
      vResponsiveBindings,
      doOpenFilePicker,
    };
  },
});
</script>

<style lang="scss">
.v-base64-encoded-image-field__field {
  overflow-y: hidden;
}
</style>

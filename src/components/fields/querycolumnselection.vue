<template>
  <v-input v-bind="vInputBindings" ref="vInput">
    <div v-bind="vInputChildBindings">
      <div v-show="loading" class="v-field__loader">
        <v-progress-linear indeterminate color="primary" height="2" />
      </div>
      <v-sheet v-bind="vFieldFieldBindings">
        <label v-if="label" class="v-label v-field-label">{{ label }}</label>
        <v-row no-gutters>
          <v-col cols="12" sm="6">
            <v-list-item :subtitle="$t('labels.selected')">
              <template #append>
                <v-btn
                  size="x-small"
                  variant="text"
                  icon="mdi-notification-clear-all"
                  color="warning"
                  :disabled="0 === value.length"
                  @click="onClearAll"
                />
              </template>
            </v-list-item>
            <v-divider />
            <v-sheet
              color="transparent"
              class="draggable-list-wrapper"
              min-width="300"
              max-height="400"
            >
              <draggable
                v-model="selectedColumns"
                item-key="value"
                group="columns"
                class="draggable-group"
                ghost-class="ghost"
              >
                <template #item="{ element, index }">
                  <v-list-item
                    :title="element.label"
                    min-width="300"
                    density="compact"
                  >
                    <template #append>
                      <div class="d-flex h-100 align-center">
                        <v-btn
                          size="x-small"
                          variant="text"
                          icon="mdi-chevron-up"
                          color="info"
                          :disabled="0 === index"
                          @click="onMoveSelectedColumnUp(index)"
                        />
                        <v-btn
                          size="x-small"
                          variant="text"
                          icon="mdi-chevron-down"
                          color="info"
                          :disabled="index === selectedColumns.length - 1"
                          @click="onMoveSelectedColumnDown(index)"
                        />
                        <v-btn
                          variant="text"
                          size="x-small"
                          color="warning"
                          icon
                          @click="onRemoveFromSelected(index)"
                        >
                          <v-icon>mdi-close</v-icon>
                        </v-btn>
                      </div>
                    </template>
                  </v-list-item>
                </template>
              </draggable>
            </v-sheet>
          </v-col>
          <v-col cols="12" sm="6">
            <v-list-item :subtitle="$t('labels.available')">
              <template #append>
                <v-btn
                  size="x-small"
                  variant="text"
                  icon="mdi-playlist-plus"
                  color="success"
                  :disabled="0 === remainingColumns.length"
                  @click="onAddAll"
                />
              </template>
            </v-list-item>
            <v-divider />
            <v-sheet
              color="transparent"
              class="draggable-list-wrapper"
              min-width="300"
              max-height="400"
            >
              <draggable
                v-model="remainingColumns"
                item-key="value"
                group="columns"
                class="draggable-group"
                ghost-class="ghost"
              >
                <template #item="{ element }">
                  <v-list-item
                    :title="element.label"
                    min-width="300"
                    density="compact"
                  >
                    <template #append>
                      <div class="d-flex h-100 align-center">
                        <v-btn
                          variant="text"
                          size="x-small"
                          color="success"
                          icon
                          @click="onAddToSelected(element)"
                        >
                          <v-icon>mdi-plus</v-icon>
                        </v-btn>
                      </div>
                    </template>
                  </v-list-item>
                </template>
              </draggable>
            </v-sheet>
          </v-col>
        </v-row>
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
import Draggable from "vuedraggable";
import type { PropType } from "vue";
import type { VInput } from "vuetify/components/VInput";

interface QueryColumnSelectionField {
  value: string;
  label: string;
}

export default defineComponent({
  name: "QueryColumnSelectionField",
  components: {
    Draggable,
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
    items: {
      type: Array as PropType<QueryColumnSelectionField[]>,
      default: () => [],
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
      type: Array as PropType<string[]>,
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
    "update:modelValue": (val: string[]) =>
      Array.isArray(val) && val.every((v) => "string" === typeof v),
    "update:model-value": (val: string[]) =>
      Array.isArray(val) && val.every((v) => "string" === typeof v),
    update: (val: string[]) =>
      Array.isArray(val) && val.every((v) => "string" === typeof v),
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
      class: ["v-field__field", "v-column-selector__field"],
      minHeight: "48px",
      color: "transparent",
    }));
    const value = ref<string[]>(props.modelValue);
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
    const items = computed(() =>
      Array.isArray(props.items) ? props.items : [],
    );
    const selectedColumns = computed({
      get: () =>
        Array.isArray(value.value)
          ? value.value.map((column) =>
              items.value.find((item) => item.value === column),
            )
          : [],
      set: (columns: Array<QueryColumnSelectionField>) => {
        value.value = columns.map((column) => column.value);
      },
    });
    const remainingColumns = computed({
      get: () =>
        [...items.value].filter(
          (column) => !value.value.includes(column.value),
        ),
      set: (_value: Array<QueryColumnSelectionField>) => {
        // noop - the list is automatically calculated based on the selected columns from the available columns
      },
    });
    const onMoveSelectedColumnUp = (index: number) => {
      if (index > 0) {
        const [item] = value.value.splice(index, 1);
        value.value.splice(index - 1, 0, item);
      }
    };
    const onMoveSelectedColumnDown = (index: number) => {
      if (index < value.value.length - 1) {
        const [item] = value.value.splice(index, 1);
        value.value.splice(index + 1, 0, item);
      }
    };
    const onRemoveFromSelected = (index: number) => {
      value.value.splice(index, 1);
    };
    const onAddToSelected = (field: QueryColumnSelectionField) => {
      value.value.push(field.value);
    };
    const onClearAll = () => {
      value.value = [];
    };
    const onAddAll = () => {
      remainingColumns.value.forEach((c) => {
        value.value.push(c.value);
      });
    };
    return {
      vInputBindings,
      vInput,
      vInputChildBindings,
      vFieldFieldBindings,
      value,
      selectedColumns,
      remainingColumns,
      onMoveSelectedColumnUp,
      onMoveSelectedColumnDown,
      onRemoveFromSelected,
      onAddToSelected,
      onClearAll,
      onAddAll,
    };
  },
});
</script>

<style lang="scss">
.v-column-selector__field {
  overflow-y: hidden;
}
</style>

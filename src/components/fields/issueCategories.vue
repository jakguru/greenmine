<template>
  <v-input v-bind="vInputBindings" ref="vInput">
    <div v-bind="vInputChildBindings">
      <div v-show="loading" class="v-field__loader">
        <v-progress-linear indeterminate color="primary" height="2" />
      </div>
      <div v-bind="vFieldFieldBindings">
        <label v-if="label" class="v-label v-field-label">{{ label }}</label>
        <v-table class="w-100">
          <thead>
            <tr>
              <th>{{ $t("labels.issueCategory") }}</th>
              <th>{{ $t("labels.assignee") }}</th>
              <th width="40">&nbsp;</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(entry, index) in value" :key="`entry-${index}`">
              <td width="50%" class="d-flex w-100 align-center">
                <div class="ms-5" v-text="entry.name" />
              </td>
              <td>
                <v-autocomplete
                  v-model="value[index].assigned_to_id"
                  :items="assignees"
                  item-title="label"
                  hide-details
                  density="compact"
                  clearable
                />
              </td>
              <td width="40" class="text-center">
                <v-btn
                  icon="mdi-delete"
                  color="warning"
                  size="x-small"
                  @click="doRemove(index)"
                />
              </td>
            </tr>
          </tbody>
          <tfoot>
            <tr>
              <th>
                <v-text-field
                  v-model="toAdd.name"
                  hide-details
                  density="compact"
                />
              </th>
              <th>
                <v-autocomplete
                  v-model="toAdd.assigned_to_id"
                  :items="assignees"
                  item-title="label"
                  hide-details
                  density="compact"
                  clearable
                />
              </th>
              <th width="40" class="text-center">
                <v-btn
                  icon="mdi-plus"
                  color="accent"
                  size="x-small"
                  @click="doAdd"
                />
              </th>
            </tr>
          </tfoot>
        </v-table>
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
import { useSystemAccentColor } from "@/utils/app";

import type { PropType } from "vue";
import type { VInput } from "vuetify/components/VInput";
import type { SelectableListItem, ProjectModelIssueCategory } from "@/friday";

export default defineComponent({
  name: "IssueCategoriesField",
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
      type: Array as PropType<ProjectModelIssueCategory[]>,
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
    assignees: {
      type: Array as PropType<SelectableListItem<number>[]>,
      required: true,
    },
    roles: {
      type: Array as PropType<SelectableListItem<number>[]>,
      required: true,
    },
  },
  emits: {
    "update:modelValue": (val: ProjectModelIssueCategory[]) =>
      Array.isArray(val),
    "update:model-value": (val: ProjectModelIssueCategory[]) =>
      Array.isArray(val),
    update: (val: ProjectModelIssueCategory[]) => Array.isArray(val),
  },
  setup(props, { emit }) {
    // const { t } = useI18n({ useScope: "global" });
    const onChange = computed(() => props.onChange);
    // const onFocus = computed(() => props.onFocus);
    // const onBlur = computed(() => props.onBlur);
    const onInput = computed(() => props.onInput);
    const theme = useTheme();
    const locale = useLocale();
    const vInputBindings = computed(() => ({
      appendIcon: props.appendIcon,
      density: props.density,
      disabled: props.disabled,
      error: props.error,
      errorMessages: props.errorMessages,
      focused: props.focused,
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
    const value = ref<ProjectModelIssueCategory[]>(props.modelValue);
    const vInputChildBindings = computed(() => ({
      class: [
        "v-field",
        "v-issue-categories-field",
        "v-field--active",
        "v-field--top-affix",
        `v-field--variant-${props.variant}`,
        `v-theme--${theme.global.name.value}`,
        `v-locale--is-${locale.isRtl.value ? "rtl" : "ltr"}`,
      ],
    }));
    const vFieldFieldBindings = computed(() => ({
      class: ["v-field__field", "v-issue-categories-field__field"].filter(
        (c) => "string" === typeof c,
      ),
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
    const toAdd = ref<any>({
      name: null,
      assigned_to_id: null,
    });
    const doAdd = () => {
      if (toAdd.value.name) {
        value.value.push(toAdd.value);
        toAdd.value = {
          name: null,
          assigned_to_id: null,
        };
      }
    };
    const doRemove = (index: number) => {
      value.value.splice(index, 1);
    };
    const accentColor = useSystemAccentColor();
    return {
      vInputBindings,
      vInput,
      vInputChildBindings,
      vFieldFieldBindings,
      value,
      toAdd,
      doAdd,
      doRemove,
      accentColor,
    };
  },
});
</script>

<style lang="scss">
.v-issue-categories-field__field {
  overflow-y: hidden;
}
</style>

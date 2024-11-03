<template>
  <v-input v-bind="vInputBindings" ref="vInput">
    <div v-bind="vInputChildBindings">
      <div v-show="loading" class="v-field__loader">
        <v-progress-linear indeterminate color="primary" height="2" />
      </div>
      <v-sheet v-bind="vFieldFieldBindings">
        <label v-if="label" class="v-label v-field-label">{{ label }}</label>
        <v-container fluid>
          <v-row>
            <v-col cols="2">
              <v-autocomplete
                v-model="valueToAdd.if_tracker_id"
                :items="trackers"
                item-title="label"
                item-value="value"
                :label="$t('labels.repositoryCommitUpdateKeywords.tracker')"
                density="compact"
                outlined
              />
            </v-col>
            <v-col cols="5">
              <VCSVField
                v-model="valueToAdd.keywords"
                :label="$t('labels.repositoryCommitUpdateKeywords.keywords')"
                density="compact"
                outlined
              />
            </v-col>
            <v-col cols="2">
              <v-autocomplete
                v-model="valueToAdd.status_id"
                :items="statuses"
                item-title="label"
                item-value="value"
                :label="$t('labels.repositoryCommitUpdateKeywords.status')"
                density="compact"
                outlined
              />
            </v-col>
            <v-col cols="2">
              <v-select
                v-model="valueToAdd.done_ratio"
                :items="percentages"
                item-title="label"
                item-value="value"
                :label="$t('labels.repositoryCommitUpdateKeywords.percentages')"
                density="compact"
                outlined
              />
            </v-col>
            <v-col cols="1">
              <v-btn block :color="accentColor" @click="addNewRule">
                {{ $t("labels.add") }}
              </v-btn>
            </v-col>
          </v-row>
          <v-row v-for="(_rule, index) in value" :key="index">
            <v-col cols="2">
              <v-autocomplete
                v-model="value[index].if_tracker_id"
                :items="trackers"
                item-title="label"
                item-value="value"
                :label="$t('labels.repositoryCommitUpdateKeywords.tracker')"
                density="compact"
                outlined
              />
            </v-col>
            <v-col cols="5">
              <VCSVField
                v-model="value[index].keywords"
                :label="$t('labels.repositoryCommitUpdateKeywords.keywords')"
                density="compact"
                outlined
              />
            </v-col>
            <v-col cols="2">
              <v-autocomplete
                v-model="value[index].status_id"
                :items="statuses"
                item-title="label"
                item-value="value"
                :label="$t('labels.repositoryCommitUpdateKeywords.status')"
                density="compact"
                outlined
              />
            </v-col>
            <v-col cols="2">
              <v-select
                v-model="value[index].done_ratio"
                :items="percentages"
                item-title="label"
                item-value="value"
                :label="$t('labels.repositoryCommitUpdateKeywords.percentages')"
                density="compact"
                outlined
              />
            </v-col>
            <v-col cols="1">
              <v-btn block color="error" @click="() => removeRule(index)">
                {{ $t("labels.remove") }}
              </v-btn>
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
import { VCSVField } from "./csv";
import Joi from "joi";
import type { PropType } from "vue";
import type { VInput } from "vuetify/components/VInput";

interface QueryColumnSelectionField {
  value: string;
  label: string;
}

interface RepositoryCommitUpdateKeywordsValue {
  if_tracker_id?: string;
  keywords?: string;
  status_id?: string;
  done_ratio?: string;
}

interface InferredRepositoryCommitUpdateKeywordsValue
  extends RepositoryCommitUpdateKeywordsValue {
  if_tracker_id: string;
  keywords: string;
  status_id: string;
  done_ratio: string;
}

const repositoryCommitUpdateKeywordsValueSchema = Joi.object({
  if_tracker_id: Joi.string().optional().allow(""),
  keywords: Joi.string().optional().allow(""),
  status_id: Joi.string().optional().allow(""),
  done_ratio: Joi.string().optional().allow(""),
});

// const repositoryCommitUpdateKeywordsValueSchemaArray = Joi.array().items(
//   repositoryCommitUpdateKeywordsValueSchema,
// );

// const testModelValue = (val: unknown) => {
//   const { error } =
//     repositoryCommitUpdateKeywordsValueSchemaArray.validate(val);
//   return !error;
// };

const inferRepositoryCommitUpdateKeywordsValue = (
  val: RepositoryCommitUpdateKeywordsValue,
): InferredRepositoryCommitUpdateKeywordsValue => {
  return {
    if_tracker_id: val.if_tracker_id || "",
    keywords: val.keywords || "",
    status_id: val.status_id || "",
    done_ratio: val.done_ratio || "",
  };
};

const inferRepositoryCommitUpdateKeywordsValues = (
  val: RepositoryCommitUpdateKeywordsValue[],
): InferredRepositoryCommitUpdateKeywordsValue[] => {
  return val.map(inferRepositoryCommitUpdateKeywordsValue);
};

export default defineComponent({
  name: "RepositoryCommitUpdateKeywords",
  components: {
    VCSVField,
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
      type: Array as PropType<RepositoryCommitUpdateKeywordsValue[]>,
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
    percentages: {
      type: Array as PropType<QueryColumnSelectionField[]>,
      default: () => [],
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
    statuses: {
      type: Array as PropType<QueryColumnSelectionField[]>,
      default: () => [],
    },
    trackers: {
      type: Array as PropType<QueryColumnSelectionField[]>,
      default: () => [],
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
    "update:modelValue": (val: RepositoryCommitUpdateKeywordsValue[]) =>
      Array.isArray(val),
    "update:model-value": (val: RepositoryCommitUpdateKeywordsValue[]) =>
      Array.isArray(val),
    update: (val: RepositoryCommitUpdateKeywordsValue[]) => Array.isArray(val),
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
    const value = ref<RepositoryCommitUpdateKeywordsValue[]>(props.modelValue);
    const valueToAdd = ref<RepositoryCommitUpdateKeywordsValue>({
      if_tracker_id: "",
      keywords: "",
      status_id: "",
      done_ratio: "",
    });
    const addNewRule = () => {
      const { error } = repositoryCommitUpdateKeywordsValueSchema.validate(
        valueToAdd.value,
      );
      if (error) {
        return;
      }
      value.value.push(cloneObject(valueToAdd.value));
      valueToAdd.value = {
        if_tracker_id: "",
        keywords: "",
        status_id: "",
        done_ratio: "",
      };
    };
    const removeRule = (index: number) => {
      value.value.splice(index, 1);
    };
    watch(
      () => props.modelValue,
      (is, was) => {
        if (checkObjectEquality(is, was)) {
          return;
        }
        value.value = inferRepositoryCommitUpdateKeywordsValues(is);
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
    return {
      vInputBindings,
      vInput,
      vInputChildBindings,
      vFieldFieldBindings,
      value,
      valueToAdd,
      addNewRule,
      removeRule,
      accentColor,
    };
  },
});
</script>

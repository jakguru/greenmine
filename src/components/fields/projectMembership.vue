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
              <th>{{ $t("labels.project") }}</th>
              <th>{{ $t("labels.roles") }}</th>
              <th width="40">&nbsp;</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(entry, index) in value" :key="`entry-${index}`">
              <td>
                <span v-text="getProjectName(entry.project)" />
              </td>
              <td>
                <v-autocomplete
                  v-model="value[index].roles"
                  :items="roles"
                  item-title="label"
                  hide-details
                  multiple
                  chips
                  closable-chips
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
            <th>
              <v-autocomplete
                v-model="toAdd.project"
                :items="remainingProjects"
                item-title="label"
                hide-details
              />
            </th>
            <th>
              <v-autocomplete
                v-model="toAdd.roles"
                :items="roles"
                item-title="label"
                hide-details
                multiple
                chips
                closable-chips
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

import type { PropType } from "vue";
import type { VInput } from "vuetify/components/VInput";
import type { SelectableListItem, PrincipalMembership } from "@/friday";

export default defineComponent({
  name: "ProjectMembershipField",
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
      type: Array as PropType<PrincipalMembership[]>,
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
    projects: {
      type: Array as PropType<SelectableListItem<number>[]>,
      required: true,
    },
    roles: {
      type: Array as PropType<SelectableListItem<number>[]>,
      required: true,
    },
  },
  emits: {
    "update:modelValue": (val: PrincipalMembership[]) => Array.isArray(val),
    "update:model-value": (val: PrincipalMembership[]) => Array.isArray(val),
    update: (val: PrincipalMembership[]) => Array.isArray(val),
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
    const value = ref<PrincipalMembership[]>(props.modelValue);
    const vInputChildBindings = computed(() => ({
      class: [
        "v-field",
        "v-project-membership-field",
        "v-field--active",
        "v-field--top-affix",
        `v-field--variant-${props.variant}`,
        `v-theme--${theme.global.name.value}`,
        `v-locale--is-${locale.isRtl.value ? "rtl" : "ltr"}`,
      ],
    }));
    const vFieldFieldBindings = computed(() => ({
      class: ["v-field__field", "v-project-membership-field__field"].filter(
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
    const projects = computed(() => props.projects);
    const existingProjectIds = computed(() =>
      [...value.value].map((m) => m.project),
    );
    const remainingProjects = computed(() =>
      [...projects.value].filter(
        (p) => !existingProjectIds.value.includes(p.value),
      ),
    );
    const toAdd = ref<any>({
      project: null,
      roles: [],
    });
    const doAdd = () => {
      if (toAdd.value.project && toAdd.value.roles.length) {
        value.value.push(toAdd.value);
        toAdd.value = {
          project: 0,
          roles: [],
        };
      }
    };
    const doRemove = (index: number) => {
      value.value.splice(index, 1);
    };
    const getProjectName = (id: number) => {
      const project = projects.value.find((p) => p.value === id);
      return project ? project.label : "";
    };
    return {
      vInputBindings,
      vInput,
      vInputChildBindings,
      vFieldFieldBindings,
      value,
      remainingProjects,
      toAdd,
      doAdd,
      doRemove,
      getProjectName,
    };
  },
});
</script>

<style lang="scss">
.v-project-membership-field__field {
  overflow-y: hidden;
}
</style>

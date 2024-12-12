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
              <th>{{ $t("labels.principal") }}</th>
              <th>{{ $t("labels.roles") }}</th>
              <th width="40">&nbsp;</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(entry, index) in value" :key="`entry-${index}`">
              <td width="50%" class="d-flex w-100 align-center">
                <v-badge v-bind="getBadgePropsForPrincipal(entry.principal)">
                  <v-avatar size="36" :color="accentColor">
                    <v-img :src="avatarUrlForPrincipal(entry.principal)" />
                  </v-avatar>
                </v-badge>
                <div class="ms-5" v-text="getPrincipalName(entry.principal)" />
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
                  density="compact"
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
                <v-autocomplete
                  v-model="toAdd.principal"
                  :items="remainingPrincipals"
                  item-title="label"
                  hide-details
                  density="compact"
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
                  density="compact"
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
import type {
  SelectableListItem,
  ProjectPrincipalMembership,
  ProjectValuesPropMember,
} from "@/friday";

export default defineComponent({
  name: "PrincipalMembershipField",
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
      type: Array as PropType<ProjectPrincipalMembership[]>,
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
    principals: {
      type: Array as PropType<ProjectValuesPropMember[]>,
      required: true,
    },
    roles: {
      type: Array as PropType<SelectableListItem<number>[]>,
      required: true,
    },
  },
  emits: {
    "update:modelValue": (val: ProjectPrincipalMembership[]) =>
      Array.isArray(val),
    "update:model-value": (val: ProjectPrincipalMembership[]) =>
      Array.isArray(val),
    update: (val: ProjectPrincipalMembership[]) => Array.isArray(val),
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
    const value = ref<ProjectPrincipalMembership[]>(props.modelValue);
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
    const principals = computed(() => props.principals);
    const existingPrincipalIds = computed(() =>
      [...value.value].map((m) => m.principal),
    );
    const remainingPrincipals = computed(() =>
      [...principals.value].filter(
        (p) => !existingPrincipalIds.value.includes(p.value),
      ),
    );
    const toAdd = ref<any>({
      principal: null,
      roles: [],
    });
    const doAdd = () => {
      if (toAdd.value.principal && toAdd.value.roles.length) {
        value.value.push(toAdd.value);
        toAdd.value = {
          principal: null,
          roles: [],
        };
      }
    };
    const doRemove = (index: number) => {
      value.value.splice(index, 1);
    };
    const getPrincipalName = (id: number) => {
      const principal = principals.value.find((p) => p.value === id);
      return principal ? principal.label : "";
    };
    const avatarUrlForPrincipal = (id: number) => {
      const principal = principals.value.find((p) => p.value === id);
      if (principal && "group" === principal.kind) {
        return `/groups/${principal.value}/avatar`;
      } else {
        return `/users/${principal?.value || 0}/avatar`;
      }
    };
    const getBadgePropsForPrincipal = (id: number) => {
      const base = {
        location: "bottom end" as const,
        offsetX: 0,
        offsetY: 5,
      };
      const principal = principals.value.find((p) => p.value === id);
      if (!principal) {
        return {
          ...base,
          icon: "mdi-question",
          color: "grey",
        };
      } else {
        return {
          ...base,
          icon:
            principal.kind === "group" ? "mdi-account-group" : "mdi-account",
          color: principal.kind === "group" ? "primary" : "secondary",
        };
      }
    };
    const accentColor = useSystemAccentColor();
    return {
      vInputBindings,
      vInput,
      vInputChildBindings,
      vFieldFieldBindings,
      value,
      remainingPrincipals,
      toAdd,
      doAdd,
      doRemove,
      getPrincipalName,
      avatarUrlForPrincipal,
      accentColor,
      getBadgePropsForPrincipal,
    };
  },
});
</script>

<style lang="scss">
.v-project-membership-field__field {
  overflow-y: hidden;
}
</style>

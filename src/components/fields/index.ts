import { defineComponent, computed, h, ref } from "vue";
import { capitalize } from "@/utils/formatting";
import { useDefaults } from "vuetify";
import { VTextField } from "vuetify/components/VTextField";
import { VBtn } from "vuetify/components/VBtn";
import { useI18n } from "vue-i18n";
import VPasswordField from "./password.vue";
import VSaveableTextField from "./savable-text-field.vue";
import VAbbreviatedMultiSelect from "./abbreviatedMultiSelect.vue";
import VMarkdownField from "./markdown.vue";
import VQueryColumnSelectionField from "./querycolumnselection.vue";
import VRepositoryCommitUpdateKeywordsField from "./repositorycommitupdatekeywords.vue";
import VColorField from "./color.vue";
import generatePasswordBrowser from "generate-password-browser";
import VPermissionsGroupedField from "./permissionsGrouped.vue";
import VPermissionsObjectField from "./permissionsObject.vue";
import VPermissionsObjectGroupedField from "./permissionsObjectGrouped.vue";
import VBase64EncodedImageField from "./base64EncodedImage.vue";
import VProjectMembershipField from "./projectMembership.vue";
export { VCSVField } from "./csv";
export { VLBSVField } from "./lbsv";
export {
  VPasswordField,
  VSaveableTextField,
  VMarkdownField,
  VQueryColumnSelectionField,
  VRepositoryCommitUpdateKeywordsField,
  VColorField,
  VAbbreviatedMultiSelect,
  VPermissionsGroupedField,
  VPermissionsObjectField,
  VPermissionsObjectGroupedField,
  VBase64EncodedImageField,
  VProjectMembershipField,
};

const VPasswordFieldWithGeneratorProps: Record<
  string,
  {
    type: any;
    default?: any;
    required?: boolean;
    validator?: any;
  }
> = {
  ...VPasswordField.props,
  length: {
    type: Number,
    default: 10,
  },
  numbers: {
    type: Boolean,
    default: false,
  },
  symbols: {
    type: Boolean,
    default: false,
  },
  lowercase: {
    type: Boolean,
    default: true,
  },
  uppercase: {
    type: Boolean,
    default: true,
  },
  excludeSimilarCharacters: {
    type: Boolean,
    default: false,
  },
  exclude: {
    type: String,
    default: "",
  },
  strict: {
    type: Boolean,
    default: false,
  },
};

export const VPasswordFieldWithGenerator = defineComponent({
  name: "VPasswordFieldWithGenerator",
  components: { VPasswordField },
  props: VPasswordFieldWithGeneratorProps,
  emits: Object.keys({ ...VPasswordField.emits }),
  setup(props, { emit }) {
    const { t } = useI18n({ useScope: "global" });
    const passedProps = computed(() => props);
    const defaults = useDefaults(passedProps.value, "VTextField");
    const updatedEmitters = computed(() => {
      const ret: any = {};
      Object.keys({ ...VTextField.emits }).forEach((evnt) => {
        const key = `on${capitalize(evnt)}`;
        ret[key] = (e: any) => emit(evnt, e);
      });
      return ret;
    });
    const updatedProps = computed(() => ({
      ...defaults,
      ...updatedEmitters.value,
    }));
    const vPasswordField = ref();
    const onAppendedButtonClick = (e?: Event) => {
      if (e) {
        e.preventDefault();
      }
      const password = generatePasswordBrowser.generate({
        length: props.length,
        numbers: props.numbers,
        symbols: props.symbols,
        lowercase: props.lowercase,
        uppercase: props.uppercase,
        excludeSimilarCharacters: props.excludeSimilarCharacters,
        exclude: props.exclude,
        strict: props.strict,
      });
      emit("update:modelValue", password);
    };
    const appendedButtonHeight = computed(() => {
      if (props.height) {
        return props.height;
      }
      switch (props.density) {
        case "compact":
          return 40;
        case "comfortable":
          return 48;
        case "standard":
        default:
          return 56;
      }
    });
    const appendedButtonProps = computed(() => ({
      disabled: (props.disabled || props.readonly || props.loading) as boolean,
      variant: "outlined" as const,
      onClick: onAppendedButtonClick,
      density: props.density,
      height: appendedButtonHeight.value,
    }));
    return () =>
      h(
        VPasswordField,
        {
          ref: vPasswordField,
          ...updatedProps.value,
        },
        {
          append: () =>
            h(VBtn, appendedButtonProps.value, [t("labels.generate")]),
        },
      );
  },
});

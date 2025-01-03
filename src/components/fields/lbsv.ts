import { computed, defineComponent, ref, watch, h } from "vue";
import { VCombobox } from "vuetify/components/VCombobox";
import { useDefaults } from "vuetify";
import { capitalize } from "@/utils/formatting";

const VLBSVProps: Record<
  string,
  {
    type: any;
    default?: any;
    required?: boolean;
    validator?: any;
  }
> = {
  ...VCombobox.props,
  modelValue: {
    type: String,
    default: "",
  },
};

export const VLBSVField = defineComponent({
  name: "VLBSVField",
  props: VLBSVProps,
  emits: Object.keys({ ...VCombobox.emits }),
  setup(props, { emit }) {
    const sourceValue = computed(() => props.modelValue);
    const modelValue = ref<string[]>([]);
    watch(
      () => sourceValue.value,
      (v: string) => {
        modelValue.value =
          "string" === typeof v
            ? v
                .trim()
                .split("\n")
                .map((v: string) => v.trim())
                .filter((v: string) => v.length > 0)
            : [];
      },
      { immediate: true },
    );
    watch(
      () => modelValue.value,
      (v: string[]) => {
        emit("update:modelValue", v.join("\n"));
      },
    );
    const passedProps = computed(() => props);
    const defaults = useDefaults(passedProps.value, "VCombobox");
    const updatedEmitters = computed(() => {
      const ret: any = {};
      Object.keys({ ...VCombobox.emits }).forEach((evnt) => {
        const key = `on${capitalize(evnt)}`;
        ret[key] = (e: any) => emit(evnt, e);
      });
      ret["onUpdate:modelValue"] = (v: string[]) => {
        modelValue.value = v;
      };
      return ret;
    });
    const updatedProps = computed(() => ({
      ...defaults,
      multiple: true,
      modelValue: modelValue.value,
      chips: true,
      closableChips: true,
      ...updatedEmitters.value,
    }));
    return () => h(VCombobox, updatedProps.value);
  },
});

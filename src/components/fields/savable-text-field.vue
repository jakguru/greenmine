<script lang="ts">
import { computed, defineComponent, ref, h } from "vue";
import { VTextField } from "vuetify/components/VTextField";
import { useDefaults } from "vuetify";
import { capitalize } from "@/utils/formatting";

export default defineComponent({
  name: "VSaveableTextField",
  props: { ...VTextField.props },
  emits: Object.keys({ ...VTextField.emits }),
  setup(props, { slots, emit }) {
    const passedProps = computed(() => props);
    const defaults = useDefaults(passedProps.value, "VTextField");
    // @ts-ignore
    const modelValue = ref(props.modelValue);
    const updatedEmitters = computed(() => {
      const ret: any = {};
      Object.keys({ ...VTextField.emits }).forEach((evnt) => {
        const key = `on${capitalize(evnt)}`;
        ret[key] = (e: any) => emit(evnt, e);
      });
      ret["onUpdate:modelValue"] = (e: any) => {
        modelValue.value = e;
      };
      ret["onKeyup"] = (e: KeyboardEvent) => {
        if (e.key === "Enter") {
          e.preventDefault();
          emit("update:modelValue", modelValue.value);
        }
      };
      ret["onClick:append-inner"] = () => {
        emit("update:modelValue", modelValue.value);
      };
      return ret;
    });
    const updatedProps = computed(() => ({
      ...defaults,
      "append-inner-icon": "mdi-content-save",
      ...updatedEmitters.value,
    }));
    return () =>
      h(
        VTextField,
        {
          ...updatedProps.value,
          class: "v-savable-text-field",
        },
        slots,
      );
  },
});
</script>

<style lang="scss">
.v-savable-text-field {
  input:focus,
  input:active {
    opacity: 1;
  }
}
</style>

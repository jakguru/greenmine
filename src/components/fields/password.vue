<script lang="ts">
import { computed, defineComponent, ref, h } from "vue";
import { VTextField } from "vuetify/components/VTextField";
import { useDefaults } from "vuetify";
import { capitalize } from "@/utils/formatting";

export default defineComponent({
  name: "VPasswordField",
  props: { ...VTextField.props },
  emits: Object.keys({ ...VTextField.emits }),
  setup(props, { slots, emit }) {
    const passwordFieldType = ref("password");
    const passwordFieldTypeIcon = computed(() =>
      passwordFieldType.value === "password"
        ? "mdi-eye-lock-open-outline"
        : "mdi-eye-off-outline",
    );
    const togglePasswordFieldType = () => {
      passwordFieldType.value =
        passwordFieldType.value === "password" ? "text" : "password";
    };
    const passedProps = computed(() => props);
    const defaults = useDefaults(passedProps.value, "VTextField");
    const updatedEmitters = computed(() => {
      const ret: any = {};
      Object.keys({ ...VTextField.emits }).forEach((evnt) => {
        const key = `on${capitalize(evnt)}`;
        ret[key] = (e: any) => emit(evnt, e);
      });
      ret["onClick:append-inner"] = togglePasswordFieldType;
      return ret;
    });
    const updatedProps = computed(() => ({
      ...defaults,
      type: passwordFieldType.value,
      "append-inner-icon": passwordFieldTypeIcon.value,
      ...updatedEmitters.value,
    }));
    return () =>
      h(
        VTextField,
        {
          ...updatedProps.value,
          class: "v-password-field",
        },
        slots,
      );
  },
});
</script>

<style lang="scss">
.v-password-field {
  input:focus,
  input:active {
    opacity: 1;
  }
}
</style>

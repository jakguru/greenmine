<template>
  <v-text-field v-bind="textFieldProps">
    <template #prepend-inner>
      <v-sheet height="24" width="24" :color="color" />
    </template>
    <template #append-inner>
      <v-menu
        v-model="showColorPicker"
        offset-y
        :close-on-content-click="false"
      >
        <template #activator="{ props }">
          <v-btn
            v-bind="props"
            size="small"
            icon="mdi-palette"
            density="comfortable"
            @click="openColorPicker"
          />
        </template>
        <v-card color="background">
          <v-color-picker v-bind="colorPickerProps" />
        </v-card>
      </v-menu>
    </template>
  </v-text-field>
</template>

<script lang="ts">
import { defineComponent, computed, ref } from "vue";
import { VTextField } from "vuetify/components/VTextField";
import { useDefaults } from "vuetify";
import { capitalize } from "@/utils/formatting";

export default defineComponent({
  name: "VColorField",
  props: { ...VTextField.props },
  emits: Object.keys({ ...VTextField.emits }),
  setup(props, { emit }) {
    const passedProps = computed(() => props);
    const defaults = useDefaults(passedProps.value, "VTextField");
    // @ts-ignore
    const modelValue = ref(props.modelValue);
    const showColorPicker = ref(false);
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
      ret["onFocus"] = (e: FocusEvent) => {
        emit("focus", e);
        showColorPicker.value = true;
      };
      return ret;
    });
    const textFieldProps = computed(() => ({
      ...defaults,
      ...updatedEmitters.value,
      class: "v-savable-text-field",
      readonly: true,
    }));
    const colorPickerProps = computed(() => ({
      modelValue: modelValue.value,
      "onUpdate:modelValue": (val: string) => {
        modelValue.value = val;
        emit("update:modelValue", val);
      },
      mode: "hex" as const,
      modes: ["hex"] as const,
      showSwatches: true,
      // @ts-ignore
      disabled: props.disabled,
    }));
    const openColorPicker = (e?: MouseEvent) => {
      if (e) {
        e.preventDefault();
        e.stopPropagation();
        e.stopImmediatePropagation();
      }
      showColorPicker.value = true;
    };
    const color = computed({
      get: () => modelValue.value,
      set: (val) => {
        modelValue.value = val;
        emit("update:modelValue", val);
      },
    });
    return {
      textFieldProps,
      showColorPicker,
      openColorPicker,
      color,
      colorPickerProps,
    };
  },
});
</script>

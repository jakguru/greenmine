<template>
  <v-text-field v-bind="textFieldProps" ref="displayField">
    <template #append-inner>
      <v-menu
        v-model="showMenu"
        offset-y
        :close-on-content-click="false"
        :target="displayField || undefined"
      >
        <template #activator="{ props }">
          <v-btn
            v-bind="props"
            size="small"
            icon="mdi-menu-down"
            density="comfortable"
            variant="text"
            @click="openMenu"
          />
        </template>
        <v-card color="background" width="300">
          <v-container>
            <v-row>
              <v-col cols="12">
                <v-text-field
                  v-model="search"
                  :label="$t('label.multiselect.filter.label')"
                  density="compact"
                />
              </v-col>
            </v-row>
          </v-container>
          <v-virtual-scroll :height="250" :items="filteredItems">
            <template #default="{ item }">
              <v-list-item :title="item.label">
                <template #prepend>
                  <v-checkbox
                    v-model="selections"
                    :value="item.value"
                    hide-details
                  />
                </template>
              </v-list-item>
            </template>
          </v-virtual-scroll>
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
import { useI18n } from "vue-i18n";

import type { PropType } from "vue";
import type { SelectableListItem } from "@/friday";

export default defineComponent({
  name: "VAbbreviatedMultiSelect",
  props: {
    ...VTextField.props,
    items: {
      type: Array as PropType<
        SelectableListItem<number>[] | SelectableListItem<string>[]
      >,
      required: true,
    },
  },
  emits: Object.keys({ ...VTextField.emits }),
  setup(props, { emit }) {
    const displayField = ref<VTextField | null>(null);
    const { t } = useI18n();
    const passedProps = computed(() => props);
    const defaults = useDefaults(passedProps.value, "VTextField");
    // @ts-ignore
    const modelValue = ref(props.modelValue);
    const showMenu = ref(false);
    const updatedEmitters = computed(() => {
      const ret: any = {};
      Object.keys({ ...VTextField.emits }).forEach((evnt) => {
        const key = `on${capitalize(evnt)}`;
        ret[key] = (e: any) => emit(evnt, e);
      });
      // ret["onUpdate:modelValue"] = (e: any) => {
      //   modelValue.value = e;
      // };
      ret["onClick:clear"] = (e?: MouseEvent) => {
        if (e) {
          e.preventDefault();
          e.stopPropagation();
          e.stopImmediatePropagation();
        }
        modelValue.value = [];
        emit("update:modelValue", modelValue.value);
      };
      ret["onKeyup"] = (e: KeyboardEvent) => {
        if (e.key === "Enter") {
          e.preventDefault();
          emit("update:modelValue", modelValue.value);
        }
      };
      ret["onFocus"] = (e: FocusEvent) => {
        emit("focus", e);
        showMenu.value = true;
      };
      return ret;
    });
    const textToShow = computed(() => {
      switch (modelValue.value.length) {
        case 0:
          return t("labels.multiselect.selected.none");
        case 1:
          return t("labels.multiselect.selected.one");
        default:
          return t("labels.multiselect.selected.more", {
            count: modelValue.value.length,
          });
      }
    });
    const textFieldProps = computed(() => ({
      ...defaults,
      ...updatedEmitters.value,
      class: "v-savable-text-field",
      readonly: true,
      modelValue: textToShow.value,
    }));
    const openMenu = (e?: MouseEvent) => {
      if (e) {
        e.preventDefault();
        e.stopPropagation();
        e.stopImmediatePropagation();
      }
      showMenu.value = true;
    };
    const search = ref("");
    const items = computed<SelectableListItem[]>(
      // @ts-ignore
      () => props.items as any as SelectableListItem[],
    );
    const filteredItems = computed(() =>
      [...items.value].filter(
        (i) =>
          !search.value ||
          i.label.toLowerCase().includes(search.value.toLowerCase()),
      ),
    );
    const selections = computed({
      get: () => modelValue.value,
      set: (val: any) => {
        modelValue.value = val;
        emit("update:modelValue", modelValue.value);
      },
    });
    return {
      textFieldProps,
      showMenu,
      openMenu,
      displayField,
      search,
      filteredItems,
      selections,
    };
  },
});
</script>

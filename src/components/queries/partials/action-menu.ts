import { defineComponent, computed, h } from "vue";
import { VCard } from "vuetify/components/VCard";
import { VSheet } from "vuetify/components/VSheet";
import { VProgressCircular } from "vuetify/components/VProgressCircular";
import type { PropType } from "vue";
import type { Item } from "@/friday";

export interface ActionMenuItem {
  component: ReturnType<typeof defineComponent> | string | ReturnType<typeof h>;
  props?: Record<string, unknown>;
}

export interface GetActionItemsMethod {
  (
    items: Item[],
    onDone: () => void,
    onFilterTo: () => void,
  ): ActionMenuItem[] | Promise<ActionMenuItem[]>;
}

export const ActionMenu = defineComponent({
  name: "ActionMenu",
  props: {
    items: {
      type: Array as PropType<ActionMenuItem[]>,
      required: true,
    },
    loading: {
      type: Boolean,
      default: false,
    },
  },
  setup(props) {
    const items = computed(() => props.items);
    const loading = computed(() => props.loading);
    const actionMenuItemToHyperscript = (item: ActionMenuItem) => {
      return item.component;
    };
    const children = computed(() =>
      loading.value
        ? h(
            VSheet,
            {
              width: 200,
              height: 200,
              class: "d-flex justify-center align-center",
            },
            [
              h(VProgressCircular, {
                indeterminate: true,
                color: "accent",
                size: 64,
              }),
            ],
          )
        : items.value.map((item) => actionMenuItemToHyperscript(item)),
    );
    return () =>
      h(
        VCard,
        {
          color: "background",
          width: "200",
          class: "action-menu",
        },
        children.value,
      );
  },
});

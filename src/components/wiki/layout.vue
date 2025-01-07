<template>
  <v-sheet v-bind="sheetProps">
    <v-layout v-bind="layoutProps">
      <v-navigation-drawer v-bind="sidebarBindings">
        <TableOfContentsList :toc="toc" />
      </v-navigation-drawer>
    </v-layout>
  </v-sheet>
</template>

<script lang="ts">
import { defineComponent, ref, computed, watch } from "vue";
import { useDisplay } from "vuetify";
import { TableOfContentsList } from "./tableOfContentsList";

import type { PropType } from "vue";
import type { WikiTableOfContents } from "@/friday";

export default defineComponent({
  name: "WikiLayout",
  components: {
    TableOfContentsList,
  },
  props: {
    toc: {
      type: Array as PropType<WikiTableOfContents[]>,
      required: true,
    },
  },
  setup() {
    const { smAndDown, height } = useDisplay();
    const sheetProps = computed(() => ({
      width: "100%",
      color: "transparent" as const,
      style: {
        position: "relative" as const,
      },
    }));
    const layoutProps = computed(() => ({
      minHeight: Math.min(height.value, 768),
    }));
    const sidebarOpen = ref(false);
    const sidebarBindings = computed(() => ({
      absolute: true,
      color: "surface" as const,
      location: "right" as const,
      modelValue: sidebarOpen.value,
      "onUpdate:modelValue": (v: boolean) => {
        sidebarOpen.value = v;
      },
      class: ["workflow-management-sidebar"],
      style: {
        height: "100%",
        top: 0,
        bottom: 0,
      },
      permanent: true,
      app: false,
      elevation: sidebarOpen.value ? 5 : 0,
      width: 256,
    }));
    watch(
      () => smAndDown.value,
      (is) => {
        if (is) {
          sidebarOpen.value = false;
        } else {
          sidebarOpen.value = true;
        }
      },
      {
        immediate: true,
      },
    );
    return {
      sheetProps,
      layoutProps,
      sidebarBindings,
    };
  },
});
</script>

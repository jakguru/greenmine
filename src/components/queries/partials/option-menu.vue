<template>
  <div class="queries-option-menu">
    <v-menu v-model="showingMenu" :close-on-content-click="false">
      <template #activator="{ props }">
        <v-btn-group
          divided
          :base-color="color"
          density="compact"
          style="height: 24px"
        >
          <v-btn v-bind="props" size="x-small">
            <v-icon v-if="icon" class="me-2">{{ icon }}</v-icon>
            <span>{{ title }}</span>
            <v-badge
              v-if="showCount"
              inline
              color="info"
              class="ms-2"
              style="height: 16px"
            >
              <template #badge>
                <small>
                  {{ count }}
                </small>
              </template>
            </v-badge>
          </v-btn>
          <v-btn v-bind="props" icon="mdi-menu-down" size="x-small" />
        </v-btn-group>
      </template>
      <v-card :color="surfaceColor">
        <slot name="content" :close="close"></slot>
      </v-card>
    </v-menu>
  </div>
</template>

<script lang="ts">
import { defineComponent, ref, computed } from "vue";
import { useSystemSurfaceColor } from "@/utils/app";

import type { PropType } from "vue";

export default defineComponent({
  name: "QueriesOptionMenu",
  components: {},
  props: {
    color: {
      type: String,
      default: "accent",
    },
    icon: {
      type: String as PropType<string | undefined>,
      default: undefined,
    },
    title: {
      type: String,
      required: true,
    },
    count: {
      type: [String, Number] as PropType<string | number | undefined>,
      default: undefined,
    },
  },
  setup(props) {
    const count = computed(() => props.count);
    const showingMenu = ref(false);
    const surfaceColor = useSystemSurfaceColor();
    const showCount = computed(() => "undefined" !== typeof count.value);
    const close = () => {
      showingMenu.value = false;
    };
    return {
      showingMenu,
      surfaceColor,
      close,
      showCount,
    };
  },
});
</script>

<style lang="scss">
.queries-option-menu {
  .v-badge__badge {
    height: 16px;
  }
}
</style>

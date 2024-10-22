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
      <v-card color="surface-darken-1" min-width="300">
        <slot name="top" :close="close" :submit="submit"></slot>
        <slot name="content" :close="close" :submit="submit"></slot>
        <v-divider />
        <v-toolbar color="transparent" density="compact">
          <v-toolbar-items class="mr-auto">
            <slot name="bottom-actions" :close="close" :submit="submit"></slot>
          </v-toolbar-items>
          <v-toolbar-items class="ml-auto">
            <v-btn
              variant="text"
              color="secondary"
              :loading="submitting"
              :disabled="!dirty"
              @click="submit"
            >
              <v-icon>mdi-check</v-icon>
              <span class="ms-2">{{ $t("labels.apply") }}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
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
    submitting: {
      type: Boolean,
      default: false,
    },
    dirty: {
      type: Boolean,
      default: false,
    },
  },
  emits: ["submit"],
  setup(props, { emit }) {
    const count = computed(() => props.count);
    const showingMenu = ref(false);
    const surfaceColor = useSystemSurfaceColor();
    const showCount = computed(() => "undefined" !== typeof count.value);
    const close = () => {
      showingMenu.value = false;
    };
    const submit = () => {
      emit("submit");
      close();
    };
    return {
      showingMenu,
      surfaceColor,
      showCount,
      close,
      submit,
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

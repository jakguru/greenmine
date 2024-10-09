<template>
  <div class="d-flex justify-center align-center">
    <v-switch v-model="themeIsDark" hide-details loading>
      <template #loader>
        <v-avatar :color="themeIsDark ? 'background' : 'on-primary'" size="20">
          <v-icon
            size="14"
            :color="themeIsDark ? 'on-background' : 'primary'"
            >{{ themeIcon }}</v-icon
          >
        </v-avatar>
      </template>
    </v-switch>
  </div>
</template>

<script lang="ts">
import { computed, inject } from "vue";
import { useTheme } from "vuetify";
import type { LocalStorageService, BusService } from "@jakguru/vueprint";
export default {
  name: "ThemeToggle",
  setup() {
    const ls = inject<LocalStorageService>("ls");
    const theme = useTheme();
    const bus = inject<BusService>("bus");
    const themeIcon = computed(() =>
      theme.global.name.value === "greenmine-light"
        ? "mdi-lightbulb-on"
        : "mdi-lightbulb-off",
    );
    const themeIsDark = computed({
      get: () => theme.global.name.value === "greenmine-dark",
      set: (val) => {
        const value = val ? "greenmine-dark" : "greenmine-light";
        if (theme.global.name.value !== value) {
          theme.global.name.value = value;
          if (ls) {
            ls.set("theme", theme.global.name.value);
          }
          if (bus) {
            bus.emit(
              "theme:changed",
              { crossTab: true },
              theme.global.name.value,
            );
          }
        }
      },
    });
    return {
      themeIcon,
      themeIsDark,
    };
  },
};
</script>

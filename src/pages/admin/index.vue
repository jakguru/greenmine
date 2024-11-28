<template>
  <v-container fluid>
    <v-card min-height="100" color="surface">
      <v-toolbar color="transparent" density="compact">
        <v-toolbar-title class="font-weight-bold d-flex align-center" tag="h1">
          <v-icon size="20" class="me-3" style="position: relative; top: -2px"
            >mdi-cog</v-icon
          >
          {{ $t("pages.admin.title") }}
        </v-toolbar-title>
      </v-toolbar>
      <v-divider />
      <template
        v-for="(item, i) in administrationNav"
        :key="`admin-nav-item-${i}`"
      >
        <v-list-item v-bind="item" :id="`admin-nav-item-${i}`" />
      </template>
    </v-card>
  </v-container>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { useAdminNav } from "@/constants/nav.ts";

export default defineComponent({
  name: "AdminIndex",
  props: {
    noConfigurationData: {
      type: Boolean,
      required: true,
    },
  },
  setup() {
    const administrationNav = useAdminNav();
    return {
      administrationNav,
    };
  },
});
</script>

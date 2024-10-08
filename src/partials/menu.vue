<template>
  <v-card :color="color" width="320" min-height="100">
    <v-container :fluid="true">
      <v-row>
        <v-col v-for="(item, i) in items" :key="`menu-nav-item-${i}`" cols="4">
          <MenuLink
            v-if="item.to"
            :to="item.to"
            :icon="item.icon"
            :label="item.label"
          />
          <MenuExternalLink
            v-if="item.href"
            :to="item.href"
            :icon="item.icon"
            :label="item.label"
          />
        </v-col>
      </v-row>
    </v-container>
  </v-card>
</template>

<script lang="ts">
import { defineComponent, computed } from "vue";
import { MenuLink, MenuExternalLink } from "@/components/menu";
import { useI18n } from "vue-i18n";

import type {
  RouteLocationAsRelativeGeneric,
  RouteLocationAsPathGeneric,
} from "vue-router";

interface MenuItem {
  to?: string | RouteLocationAsPathGeneric | RouteLocationAsRelativeGeneric;
  href?: string;
  icon: string;
  label: string;
}

export default defineComponent({
  name: "PartialMenu",
  components: {
    MenuLink,
    MenuExternalLink,
  },
  props: {
    color: {
      type: String,
      required: true,
    },
  },
  setup() {
    const { t } = useI18n();
    const items = computed<MenuItem[]>(() => [
      {
        to: {
          name: "home",
        },
        icon: "mdi-home",
        label: t("pages.home.title"),
      },
      {
        to: {
          name: "projects",
        },
        icon: "mdi-code-block-braces",
        label: t("pages.projects.title"),
      },
      {
        href: "https://www.redmine.org/guide",
        icon: "mdi-help-circle",
        label: t("pages.help.title"),
      },
    ]);
    return { items };
  },
});
</script>

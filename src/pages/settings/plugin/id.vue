<template>
  <v-container fluid :class="!isFriday ? 'fill-height' : ''">
    <div
      v-if="!isFriday"
      class="w-100 h-100 d-flex justify-center align-center"
    >
      <v-empty-state
        :headline="$t('pages.settings-plugin-id.content.incompatible.headline')"
        :title="$t('pages.settings-plugin-id.content.incompatible.title')"
        :text="$t('pages.settings-plugin-id.content.incompatible.text')"
        :image="fourOhSixImage"
      ></v-empty-state>
    </div>
    <v-card v-else min-height="100" color="surface">
      <v-toolbar color="transparent" density="compact">
        <v-toolbar-title class="font-weight-bold d-flex align-center" tag="h1">
          <v-icon size="20" class="me-3" style="position: relative; top: -2px"
            >mdi-puzzle</v-icon
          >
          {{
            $t("pages.settings-plugin-id.specificTitle", {
              plugin: plugin.name,
            })
          }}
        </v-toolbar-title>
      </v-toolbar>
      <v-divider />
    </v-card>
  </v-container>
</template>

<script lang="ts">
import { defineComponent, computed, onMounted } from "vue";
import fourOhSixImage from "@/assets/images/406.svg?url";
import { useHead } from "@unhead/vue";
import { useI18n } from "vue-i18n";

import type { PropType } from "vue";
import type { PluginData } from "@/redmine";

export default defineComponent({
  name: "SettingsPluginId",
  props: {
    plugin: {
      type: Object as PropType<PluginData>,
      required: true,
    },
    settings: {
      type: Object as PropType<Record<string, unknown>>,
      required: true,
    },
  },
  setup(props) {
    const plugin = computed(() => props.plugin);
    const settings = computed(() => props.settings);
    const isFriday = computed(() => plugin.value.id === "friday");
    const { t } = useI18n({ useScope: "global" });
    onMounted(() => {
      useHead({
        title: t("pages.settings-plugin-id.specificTitle", {
          plugin: plugin.value.name,
        }),
      });
    });
    return {
      isFriday,
      fourOhSixImage,
    };
  },
});
</script>

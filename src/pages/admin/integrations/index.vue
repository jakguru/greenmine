<template>
  <v-container fluid>
    <v-card min-height="100" color="surface">
      <v-toolbar color="transparent" density="compact">
        <v-toolbar-title class="font-weight-bold d-flex align-center" tag="h1">
          <v-icon size="20" class="me-3" style="position: relative; top: -2px"
            >mdi-relation-many-to-many</v-icon
          >
          {{ $t("pages.admin-integrations.title") }}
        </v-toolbar-title>
      </v-toolbar>
      <v-divider />
      <v-breadcrumbs v-bind="breadcrumbsBindings" />
      <v-divider />
      <v-container fluid>
        <v-row justify="start">
          <v-col cols="12" sm="4" md="2">
            <v-card
              elevation="5"
              color="background"
              :to="{ name: 'admin-integrations-monday' }"
            >
              <v-card-text class="pa-3">
                <v-img :src="iconMonday" :aspect-ratio="1" />
              </v-card-text>
              <v-card-title class="text-center">
                <span>Monday</span>
              </v-card-title>
            </v-card>
          </v-col>
          <v-col cols="12" sm="4" md="2">
            <v-card
              elevation="5"
              color="background"
              :to="{ name: 'admin-integrations-github' }"
            >
              <v-card-text class="pa-3">
                <v-img :src="iconGithub" :aspect-ratio="1" />
              </v-card-text>
              <v-card-title class="text-center">
                <span>GitHub</span>
              </v-card-title>
            </v-card>
          </v-col>
          <v-col cols="12" sm="4" md="2">
            <v-card
              elevation="5"
              color="background"
              :to="{ name: 'admin-integrations-gitlab' }"
            >
              <v-card-text class="pa-3">
                <v-img :src="iconGitLab" :aspect-ratio="1" />
              </v-card-text>
              <v-card-title class="text-center">
                <span>GitLab</span>
              </v-card-title>
            </v-card>
          </v-col>
          <v-col cols="12" sm="4" md="2">
            <v-card
              elevation="5"
              color="background"
              :to="{ name: 'admin-integrations-pagerduty' }"
            >
              <v-card-text class="pa-3">
                <v-img :src="iconPagerduty" :aspect-ratio="1" />
              </v-card-text>
              <v-card-title class="text-center">
                <span>PagerDuty</span>
              </v-card-title>
            </v-card>
          </v-col>
          <v-col cols="12" sm="4" md="2">
            <v-card
              elevation="5"
              color="background"
              :to="{ name: 'admin-integrations-sentry' }"
            >
              <v-card-text class="pa-3">
                <v-img :src="iconSentry" :aspect-ratio="1" />
              </v-card-text>
              <v-card-title class="text-center">
                <span>Sentry</span>
              </v-card-title>
            </v-card>
          </v-col>
          <v-col cols="12" sm="4" md="2">
            <v-card
              elevation="5"
              color="background"
              :to="{ name: 'admin-integrations-slack' }"
            >
              <v-card-text class="pa-3">
                <v-img :src="iconSlack" :aspect-ratio="1" />
              </v-card-text>
              <v-card-title class="text-center">
                <span>Slack</span>
              </v-card-title>
            </v-card>
          </v-col>
          <v-col cols="12" sm="4" md="2">
            <v-card
              elevation="5"
              color="background"
              :to="{ name: 'admin-integrations-webhooks' }"
            >
              <v-card-text class="pa-3">
                <v-img :src="iconWebhooks" :aspect-ratio="1" />
              </v-card-text>
              <v-card-title class="text-center">
                <span v-text="$t('labels.webhooks.title')" />
              </v-card-title>
            </v-card>
          </v-col>
        </v-row>
      </v-container>
    </v-card>
  </v-container>
</template>

<script lang="ts">
import { defineComponent, computed } from "vue";
import { useI18n } from "vue-i18n";
import iconGithub from "@/assets/images/icon-github.svg?url";
import iconGitLab from "@/assets/images/icon-gitlab.svg?url";
import iconPagerduty from "@/assets/images/icon-pagerduty.svg?url";
import iconSentry from "@/assets/images/icon-sentry.svg?url";
import iconSlack from "@/assets/images/icon-slack.svg?url";
import iconWebhooks from "@/assets/images/icon-webhooks.svg?url";
import iconMonday from "@/assets/images/icon-monday.svg?url";

export default defineComponent({
  name: "AdminIntegrationsIndex",
  setup() {
    const { t } = useI18n({ useScope: "global" });
    const breadcrumbsBindings = computed(() => ({
      items: [
        { title: t("pages.admin.title"), to: { name: "admin" } },
        {
          title: t("pages.admin-integrations.title"),
        },
      ],
    }));
    return {
      breadcrumbsBindings,
      iconGithub,
      iconGitLab,
      iconPagerduty,
      iconSentry,
      iconSlack,
      iconWebhooks,
      iconMonday,
    };
  },
});
</script>

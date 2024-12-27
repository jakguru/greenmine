<template>
  <v-container fluid class="page-activities-index">
    <v-card min-height="100" color="surface">
      <v-toolbar color="transparent" density="compact">
        <v-toolbar-title class="font-weight-bold d-flex align-center" tag="h1">
          {{ $t(`pages.${String($route.name)}.title`) }}
        </v-toolbar-title>
      </v-toolbar>
      <ActivityTimeline
        :form-authenticity-token="formAuthenticityToken"
        :events="events"
        :date-from="dateFrom"
        :date-to="dateTo"
        :event-types="eventTypes"
        :scope="scope"
      />
    </v-card>
  </v-container>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { useRoute } from "vue-router";
import { useSystemSurfaceColor, useSystemAccentColor } from "@/utils/app";
import { formatDuration } from "@/utils/formatting";
import iconGitLab from "@/assets/images/icon-gitlab.svg?url";
import iconGitHub from "@/assets/images/icon-github.svg?url";
import iconMonday from "@/assets/images/icon-monday.svg?url";
import defaultProjectAvatar from "@/assets/images/default-project-avatar.svg?url";
import ActivityTimeline from "@/components/activities/timeline.vue";

import type { PropType } from "vue";
import type { SelectableListItem, ActivityEvent } from "@/friday";

export default defineComponent({
  name: "ActivitiesIndex",
  components: {
    ActivityTimeline,
  },
  props: {
    formAuthenticityToken: {
      type: String,
      required: true,
    },
    events: {
      type: Array as PropType<ActivityEvent[]>,
      required: true,
    },
    dateFrom: {
      type: String,
      required: true,
    },
    dateTo: {
      type: String,
      required: true,
    },
    eventTypes: {
      type: Array as PropType<SelectableListItem<string>[]>,
      required: true,
    },
    scope: {
      type: Array as PropType<string[]>,
      required: true,
    },
  },
  setup() {
    const route = useRoute();
    const surfaceColor = useSystemSurfaceColor();
    const accentColor = useSystemAccentColor();
    const isCurrentRoute = (names: string[]) => {
      return names.includes(route.name as string);
    };
    return {
      surfaceColor,
      accentColor,
      defaultProjectAvatar,
      iconGitLab,
      iconGitHub,
      iconMonday,
      formatDuration,
      isCurrentRoute,
    };
  },
});
</script>

<style lang="scss">
.page-activities-index {
  .project-hero {
    position: relative;
    display: flex;
    flex-direction: column;

    &:before {
      content: "";
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 50%;
      background-image: var(--project-hero-background);
      background-size: cover;
      opacity: 0.5;
    }

    > div {
      position: relative;
      z-index: 1;
      flex-grow: 1;
      height: 50%;
      width: 100%;
      display: flex;
      align-items: center;
      padding: 0 16px;

      &.bottom {
        align-items: flex-end;
      }

      > .v-avatar {
        border: solid 2px;
        transform: translateY(75px);
      }

      @media (max-width: 600px) {
        justify-content: center;
        > .v-avatar {
          transform: translateY(30px);
        }
      }
    }
  }

  .v-row {
    &.with-dividing-border {
      @media (min-width: 600px) and (max-width: 959px) {
        > div:not(:first-child):not(:last-child) {
          border-right: 1px solid
            rgba(var(--v-theme-on-surface), var(--v-border-opacity));
        }
      }
      @media (min-width: 960px) {
        > div:not(:last-child) {
          border-right: 1px solid
            rgba(var(--v-theme-on-surface), var(--v-border-opacity));
        }
      }
    }
  }

  .v-card.overflow-y-visible {
    overflow: visible !important;
    position: relative;
  }

  .project-card-label {
    position: absolute;
    top: -10px;
    z-index: 3;
    background-color: rgb(var(--v-theme-surface));
    opacity: 1;
    padding: 0 8px;
  }
}
</style>

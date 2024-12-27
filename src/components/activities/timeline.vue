<template>
  <v-container fluid>
    <v-row>
      <v-col cols="12" md="6" xxl="2">
        <v-text-field
          v-model="dateFromModelValue"
          type="date"
          :label="$t('labels.from')"
          hide-details
          :max="dateFromMax"
          clearable
        />
      </v-col>
      <v-col cols="12" md="6" xxl="2">
        <v-text-field
          v-model="dateToModelValue"
          type="date"
          :label="$t('labels.to')"
          hide-details
          :min="dateFromModelValue"
          :max="dateToMax"
          clearable
        />
      </v-col>
      <v-col cols="12" xxl="8">
        <v-autocomplete
          v-model="scopeModelValue"
          :items="eventTypes"
          item-title="label"
          hide-details
          multiple
          chips
          clearable
          deletable-chips
          :label="$t('labels.events')"
        />
      </v-col>
    </v-row>
    <v-timeline density="compact" side="end">
      <template
        v-for="(dayvents, date) in eventsGroupedByDays"
        :key="`events-on-date-${date}`"
      >
        <v-timeline-item class="mb-6" hide-dot>
          <span>{{ formatDate(date) }}</span>
        </v-timeline-item>
        <v-timeline-item
          v-for="(event, index) in dayvents"
          :key="`event-${index}-on-date-${date}`"
          :dot-color="getEventColor(event.type)"
          class="mb-12"
          fill-dot
        >
          <template #icon>
            <v-tooltip :text="event.author?.name || $t('label.unknown')">
              <template #activator="{ props }">
                <img :src="getEventUserIcon(event)" v-bind="props" />
              </template>
            </v-tooltip>
          </template>
          <v-card color="background" class="w-100 flex-grow-1">
            <v-toolbar
              :color="getEventColor(event.type)"
              density="compact"
              class="pe-4"
            >
              <div class="h-100 d-flex align-center ms-4">
                <img :src="getEventIcon(event.type)" />
              </div>
              <v-toolbar-title class="text-subtitle">
                {{ event.title }}
              </v-toolbar-title>
              <small
                class="h-100 d-flex align-center ms-4"
                v-text="formatTime(event.datetime)"
              />
            </v-toolbar>
            <v-divider v-if="event.description" />
            <v-card-text v-if="event.description">
              <RenderMarkdown :raw="event.description" />
            </v-card-text>
            <v-divider v-if="event.description && event.url" />
            <v-card-actions v-if="event.url">
              <v-spacer />
              <v-btn
                variant="elevated"
                :color="accentColor"
                size="x-small"
                class="mx-1 my-2"
                height="24px"
                style="position: relative; top: 1px"
                :href="event.url"
              >
                <span>{{
                  $t("actions.view", { what: getEventModel(event.type) })
                }}</span>
              </v-btn>
            </v-card-actions>
          </v-card>
        </v-timeline-item>
      </template>
    </v-timeline>
  </v-container>
</template>

<script lang="ts">
import {
  defineComponent,
  computed,
  ref,
  inject,
  onMounted,
  onBeforeUnmount,
} from "vue";
import { useI18n } from "vue-i18n";
import { useRoute, useRouter } from "vue-router";
import { DateTime } from "luxon";
import { useSystemAccentColor } from "@/utils/app";
import { formatDate, formatTime } from "@/utils/formatting";
import { RenderMarkdown } from "@/components/rendering";

import iconAttachment from "@/assets/images/attachment.png?url";
import iconChangeset from "@/assets/images/changeset.png?url";
import iconDocument from "@/assets/images/document.png?url";
import iconIssue from "@/assets/images/ticket.png?url";
import iconIssueEdit from "@/assets/images/ticket_edit.png?url";
import iconIssueClosed from "@/assets/images/ticket_checked.png?url";
import iconIssueNote from "@/assets/images/ticket_note.png?url";
import iconMessage from "@/assets/images/message.png?url";
import iconReply from "@/assets/images/comments.png?url";
import iconNews from "@/assets/images/news.png?url";
import iconProject from "@/assets/images/projects.png?url";
import iconTimeEntry from "@/assets/images/time.png?url";
import iconWikiPage from "@/assets/images/wiki_edit.png?url";
import iconRemoteGitCommit from "@/assets/images/iconRemoteGitCommit.svg?url";
import iconRemoteGitMergeRequestOpened from "@/assets/images/iconRemoteGitMergeRequestOpened.svg?url";
import iconRemoteGitMergeRequestClosed from "@/assets/images/iconRemoteGitMergeRequestClosed.svg?url";
import iconRemoteGitMergeRequestMerged from "@/assets/images/iconRemoteGitMergeRequestMerged.svg?url";
import iconRemoteGitPipelineStarted from "@/assets/images/iconRemoteGitPipelineStarted.svg?url";
import iconRemoteGitPipelineEnded from "@/assets/images/iconRemoteGitPipelineEnded.svg?url";
import iconRemoteGitRelease from "@/assets/images/iconRemoteGitRelease.svg?url";
import iconRemoteGitTag from "@/assets/images/iconRemoteGitTag.svg?url";
import iconUnknown from "@/assets/images/help.png?url";

import type { PropType } from "vue";
import type {
  SelectableListItem,
  ActivityEvent,
  ActivityEventType,
} from "@/friday";
import type { CronService } from "@jakguru/vueprint";

export default defineComponent({
  name: "ActivityTimeline",
  components: { RenderMarkdown },
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
  setup(props) {
    const cron = inject<CronService>("cron");
    const { t } = useI18n({ useScope: "global" });
    const route = useRoute();
    const router = useRouter();
    const events = computed(() => props.events);
    const dateFrom = computed(() => props.dateFrom);
    const dateTo = computed(() => props.dateTo);
    const eventTypes = computed(() => props.eventTypes);
    const scope = computed(() => props.scope);
    const now = ref(DateTime.utc());
    const updateNow = () => {
      now.value = DateTime.utc();
    };

    const doRouteUpdate = (
      dateFrom: string | null,
      dateTo: string | null,
      scope: string[] | null,
    ) => {
      const query: any = { ...route.query };
      eventTypes.value.forEach((v) => {
        delete query[`show_${v.value}`];
      });
      if (!dateFrom) {
        delete query.from;
      } else {
        query.from = dateFrom;
      }
      if (!dateTo) {
        delete query.to;
      } else {
        query.to = dateTo;
      }
      if (scope) {
        scope.forEach((v) => {
          query[`show_${v}`] = 1;
        });
      }
      router
        .push({
          name: route.name as string,
          params: { ...route.params },
          query,
        })
        .catch(() => {});
    };

    const dateFromModelValue = computed({
      get: () => dateFrom.value,
      set: (value: string) => {
        doRouteUpdate(value, dateTo.value, scope.value);
      },
    });
    const dateToModelValue = computed({
      get: () => dateTo.value,
      set: (value: string) => {
        doRouteUpdate(dateFrom.value, value, scope.value);
      },
    });
    const scopeModelValue = computed({
      get: () => scope.value,
      set: (value: string[]) => {
        doRouteUpdate(dateFrom.value, dateTo.value, value);
      },
    });
    onMounted(() => {
      if (cron) {
        cron.$on("* * * * * *", updateNow);
      }
    });
    onBeforeUnmount(() => {
      if (cron) {
        cron.$off("* * * * * *", updateNow);
      }
    });
    const dateFromMax = computed(() => {
      const dateTimeForDateTo = DateTime.fromSQL(dateTo.value);
      if (dateTimeForDateTo < now.value) {
        return dateTimeForDateTo.toSQLDate();
      }
      return now.value.toSQLDate();
    });
    const dateToMax = computed(() => now.value.toSQLDate());

    const eventsGroupedByDays = computed(() => {
      const grouped: Record<string, ActivityEvent[]> = {};
      events.value.forEach((event) => {
        const date = DateTime.fromISO(event.datetime).toSQLDate()!;
        if (!grouped[date]) {
          grouped[date] = [];
        }
        grouped[date].push(event);
      });
      return grouped;
    });

    const eventStyles = {
      attachment: {
        icon: iconAttachment,
        color: "#FF5722",
        model: t("models.attachment"),
      },
      changeset: {
        icon: iconChangeset,
        color: "#2196F3",
        model: t("models.changeset"),
      },
      document: {
        icon: iconDocument,
        color: "#FFC107",
        model: t("models.document"),
      },
      issue: { icon: iconIssue, color: "#E91E63", model: t("models.issue") },
      "issue-edit": {
        icon: iconIssueEdit,
        color: "#9C27B0",
        model: t("models.issue"),
      },
      "issue-closed": {
        icon: iconIssueClosed,
        color: "#673AB7",
        model: t("models.issue"),
      },
      "issue-note": {
        icon: iconIssueNote,
        color: "#00BCD4",
        model: t("models.note"),
      },
      message: {
        icon: iconMessage,
        color: "#FF9800",
        model: t("models.message"),
      },
      reply: { icon: iconReply, color: "#4CAF50", model: t("models.reply") },
      news: { icon: iconNews, color: "#3F51B5", model: t("models.news") },
      project: {
        icon: iconProject,
        color: "#8BC34A",
        model: t("models.project"),
      },
      "time-entry": {
        icon: iconTimeEntry,
        color: "#CDDC39",
        model: t("models.timeEntry"),
      },
      "wiki-page": {
        icon: iconWikiPage,
        color: "#FFEB3B",
        model: t("models.wikiPage"),
      },
      "remote-git-commit": {
        icon: iconRemoteGitCommit,
        color: "#795548",
        model: t("models.remoteGitCommit"),
      },
      "remote-git-merge-request-opened": {
        icon: iconRemoteGitMergeRequestOpened,
        color: "#607D8B",
        model: t("models.remoteGitMergeRequestOpened"),
      },
      "remote-git-merge-request-closed": {
        icon: iconRemoteGitMergeRequestClosed,
        color: "#F44336",
        model: t("models.remoteGitMergeRequestClosed"),
      },
      "remote-git-merge-request-merged": {
        icon: iconRemoteGitMergeRequestMerged,
        color: "#009688",
        model: t("models.remoteGitMergeRequestMerged"),
      },
      "remote-git-pipeline-started": {
        icon: iconRemoteGitPipelineStarted,
        color: "#673AB7",
        model: t("models.remoteGitPipelineStarted"),
      },
      "remote-git-pipeline-ended": {
        icon: iconRemoteGitPipelineEnded,
        color: "#03A9F4",
        model: t("models.remoteGitPipelineEnded"),
      },
      "remote-git-release": {
        icon: iconRemoteGitRelease,
        color: "#FF5722",
        model: t("models.remoteGitRelease"),
      },
      "remote-git-tag": {
        icon: iconRemoteGitTag,
        color: "#607D8B",
        model: t("models.remoteGitTag"),
      },
      unknown: {
        icon: iconUnknown,
        color: "#9E9E9E",
        model: t("models.unknown"),
      },
    };

    const getEventStyle = (eventType: ActivityEventType) => {
      return eventStyles[eventType] || eventStyles.unknown;
    };

    const getEventColor = (eventType: ActivityEventType) => {
      return getEventStyle(eventType).color;
    };

    const getEventModel = (eventType: ActivityEventType) => {
      return getEventStyle(eventType).model;
    };

    const getEventIcon = (eventType: ActivityEventType) => {
      return getEventStyle(eventType).icon;
    };

    const getEventUserIcon = (event: ActivityEvent) => {
      if (event.author) {
        return `/users/${event.author.id}/avatar`;
      }
      return iconUnknown;
    };

    const accentColor = useSystemAccentColor();

    return {
      dateFromModelValue,
      dateToModelValue,
      scopeModelValue,
      dateFromMax,
      dateToMax,
      eventsGroupedByDays,
      formatDate,
      formatTime,
      getEventColor,
      getEventIcon,
      getEventModel,
      getEventUserIcon,
      accentColor,
    };
  },
});
</script>

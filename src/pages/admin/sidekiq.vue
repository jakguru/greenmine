<template>
  <v-container fluid>
    <v-card min-height="100" color="surface">
      <v-toolbar color="transparent" density="compact">
        <v-toolbar-title class="font-weight-bold d-flex align-center" tag="h1">
          <v-icon size="20" class="me-3" style="position: relative; top: -2px"
            >mdi-queue-first-in-last-out</v-icon
          >
          {{ $t("pages.admin-sidekiq.title") }}
        </v-toolbar-title>
      </v-toolbar>
      <v-divider />
      <v-container fluid>
        <v-row>
          <v-col cols="2">
            <v-text-field
              :model-value="stats.processed"
              readonly
              :label="$t('pages.admin-sidekiq.content.stats.processed')"
              class="text-center"
            />
          </v-col>
          <v-col cols="2">
            <v-text-field
              :model-value="stats.failed"
              readonly
              :label="$t('pages.admin-sidekiq.content.stats.failed')"
              class="text-center"
            />
          </v-col>
          <v-col cols="2">
            <v-text-field
              :model-value="busy"
              readonly
              :label="$t('pages.admin-sidekiq.content.stats.busy')"
              class="text-center"
            />
          </v-col>
          <v-col cols="2">
            <v-text-field
              :model-value="stats.scheduled_size"
              readonly
              :label="$t('pages.admin-sidekiq.content.stats.scheduled_size')"
              class="text-center"
            />
          </v-col>
          <v-col cols="2">
            <v-text-field
              :model-value="stats.retry_size"
              readonly
              :label="$t('pages.admin-sidekiq.content.stats.retry_size')"
              class="text-center"
            />
          </v-col>
          <v-col cols="2">
            <v-text-field
              :model-value="stats.enqueued"
              readonly
              :label="$t('pages.admin-sidekiq.content.stats.enqueued')"
              class="text-center"
            />
          </v-col>
        </v-row>
      </v-container>
    </v-card>
  </v-container>
</template>

<script lang="ts">
import {
  defineComponent,
  computed,
  inject,
  onMounted,
  onBeforeUnmount,
} from "vue";
import { useReloadRouteData } from "@/utils/app";
import { useRoute } from "vue-router";
// import { useI18n } from "vue-i18n";

import type { PropType } from "vue";
import type { ApiService, ToastService, CronService } from "@jakguru/vueprint";

interface Stats {
  dead_size: number;
  default_queue_latency: number;
  failed: number;
  processed: number;
  processes_size: number;
  retry_size: number;
  scheduled_size: number;
  enqueued: number;
}

interface History {
  processed: Record<string, number>;
  failed: Record<string, number>;
}

interface Weight {
  critical: number;
  default: number;
  low: number;
}

interface ProcessAttribs {
  hostname: string;
  started_at: number;
  pid: number;
  tag: string;
  concurrency: number;
  queues: string[];
  weights: Weight[];
  labels: string[];
  identity: string;
  version: string;
  embedded: boolean;
  busy: number;
  beat: number;
  quiet: string;
  rss: number;
  rtt_us: number;
}

interface Process {
  attribs: ProcessAttribs;
}

interface Queue {
  // Define properties as needed if queue objects have specific attributes
}

// interface StatsPayload {
//     stats: Stats;
//     history: History;
//     processes: Process[];
//     queues: Queue[];
// }

export default defineComponent({
  name: "AdminSidekiq",
  props: {
    stats: {
      type: Object as PropType<Stats>,
      required: true,
    },
    history: {
      type: Object as PropType<History>,
      required: true,
    },
    processes: {
      type: Array as PropType<Process[]>,
      required: true,
    },
    queues: {
      type: Array as PropType<Queue[]>,
      required: true,
    },
  },
  setup(props) {
    const processes = computed(() => props.processes);
    const busy = computed(() =>
      processes.value.reduce((acc, p) => acc + p.attribs.busy, 0),
    );
    const route = useRoute();
    const api = inject<ApiService>("api");
    const toast = inject<ToastService>("toast");
    const cron = inject<CronService>("cron");
    const reloadRouteData = useReloadRouteData(route, api, toast);
    // const { t } = useI18n({ useScope: "global" });
    const doReloadRouteData = () => reloadRouteData.call();
    onMounted(() => {
      if (cron) {
        cron.$on("* * * * *", doReloadRouteData);
      }
    });
    onBeforeUnmount(() => {
      if (cron) {
        cron.$off("* * * * *", doReloadRouteData);
      }
    });
    return {
      busy,
      routeDataLoading: reloadRouteData.loading,
      reloadRouteData: doReloadRouteData,
    };
  },
});
</script>

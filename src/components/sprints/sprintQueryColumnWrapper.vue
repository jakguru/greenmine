<template>
  <v-menu open-on-hover>
    <template #activator="{ props }">
      <div
        v-bind="props"
        style="width: 200px; display: flex; align-items: center"
      >
        <SprintQueryColumnItemSFC
          class="flex-grow-1"
          v-bind="{ ...focusSprint }"
        />
        <v-badge
          v-if="remainingSprints.length > 0"
          class="flex-grow-0"
          color="info"
          :content="`+${remainingSprints.length}`"
          inline
        />
      </div>
    </template>
    <v-card v-if="remainingSprints.length > 0" color="background">
      <SprintQueryColumnItemSFC class="w-100" v-bind="focusSprint" />
      <template v-for="sprint in remainingSprints" :key="sprint.id">
        <SprintQueryColumnItemSFC class="w-100" v-bind="sprint" />
      </template>
    </v-card>
  </v-menu>
</template>

<script lang="ts">
import {
  defineComponent,
  inject,
  computed,
  ref,
  onMounted,
  onBeforeUnmount,
} from "vue";
import { DateTime } from "luxon";
import SprintQueryColumnItemSFC from "./sprintQueryColumnItem.vue";
import type { PropType } from "vue";
import type { CronService } from "@jakguru/vueprint";
import type { SprintQueryColumnItem } from "@/friday";

export default defineComponent({
  name: "SprintQueryColumnWrapper",
  components: {
    SprintQueryColumnItemSFC,
  },
  props: {
    sprints: {
      type: Array as PropType<SprintQueryColumnItem[]>,
      required: true,
    },
  },
  setup(props) {
    const cron = inject<CronService>("cron");
    const now = ref<DateTime>(DateTime.utc());
    const sprints = computed<SprintQueryColumnItem[]>(() => props.sprints);
    const isBacklog = (sprint: SprintQueryColumnItem) =>
      sprint.id === null || sprint.id === 0;
    const isClosed = (sprint: SprintQueryColumnItem) =>
      !isBacklog(sprint) &&
      DateTime.fromISO(sprint.endDate).endOf("day") < now.value;
    const isFuture = (sprint: SprintQueryColumnItem) =>
      !isBacklog(sprint) &&
      DateTime.fromISO(sprint.startDate).startOf("day") > now.value;
    const isCurrent = (sprint: SprintQueryColumnItem) =>
      !isBacklog(sprint) && !isClosed(sprint) && !isFuture(sprint);
    const setNow = () => {
      now.value = DateTime.utc();
    };
    const sortedSprints = computed(() =>
      [...sprints.value].sort((a, b) => {
        if (isCurrent(a) && !isCurrent(b)) {
          return -1;
        }
        if (!isCurrent(a) && isCurrent(b)) {
          return 1;
        }
        if (isClosed(a) && isClosed(b)) {
          // sort by end date descending
          return (
            DateTime.fromISO(b.endDate).toMillis() -
            DateTime.fromISO(a.endDate).toMillis()
          );
        }
        if (isClosed(a) && !isClosed(b)) {
          return 1;
        }
        if (!isClosed(a) && isClosed(b)) {
          return -1;
        }
        if (isFuture(a) && isFuture(b)) {
          // sort by start date ascending
          return (
            DateTime.fromISO(a.startDate).toMillis() -
            DateTime.fromISO(b.startDate).toMillis()
          );
        }
        if (isFuture(a) && !isFuture(b)) {
          return -1;
        }
        if (!isFuture(a) && isFuture(b)) {
          return 1;
        }
        return 0;
      }),
    );
    const focusSprint = computed(() => sortedSprints.value[0]);
    const remainingSprints = computed(() =>
      [...sortedSprints.value].filter((s) => s.id !== focusSprint.value.id),
    );
    onMounted(() => {
      if (cron) {
        cron.$on("* * * * * *", setNow);
      }
    });
    onBeforeUnmount(() => {
      if (cron) {
        cron.$off("* * * * * *", setNow);
      }
    });
    return {
      focusSprint,
      remainingSprints,
    };
  },
});
</script>

<template>
  <v-sheet color="transparent">
    <v-list-item>
      <v-list-item-title style="font-size: 75%; font-weight: bold">
        <span class="me-2">{{ name }}</span>
        <v-badge inline dot :color="color" />
      </v-list-item-title>
      <v-list-item-subtitle style="font-size: 70%">
        {{ dateRangeFormatted }}
      </v-list-item-subtitle>
    </v-list-item>
  </v-sheet>
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
import type { PropType } from "vue";
import type { CronService } from "@jakguru/vueprint";

export default defineComponent({
  name: "SprintQueryColumnItem",
  props: {
    id: {
      type: Number as PropType<number | null>,
      default: null,
    },
    name: {
      type: String as PropType<string>,
      required: true,
    },
    startDate: {
      type: String as PropType<string>,
      required: true,
    },
    endDate: {
      type: String as PropType<string>,
      required: true,
    },
  },
  setup(props) {
    const cron = inject<CronService>("cron");
    const id = computed(() => props.id);
    const name = computed(() => props.name);
    const startDate = computed(() => props.startDate);
    const endDate = computed(() => props.endDate);
    const startDateTime = computed(() =>
      DateTime.fromISO(startDate.value).startOf("day"),
    );
    const endDateTime = computed(() =>
      DateTime.fromISO(endDate.value).endOf("day"),
    );
    const now = ref<DateTime>(DateTime.utc());
    const isBacklog = computed(() => id.value === null || id.value === 0);
    const isClosed = computed(
      () => !isBacklog.value && endDateTime.value < now.value,
    );
    const isFuture = computed(
      () => !isBacklog.value && startDateTime.value > now.value,
    );
    const isCurrent = computed(
      () => !isBacklog.value && !isClosed.value && !isFuture.value,
    );
    const progress = computed(() => {
      if (isBacklog.value || isFuture.value) {
        return 0;
      }
      if (isClosed.value) {
        return 100;
      }
      const total = endDateTime.value.diff(startDateTime.value, "days").days;
      const elapsed = now.value.diff(startDateTime.value, "days").days;
      return Math.min(100, Math.floor((elapsed / total) * 100));
    });
    const startDateTimeFormatted = computed(() =>
      !isBacklog.value
        ? startDateTime.value.toLocaleString(DateTime.DATE_MED)
        : "",
    );
    const endDateTimeFormatted = computed(() =>
      !isBacklog.value
        ? endDateTime.value.toLocaleString(DateTime.DATE_MED)
        : "",
    );
    const dateRangeFormatted = computed(() =>
      !isBacklog.value
        ? [startDateTimeFormatted.value, endDateTimeFormatted.value].join(" - ")
        : name.value,
    );
    const color = computed(() => {
      switch (true) {
        case isClosed.value:
          return "mud";
        case isFuture.value:
          return "primary";
        case isCurrent.value:
          return "success";
        default:
          return "warning";
      }
    });
    const setNow = () => {
      now.value = DateTime.utc();
    };

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
      color,
      isCurrent,
      dateRangeFormatted,
      progress,
      isBacklog,
    };
  },
});
</script>

<template>
  <v-btn
    size="small"
    :disabled="disabled"
    block
    variant="outlined"
    :min-width="120"
    class="btn-time-tracking"
    @click="onButtonClick"
    @contextmenu="onContextMenu"
  >
    <v-avatar size="18" :color="statusIndicatorColor">
      <v-icon size="16" :color="iconColor">
        {{ statusIndicatorIcon }}
      </v-icon>
    </v-avatar>
    <span v-if="show" class="ms-3 time-tracking-elapsed">
      {{ elapsedTime }}
    </span>
    <v-dialog
      v-model:model-value="showActivitySelector"
      :persistent="true"
      max-width="400"
    >
      <v-card color="surface">
        <v-toolbar density="compact" color="transparent">
          <v-toolbar-title>
            {{ $t("timeTracking.activitySelector.title") }}
          </v-toolbar-title>
          <v-toolbar-items>
            <v-btn icon @click="doCloseModal">
              <v-icon>mdi-close</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider />
        <FridayForm v-bind="fridayFormBindings" @submit="onModalFormSubmit">
          <template #afterRows="{ isLoading, submit }">
            <v-row>
              <v-col cols="12">
                <div class="d-flex w-100 justify-end">
                  <v-btn
                    variant="elevated"
                    :color="accentColor"
                    size="x-small"
                    class="ma-2 me-0"
                    type="button"
                    height="24px"
                    :loading="isLoading"
                    @click="submit"
                  >
                    <v-icon class="me-2">mdi-play</v-icon>
                    {{ $t("timeTracking.start") }}
                  </v-btn>
                </div>
              </v-col>
            </v-row>
          </template>
        </FridayForm>
      </v-card>
    </v-dialog>
  </v-btn>
</template>

<script lang="ts">
import {
  defineComponent,
  computed,
  ref,
  onMounted,
  onBeforeUnmount,
  inject,
} from "vue";
import { DateTime, Duration } from "luxon";
import { useI18n } from "vue-i18n";
import { TinyEmitter } from "tiny-emitter";
import { Joi, getFormFieldValidator, FridayForm } from "@/components/forms";
import { VAutocomplete } from "vuetify/components/VAutocomplete";
import { useSystemAccentColor } from "@/utils/app";

import type { ApiService, CronService, ToastService } from "@jakguru/vueprint";
import type { FridayFormStructure } from "@/components/forms";

interface Activity {
  id: number;
  name: string;
  position: number;
  is_default: boolean;
  active: boolean;
  project_id: number | null;
  parent_id: number | null;
  position_name: string | null;
}

interface Status {
  id: number;
  name: string;
  description: string;
  is_closed: boolean;
  position: number;
  default_done_ratio: number;
}

export default defineComponent({
  name: "TimeTrackingButton",
  components: { FridayForm },
  props: {
    issueId: {
      type: Number,
      required: true,
    },
    iconColor: {
      type: String,
      default: "surface",
    },
  },
  emits: ["started", "stopped"],
  setup(props, { emit }) {
    const buttonBus = new TinyEmitter();
    const api = inject<ApiService>("api");
    const cron = inject<CronService>("cron");
    const toast = inject<ToastService>("toast");
    const { t } = useI18n({ useScope: "global" });
    const now = ref(DateTime.now());
    const issueId = computed(() => props.issueId);
    const unmountAbortController = ref<AbortController | undefined>(undefined);
    const status = ref<string | null>(null);
    const startTimeRaw = ref<string | null>(null);
    const totalHours = ref<number | null>(null);
    const totalMinutes = ref<number | null>(null);
    const totalSeconds = ref<number | null>(null);
    const startTime = computed(() => {
      if (startTimeRaw.value === null) {
        return null;
      }
      return DateTime.fromISO(startTimeRaw.value);
    });
    const elapsedTimeSinceStart = computed(() => {
      let comparison = startTime.value;
      if (startTime.value === null) {
        comparison = now.value;
      }
      return now.value.diff(comparison as DateTime, [
        "hours",
        "minutes",
        "seconds",
      ]);
    });
    const elapsedTime = computed(() => {
      const duration = Duration.fromDurationLike(
        elapsedTimeSinceStart.value,
      ).plus({
        hours: totalHours.value || 0,
        minutes: totalMinutes.value || 0,
        seconds: totalSeconds.value || 0,
      });
      return duration.toFormat("hh:mm:ss");
    });
    const canAct = ref<boolean>(false);
    const show = computed(() => status.value !== null);
    const showActivitySelector = ref(false);
    const doOpenModal = () => {
      showActivitySelector.value = true;
      buttonBus.emit("modal-opened");
    };
    const doCloseModal = () => {
      showActivitySelector.value = false;
      buttonBus.emit("modal-closed");
    };
    const selectedActivity = ref<number | undefined>(undefined);
    const selectedStatus = ref<number | undefined>(undefined);
    const getIssueTimeTrackingStatus = async () => {
      if (!api) {
        return;
      }
      try {
        const { status: httpStatus, data } = await api.get(
          `/issues/${issueId.value}/issue_time_tracking_starts`,
          {
            signal: unmountAbortController.value?.signal,
          },
        );
        if (httpStatus !== 200) {
          status.value = null;
          startTimeRaw.value = null;
          canAct.value = false;
          selectedStatus.value = undefined;
        } else {
          status.value = data.status;
          canAct.value = data.can_act;
          startTimeRaw.value = data.start_time || null;
          totalHours.value = data.total.hours;
          totalMinutes.value = data.total.minutes;
          totalSeconds.value = data.total.seconds;
          selectedStatus.value = data.status_id;
        }
      } catch {
        return;
      }
    };
    const loading = ref(false);
    const disabled = computed(() => loading.value || !canAct.value);
    const activities = ref<Activity[]>([]);
    const statuses = ref<Status[]>([]);
    const updateActivities = async () => {
      if (!api) {
        return;
      }
      try {
        const { status, data } = await api.get<Activity[]>(
          `/time-tracking/activities`,
          {
            signal: unmountAbortController.value?.signal,
          },
        );
        if (status !== 200) {
          return;
        }
        activities.value = data.sort((a, b) => a.position - b.position);
      } catch {
        return;
      }
    };
    const updateStatuses = async () => {
      if (!api) {
        return;
      }
      try {
        const { status, data } = await api.get<Status[]>(
          `/issues/${issueId.value}/time-tracking/statuses`,
          {
            signal: unmountAbortController.value?.signal,
          },
        );
        if (status !== 200) {
          return;
        }
        statuses.value = data.sort((a, b) => a.position - b.position);
      } catch {
        return;
      }
    };
    const start = async () => {
      if (!api) {
        return;
      }
      await Promise.all([updateActivities(), updateStatuses()]);
      doOpenModal();
      await new Promise<void>((resolve) => {
        buttonBus.once("modal-closed", resolve);
      });
      if (!selectedActivity.value || !selectedStatus.value) {
        return;
      }
      const { status } = await api.post(
        `/issues/${issueId.value}/issue_time_tracking_starts`,
        {
          activity_id: selectedActivity.value,
          status_id: selectedStatus.value,
        },
        {
          signal: unmountAbortController.value?.signal,
        },
      );
      if (status >= 200 && status < 300) {
        emit("started");
        selectedActivity.value = undefined;
      } else {
        if (toast) {
          toast.fire({
            icon: "error",
            title: t("timeTracking.onStart.error"),
          });
        } else {
          alert(t("timeTracking.onStart.error"));
        }
      }
    };
    const stop = async () => {
      if (!api) {
        return;
      }
      try {
        const { status } = await api.post(
          `/issues/${issueId.value}/issue_time_tracking_starts/stop`,
          {},
          {
            signal: unmountAbortController.value?.signal,
          },
        );
        if (status >= 200 && status < 300) {
          emit("stopped");
        } else {
          if (toast) {
            toast.fire({
              icon: "error",
              title: t("timeTracking.onStop.error"),
            });
          } else {
            alert(t("timeTracking.onStop.error"));
          }
        }
      } catch {
        return;
      }
    };
    const onButtonClick = async (e: MouseEvent) => {
      e.preventDefault();
      e.stopPropagation();
      e.stopImmediatePropagation();
      loading.value = true;
      await getIssueTimeTrackingStatus();
      if (status.value === null || !canAct.value) {
        if (toast) {
          toast.fire({
            icon: "error",
            title: t("timeTracking.onButtonClick.error.forbidden"),
          });
        } else {
          alert(t("timeTracking.onButtonClick.error.forbidden"));
        }
        return;
      } else if (status.value === "running") {
        await stop();
      } else if (status.value === "paused") {
        await start();
      } else {
        if (toast) {
          toast.fire({
            icon: "error",
            title: t("timeTracking.onButtonClick.error.unknownState"),
          });
        } else {
          alert(t("timeTracking.onButtonClick.error.unknownState"));
        }
      }
      await getIssueTimeTrackingStatus();
      loading.value = false;
    };
    const onContextMenu = async (e: MouseEvent) => {
      e.preventDefault();
      e.stopPropagation();
      e.stopImmediatePropagation();
    };
    const setNow = () => {
      now.value = DateTime.now();
    };
    onMounted(() => {
      unmountAbortController.value = new AbortController();
      if (cron) {
        cron.$on("*/30 * * * * *", getIssueTimeTrackingStatus);
        cron.$on("*/500 * * * * * *", setNow);
      }
      getIssueTimeTrackingStatus();
      setNow();
    });
    onBeforeUnmount(() => {
      if (cron) {
        cron.$off("*/30 * * * * *", getIssueTimeTrackingStatus);
        cron.$off("*/500 * * * * * *", setNow);
      }
      if (unmountAbortController.value) {
        unmountAbortController.value.abort();
      }
    });
    const statusIndicatorColor = computed(() => {
      switch (status.value) {
        case "running":
          return "grey";
        case "paused":
          return "accent";
        default:
          return "question";
      }
    });
    const statusIndicatorIcon = computed(() => {
      switch (status.value) {
        case "running":
          return "mdi-pause";
        case "paused":
          return "mdi-play";
        default:
          return "mdi-exclamation-thick";
      }
    });
    const onModalFormSubmit = (payload?: Record<string, unknown>) => {
      if (!payload) {
        return;
      }
      const { status_id: payloadStatusId, activity_id: payloadActivityId } =
        payload;
      selectedActivity.value = payloadActivityId as number;
      selectedStatus.value = payloadStatusId as number;
      doCloseModal();
    };
    const accentColor = useSystemAccentColor();
    const formStructure = computed<FridayFormStructure>(() => {
      return [
        [
          {
            cols: 12,
            fieldComponent: VAutocomplete,
            formKey: "activity_id",
            valueKey: "activity_id",
            label: t("timeTracking.fields.activity"),
            validator: getFormFieldValidator(
              t,
              Joi.number()
                .required()
                .allow(...activities.value.map((v) => v.id)),
              t("timeTracking.fields.activity"),
            ),
            bindings: {
              label: t("timeTracking.fields.activity"),
              items: activities.value.map((activity) => ({
                text: activity.name,
                value: activity.id,
              })),
              itemTitle: "text",
              itemValue: "value",
              density: "compact",
            },
          },
        ],
        [
          {
            cols: 12,
            fieldComponent: VAutocomplete,
            formKey: "status_id",
            valueKey: "status_id",
            label: t("timeTracking.fields.status"),
            validator: getFormFieldValidator(
              t,
              Joi.number()
                .required()
                .allow(...statuses.value.map((v) => v.id)),
              t("timeTracking.fields.status"),
            ),
            bindings: {
              label: t("timeTracking.fields.status"),
              items: statuses.value.map((status) => ({
                text: status.name,
                value: status.id,
              })),
              itemTitle: "text",
              itemValue: "value",
              density: "compact",
            },
          },
        ],
      ];
    });
    const fridayFormBindings = computed(() => ({
      action: "#",
      method: "post",
      structure: formStructure.value,
      values: {
        activity_id: selectedActivity.value,
        status_id: selectedStatus.value,
      },
      noHttp: true,
    }));
    return {
      show,
      status,
      elapsedTime,
      disabled,
      onButtonClick,
      onContextMenu,
      statusIndicatorColor,
      statusIndicatorIcon,
      buttonBus,
      showActivitySelector,
      doOpenModal,
      doCloseModal,
      onModalFormSubmit,
      accentColor,
      fridayFormBindings,
    };
  },
});
</script>

<style lang="scss">
.btn-time-tracking {
  .time-tracking-elapsed {
    font-size: 12px;
    font-weight: 300;
  }
}
</style>

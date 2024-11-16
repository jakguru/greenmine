/* eslint-disable vue/one-component-per-file */
import { defineComponent, h, computed } from "vue";
import { VChip } from "vuetify/components/VChip";
import { useAppData } from "@/utils/app";

import type { PropType } from "vue";
import type { IssueStatus, Tracker } from "@/friday";

export const IssueStatusChip = defineComponent({
  name: "IssueStatusChip",
  props: {
    id: {
      type: Number as PropType<number | undefined>,
      default: undefined,
    },
    name: {
      type: String,
      required: true,
    },
    isClosed: {
      type: Boolean,
      required: true,
    },
    position: {
      type: Number as PropType<number | undefined>,
      default: undefined,
    },
    description: {
      type: String as PropType<string | null | undefined>,
      default: undefined,
    },
    defaultDoneRatio: {
      type: Number as PropType<number | null | undefined>,
      default: undefined,
    },
    icon: {
      type: String as PropType<`mdi-${string}` | null | undefined>,
      default: undefined,
    },
    textColor: {
      type: String as PropType<
        `#${string}` | "on-working" | "on-mud" | null | undefined
      >,
      default: undefined,
    },
    backgroundColor: {
      type: String as PropType<
        `#${string}` | "working" | "mud" | null | undefined
      >,
      default: undefined,
    },
  },
  setup(props) {
    const appData = useAppData();
    const appDataTrackers = computed<IssueStatus[]>(
      () => appData.value.statuses || [],
    );
    const appDataTracker = computed(() =>
      appDataTrackers.value.find((ads) => {
        if (props.id !== undefined) {
          return ads.id === props.id;
        }
        return ads.name === props.name;
      }),
    );
    const backgroundColor = computed(() => {
      if ("string" === typeof props.backgroundColor) {
        return props.backgroundColor;
      } else if (
        appDataTracker.value &&
        appDataTracker.value.background_color
      ) {
        return appDataTracker.value.background_color;
      } else {
        return props.isClosed ? "mud" : "working";
      }
    });
    const textColor = computed(() => {
      if ("string" === typeof props.textColor) {
        return props.textColor;
      } else if (appDataTracker.value && appDataTracker.value.text_color) {
        return appDataTracker.value.text_color;
      } else {
        return props.isClosed ? "on-mud" : "on-working";
      }
    });
    const colorIsHex = computed(() => textColor.value.startsWith("#"));
    const icon = computed(() => {
      if (props.icon) {
        return props.icon as `mdi-${string}`;
      } else if (appDataTracker.value && appDataTracker.value.icon) {
        return appDataTracker.value.icon as `mdi-${string}`;
      } else {
        return null;
      }
    });
    const description = computed(() => {
      if (props.description) {
        return props.description;
      } else if (appDataTracker.value) {
        return appDataTracker.value.description;
      } else {
        return null;
      }
    });
    const vChipClasses = computed(() => {
      const ret = new Set<string>();
      ret.add("font-weight-bold");
      ret.add("w-100");
      ret.add("v-chip--issue-status");
      if (props.icon) {
        ret.add("ps-3");
      }
      return [...ret];
    });
    const vChipBindings = computed(() => ({
      color: backgroundColor.value,
      class: vChipClasses.value,
      style: {
        color: colorIsHex.value
          ? textColor.value
          : `var(--v-theme-${textColor.value})`,
      },
      prependIcon: icon.value || undefined,
      variant: "flat" as const,
      size: "small" as const,
      title: description.value,
    }));
    return () => h(VChip, vChipBindings.value, props.name);
  },
});

export const TrackerChip = defineComponent({
  name: "TrackerChip",
  props: {
    id: {
      type: Number as PropType<number | undefined>,
      default: undefined,
    },
    name: {
      type: String,
      required: true,
    },
    description: {
      type: String as PropType<string | null | undefined>,
      default: undefined,
    },
    icon: {
      type: String as PropType<`mdi-${string}` | null | undefined>,
      default: undefined,
    },
    color: {
      type: String as PropType<`#${string}` | null | undefined>,
      default: undefined,
    },
  },
  setup(props) {
    const appData = useAppData();
    const appDataTrackers = computed<Tracker[]>(
      () => appData.value.trackers || [],
    );
    const appDataTracker = computed(() =>
      appDataTrackers.value.find((ads) => {
        if (props.id !== undefined) {
          return ads.id === props.id;
        }
        return ads.name === props.name;
      }),
    );
    const color = computed(() => {
      if ("string" === typeof props.color) {
        return props.color;
      } else if (appDataTracker.value && appDataTracker.value.color) {
        return appDataTracker.value.color;
      } else {
        return "accent";
      }
    });
    const icon = computed(() => {
      if (props.icon) {
        return props.icon as `mdi-${string}`;
      } else if (appDataTracker.value && appDataTracker.value.icon) {
        return appDataTracker.value.icon as `mdi-${string}`;
      } else {
        return null;
      }
    });
    const description = computed(() => {
      if (props.description) {
        return props.description;
      } else if (appDataTracker.value) {
        return appDataTracker.value.description;
      } else {
        return null;
      }
    });
    const vChipClasses = computed(() => {
      const ret = new Set<string>();
      ret.add("font-weight-bold");
      ret.add("w-100");
      ret.add("v-chip--issue-status");
      if (props.icon) {
        ret.add("ps-3");
      }
      return [...ret];
    });
    const vChipBindings = computed(() => ({
      color: color.value,
      class: vChipClasses.value,
      prependIcon: icon.value || undefined,
      variant: "tonal" as const,
      size: "small" as const,
      title: description.value,
      style: {
        border: "solid 1px",
      },
      rounded: 0,
    }));
    return () => h(VChip, vChipBindings.value, props.name);
  },
});

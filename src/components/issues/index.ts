import { defineComponent, h, computed } from "vue";
import { VChip } from "vuetify/components/VChip";
import { useAppData } from "@/utils/app";

import type { PropType } from "vue";
import type { IssueStatus } from "@/friday";

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
    const appDataStatuses = computed<IssueStatus[]>(
      () => appData.value.statuses || [],
    );
    const appDataStatus = computed(() =>
      appDataStatuses.value.find((ads) => {
        if (props.id !== undefined) {
          return ads.id === props.id;
        }
        return ads.name === props.name;
      }),
    );
    const backgroundColor = computed(() => {
      if ("string" === typeof props.backgroundColor) {
        return props.backgroundColor;
      } else if (appDataStatus.value && appDataStatus.value.background_color) {
        return appDataStatus.value.background_color;
      } else {
        return props.isClosed ? "mud" : "working";
      }
    });
    const textColor = computed(() => {
      if ("string" === typeof props.textColor) {
        return props.textColor;
      } else if (appDataStatus.value && appDataStatus.value.text_color) {
        return appDataStatus.value.text_color;
      } else {
        return props.isClosed ? "on-mud" : "on-working";
      }
    });
    const textColorIsHex = computed(() => textColor.value.startsWith("#"));
    const icon = computed(() => {
      if (props.icon) {
        return props.icon as `mdi-${string}`;
      } else if (appDataStatus.value && appDataStatus.value.icon) {
        return appDataStatus.value.icon as `mdi-${string}`;
      } else {
        return null;
      }
    });
    const description = computed(() => {
      if (props.description) {
        return props.description;
      } else if (appDataStatus.value) {
        return appDataStatus.value.description;
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
        color: textColorIsHex.value
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

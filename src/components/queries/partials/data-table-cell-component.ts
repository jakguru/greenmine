import { defineComponent, computed, h } from "vue";
import { RouterLink } from "vue-router";
import { VChip } from "vuetify/components/VChip";
import { VProgressLinear } from "vuetify/components/VProgressLinear";
import {
  formatDateTime,
  formatDateTimeAsUTC,
  formatDuration,
} from "@/utils/formatting";
import { useAppData } from "@/utils/app";
import { calculateColorForPriority } from "@/utils/colors";
import { useI18n } from "vue-i18n";

import ProjectById from "./custom-data-table-cells/project-by-id.vue";

import type { PropType } from "vue";
import type { QueryData, Item, EntryHashValue } from "@/friday";

interface InternalItem<T = any> {
  value: any;
  raw: T;
}

type FilterMatch = boolean | number | [number, number] | [number, number][];

type FilterFunction = (
  value: string,
  query: string,
  item?: InternalItem,
) => FilterMatch;

type SelectItemKey<T = Record<string, any>> =
  | boolean
  | null
  | undefined // Ignored
  | string // Lookup by key, can use dot notation for nested objects
  | readonly (string | number)[] // Nested lookup by key, each array item is a key in the next level
  | ((item: T, fallback?: any) => any);

type DataTableCompareFunction<T = any> = (a: T, b: T) => number | null;

type ItemSlotBase<T> = {
  index: number;
  item: T;
  internalItem: DataTableItem<T>;
  isExpanded: (item: DataTableItem) => boolean;
  toggleExpand: (item: DataTableItem) => void;
  isSelected: (items: DataTableItem | DataTableItem[]) => boolean;
  toggleSelect: (item: DataTableItem) => void;
};

type ItemKeySlot<T> = ItemSlotBase<T> & {
  value: any;
  column: InternalDataTableHeader;
};

type HeaderCellProps =
  | Record<string, any>
  | ((
      data: Pick<ItemKeySlot<any>, "index" | "item" | "internalItem" | "value">,
    ) => Record<string, any>);

type DataTableHeader<T = Record<string, any>> = {
  key?:
    | "data-table-group"
    | "data-table-select"
    | "data-table-expand"
    | (string & {});
  value?: SelectItemKey<T>;
  title?: string;

  fixed?: boolean;
  align?: "start" | "end" | "center";

  width?: number | string;
  minWidth?: string;
  maxWidth?: string;
  nowrap?: boolean;

  headerProps?: Record<string, any>;
  cellProps?: HeaderCellProps;

  sortable?: boolean;
  sort?: DataTableCompareFunction;
  sortRaw?: DataTableCompareFunction;
  filter?: FilterFunction;

  mobile?: boolean;

  children?: DataTableHeader<T>[];
};

type InternalDataTableHeader = Omit<
  DataTableHeader,
  "key" | "value" | "children"
> & {
  key: string | null;
  value: SelectItemKey | null;
  sortable: boolean;
  fixedOffset?: number;
  lastFixed?: boolean;
  nowrap?: boolean;
  colspan?: number;
  rowspan?: number;
  children?: InternalDataTableHeader[];
};

interface GroupableItem<T = any> {
  type: "item";
  raw: T;
}

interface SelectableItem {
  value: any;
  selectable: boolean;
}

interface DataTableItem<T = any>
  extends InternalItem<T>,
    GroupableItem<T>,
    SelectableItem {
  key: any;
  index: number;
  columns: {
    [key: string]: any;
  };
}

export const QueriesPartialDataTableCell = defineComponent({
  name: "QueriesPartialDataTableCell",
  props: {
    query: {
      type: Object as PropType<QueryData>,
      required: true,
    },
    index: {
      type: Number,
      required: true,
    },
    item: {
      type: Object as PropType<Item>,
      required: true,
    },
    internalItem: {
      type: Object as PropType<DataTableItem>,
      required: true,
    },
    isExpanded: {
      type: Function as PropType<(item: DataTableItem) => boolean>,
      required: true,
    },
    toggleExpand: {
      type: Function as PropType<(item: DataTableItem) => void>,
      required: true,
    },
    isSelected: {
      type: Function as PropType<
        (
          items: { value: any; selectable: boolean } | SelectableItem[],
        ) => boolean
      >,
      required: true,
    },
    toggleSelect: {
      type: Function as PropType<
        (item: { value: any; selectable: boolean }) => void
      >,
      required: true,
    },
    value: {
      type: Object as PropType<EntryHashValue>,
      required: true,
    },
    column: {
      type: Object as PropType<InternalDataTableHeader>,
      required: true,
    },
  },
  setup(props) {
    const { t } = useI18n({ useScope: "global" });
    const appData = useAppData();
    const priorities = computed(() =>
      [...appData.value.priorities].sort((a, b) => a.position - b.position),
    );
    const impacts = computed(() =>
      [...appData.value.impacts].sort((a, b) => a.position - b.position),
    );
    const lowestPriorityPosition = computed(() =>
      Math.min(...priorities.value.map((p) => p.position)),
    );
    const highestPriorityPosition = computed(() =>
      Math.max(...priorities.value.map((p) => p.position)),
    );
    const lowestImpactPosition = computed(() =>
      Math.min(...impacts.value.map((p) => p.position)),
    );
    const highestImpactPosition = computed(() =>
      Math.max(...impacts.value.map((p) => p.position)),
    );
    const query = computed(() => props.query);
    const column = computed(() => props.column);
    const value = computed(() => props.value);
    const item = computed(() => props.item);
    const attrs = computed(() => ({
      "friday-type": value.value ? value.value.type : "unknown",
      "friday-column": column.value.key,
    }));
    const toReturnByColumnKey = computed(() => {
      switch (column.value.key) {
        case "identifier":
          return h("code", attrs.value, value.value.display);
        case "estimated_hours":
        case "total_estimated_hours":
        case "spent_hours":
        case "total_spent_hours":
          return h("code", attrs.value, formatDuration(value.value.value));
        case "calculated_priority":
          return h(
            VChip,
            {
              color: calculateColorForPriority(
                1,
                10,
                value.value.value,
                "#F44336",
                "#607D8B",
              ),
              variant: "flat",
              size: "small",
              class: ["font-weight-bold"],
              ...attrs.value,
            },
            value.value.display,
          );
        case "done_ratio":
          return h(
            VProgressLinear,
            {
              value: value.value.value,
              color: value.value.value === 100 ? "success" : "warning",
              height: 20,
              ...attrs.value,
            },
            { default: () => h("small", `${value.value.display}%`) },
          );
        default:
          if (!value.value) {
            return h("span", attrs.value, "");
          }
          return h("span", attrs.value, value.value.display);
      }
    });
    const toReturnByQueryType = computed(() => {
      switch (query.value.type) {
        case "IssueQuery":
          switch (column.value.key) {
            case "id":
            case "subject":
              return h(
                RouterLink,
                {
                  to: { name: "issues-id", params: { id: item.value.id } },
                  ...attrs.value,
                },
                value.value.display,
              );
            case "parent":
              if (item.value.entry.parent.value === null) {
                return h("span", attrs.value, "");
              }
              return h(
                RouterLink,
                {
                  to: {
                    name: "issues-id",
                    params: { id: value.value.value.id },
                  },
                  ...attrs.value,
                },
                value.value.display
                  .replace(`: ${value.value.value.subject}`, "")
                  .trim(),
              );
            case "parent.subject":
              if (item.value.entry.parent.value === null) {
                return h("span", attrs.value, "");
              }
              return h(
                RouterLink,
                {
                  to: {
                    name: "issues-id",
                    params: { id: item.value.entry.parent.value.id },
                  },
                  ...attrs.value,
                },
                item.value.entry.parent.value.subject,
              );
            default:
              return toReturnByColumnKey.value;
          }
        case "ProjectQuery":
          switch (column.value.key) {
            case "id":
            case "name":
              return h(
                RouterLink,
                {
                  to: {
                    name: "projects-id",
                    params: { id: item.value.entry.identifier.value },
                  },
                  ...attrs.value,
                },
                value.value.display,
              );
            case "status":
              return h(
                VChip,
                {
                  color: value.value.value === 0 ? "mud" : "success",
                  variant: "flat",
                  size: "small",
                  class: ["font-weight-bold"],
                  ...attrs.value,
                },
                value.value.value === 0
                  ? t("labels.archived")
                  : t("labels.active"),
              );
            case "parent_id":
              return h(ProjectById, {
                projectId: value.value.value,
              });
            default:
              return toReturnByColumnKey.value;
          }
        case "TimeEntryQuery":
          switch (column.value.key) {
            default:
              return toReturnByColumnKey.value;
          }
        case "UserQuery":
          switch (column.value.key) {
            default:
              return toReturnByColumnKey.value;
          }
        default:
          return toReturnByColumnKey.value;
      }
    });
    const toReturn = computed(() => {
      if (value.value === null || value.value === undefined) {
        return toReturnByQueryType.value;
      }
      switch (value.value.type) {
        case "Project":
          return h(
            RouterLink,
            {
              to: {
                name: "projects-id",
                params: { id: value.value.value.identifier },
              },
              ...attrs.value,
            },
            value.value.display,
          );
        case "User":
          return h(
            RouterLink,
            {
              to: {
                name: "users-id",
                params: { id: value.value.value.id },
              },
              ...attrs.value,
            },
            value.value.display,
          );
        case "IssueStatus":
          return h(
            VChip,
            {
              color: value.value.value.is_closed ? "mud" : "working",
              variant: "flat",
              size: "small",
              class: ["font-weight-bold"],
              ...attrs.value,
            },
            value.value.display,
          );
        case "IssuePriority":
          return h(
            VChip,
            {
              color: calculateColorForPriority(
                lowestPriorityPosition.value,
                highestPriorityPosition.value,
                value.value.value.position,
                "#607D8B",
                "#F44336",
              ),
              variant: "flat",
              size: "small",
              class: ["font-weight-bold"],
              ...attrs.value,
            },
            value.value.display,
          );
        case "IssueImpact":
          return h(
            VChip,
            {
              color: calculateColorForPriority(
                lowestImpactPosition.value,
                highestImpactPosition.value,
                value.value.value.position,
                "#607D8B",
                "#F44336",
              ),
              variant: "flat",
              size: "small",
              class: ["font-weight-bold"],
              ...attrs.value,
            },
            value.value.display,
          );
        case "ActiveSupport::TimeWithZone":
          return h(
            "abbr",
            {
              title: formatDateTimeAsUTC(value.value.value),
              ...attrs.value,
            },
            formatDateTime(value.value.value),
          );
        case "TrueClass":
          return h(
            VChip,
            {
              color: "success",
              variant: "flat",
              size: "small",
              class: ["font-weight-bold"],
              ...attrs.value,
            },
            t("labels.yes"),
          );
        case "FalseClass":
          return h(
            VChip,
            {
              color: "error",
              variant: "flat",
              size: "small",
              class: ["font-weight-bold"],
              ...attrs.value,
            },
            t("labels.no"),
          );
        case "Attachment::ActiveRecord_Associations_CollectionProxy":
          return value.value.value.map((_attachment: any) => {
            return h("pre", attrs.value, JSON.stringify(_attachment, null, 2));
          });
        case "IssueRelation::Relations":
          return value.value.value.map((_relation: any) => {
            return h("pre", attrs.value, JSON.stringify(_relation, null, 2));
          });
        default:
          return toReturnByQueryType.value;
      }
    });
    return () => toReturn.value;
  },
});
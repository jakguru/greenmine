/* eslint-disable vue/one-component-per-file */
import { defineComponent, computed, h, ref, watch } from "vue";
import { Handle, Position, useVueFlow } from "@vue-flow/core";
import { IssueStatusChip } from "@/components/issues";
import { VSheet } from "vuetify/components/VSheet";
import { VAvatar } from "vuetify/components/VAvatar";
import { VIcon } from "vuetify/components/VIcon";
import Joi from "joi";

import type { PropType, VNode, Component } from "vue";
import type { IssueStatusChipProps } from "@/components/issues";
import type {
  NodeProps,
  HandleConnectable,
  XYPosition,
  Dimensions,
  ValidConnectionFunc,
  NodeEventsOn,
} from "@vue-flow/core";

export interface IssueStatusFieldPermissions {
  [roleId: string]: {
    coreFields: {
      [fieldId: string]: string;
    };
    customFields: {
      [fieldId: string]: string;
    };
  };
}

export interface IssueStatusNodeData {
  statusId: number;
  statusName: string;
  current: IssueStatusFieldPermissions;
}

export const IssueStatusNodeDataSchema = Joi.object<IssueStatusNodeData>({
  statusId: Joi.number().required().min(0),
  statusName: Joi.string().required(),
  current: Joi.object().default({}),
}).unknown(true);

export const IssueStatusNode = defineComponent<NodeProps<IssueStatusNodeData>>({
  name: "IssueStatusNode",
  props: {
    id: {
      type: [String, Number] as PropType<string | number>,
      required: true,
    },
    type: {
      type: String as PropType<string>,
      required: true,
    },
    selected: {
      type: Boolean as PropType<boolean>,
      required: true,
    },
    connectable: {
      type: [Boolean, Number, String, Function] as PropType<HandleConnectable>,
      required: true,
    },
    position: {
      type: Object as PropType<XYPosition>,
      required: true,
    },
    dimensions: {
      type: Object as PropType<Dimensions>,
      required: true,
    },
    label: {
      type: [String, Object] as PropType<
        string | VNode | Component | Object | undefined
      >,
      default: undefined,
    },
    isValidTargetPos: {
      type: Function as PropType<ValidConnectionFunc | undefined>,
      default: undefined,
    },
    isValidSourcePos: {
      type: Function as PropType<ValidConnectionFunc | undefined>,
      default: undefined,
    },
    parent: {
      type: String as PropType<string | undefined>,
      default: undefined,
    },
    dragging: {
      type: Boolean as PropType<boolean>,
      default: false,
    },
    resizing: {
      type: Boolean as PropType<boolean>,
      default: false,
    },
    zIndex: {
      type: Number as PropType<number>,
      default: 0,
    },
    targetPosition: {
      type: String as PropType<Position | undefined>,
      default: undefined,
    },
    sourcePosition: {
      type: String as PropType<Position | undefined>,
      default: undefined,
    },
    dragHandle: {
      type: String as PropType<string | undefined>,
      default: undefined,
    },
    data: {
      type: Object as PropType<IssueStatusNodeData>,
      required: true,
    },
    events: {
      type: Object as PropType<NodeEventsOn>,
      default: () => ({}),
    },
  },
  setup(props) {
    const id = computed(() => props.id);
    const getIssueStatusNodeData = (data: unknown): IssueStatusNodeData => {
      const { value, error } = IssueStatusNodeDataSchema.validate(data);
      if (error) {
        return {
          statusId: 0,
          statusName: error.message,
          current: {},
        };
      }
      return value;
    };
    const data = computed(() => getIssueStatusNodeData(props.data));
    const { updateNodeData } = useVueFlow();
    const current = computed({
      get: () => data.value.current,
      set: (v: IssueStatusFieldPermissions) => {
        const toPush = {
          ...data.value,
          current: v,
        };
        console.log("setting current", id.value, toPush);
        updateNodeData(id.value, toPush);
      },
    });
    const localCurrent = ref<IssueStatusFieldPermissions>(data.value.current);
    watch(
      () => data.value.current,
      () => {
        localCurrent.value = data.value.current;
      },
      { deep: true, immediate: true },
    );
    watch(
      () => localCurrent.value,
      () => {
        current.value = localCurrent.value;
      },
      { deep: true },
    );
    const issueStatusChipProps = computed<IssueStatusChipProps>(() => ({
      id: data.value.statusId === 0 ? undefined : data.value.statusId,
      name: data.value.statusName,
      isClosed: undefined,
      Position: undefined,
      description: undefined,
      defaultDoneRatio: undefined,
      icon: data.value.statusId === 0 ? "mdi-alert" : undefined,
      textColor: data.value.statusId === 0 ? "#B71C1C" : undefined,
      backgroundColor: data.value.statusId === 0 ? "#FFF176" : undefined,
    }));
    const topLevelNodes = computed(() =>
      [
        h(IssueStatusChip, issueStatusChipProps.value),
        h(Handle, {
          id: "in",
          type: "target",
          position: Position.Left,
        }),
        h(Handle, {
          id: "out",
          type: "source",
          position: Position.Right,
        }),
      ].filter((n) => "undefined" !== typeof n),
    );
    return () =>
      h(
        "div",
        {
          class: "issue-status-node",
        },
        topLevelNodes.value,
      );
  },
});

export const TrackerWorkflowStartNode = defineComponent<NodeProps>({
  name: "TrackerWorkflowStartNode",
  props: {
    id: {
      type: [String, Number] as PropType<string | number>,
      required: true,
    },
    type: {
      type: String as PropType<string>,
      required: true,
    },
    selected: {
      type: Boolean as PropType<boolean>,
      required: true,
    },
    connectable: {
      type: [Boolean, Number, String, Function] as PropType<HandleConnectable>,
      required: true,
    },
    position: {
      type: Object as PropType<XYPosition>,
      required: true,
    },
    dimensions: {
      type: Object as PropType<Dimensions>,
      required: true,
    },
    label: {
      type: [String, Object] as PropType<
        string | VNode | Component | Object | undefined
      >,
      default: undefined,
    },
    isValidTargetPos: {
      type: Function as PropType<ValidConnectionFunc | undefined>,
      default: undefined,
    },
    isValidSourcePos: {
      type: Function as PropType<ValidConnectionFunc | undefined>,
      default: undefined,
    },
    parent: {
      type: String as PropType<string | undefined>,
      default: undefined,
    },
    dragging: {
      type: Boolean as PropType<boolean>,
      default: false,
    },
    resizing: {
      type: Boolean as PropType<boolean>,
      default: false,
    },
    zIndex: {
      type: Number as PropType<number>,
      default: 0,
    },
    targetPosition: {
      type: String as PropType<Position | undefined>,
      default: undefined,
    },
    sourcePosition: {
      type: String as PropType<Position | undefined>,
      default: undefined,
    },
    dragHandle: {
      type: String as PropType<string | undefined>,
      default: undefined,
    },
    data: {
      type: Object as PropType<Record<string, unknown>>,
      required: true,
    },
    events: {
      type: Object as PropType<NodeEventsOn>,
      default: () => ({}),
    },
  },
  setup() {
    return () =>
      h(
        VSheet,
        {
          color: "transparent",
        },
        [
          h(
            VAvatar,
            {
              size: "26",
              color: "accent",
            },
            [h(VIcon, { size: "18" }, "mdi-note-plus")],
          ),
          h(Handle, {
            id: "out",
            type: "source",
            position: Position.Right,
          }),
        ],
      );
  },
});

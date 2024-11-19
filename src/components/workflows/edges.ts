import { defineComponent, computed, h } from "vue";
import {
  SmoothStepEdge,
  Position,
  EdgeLabelRenderer,
  getSmoothStepPath,
} from "@vue-flow/core";
import { VBtn } from "vuetify/components/VBtn";
import { VIcon } from "vuetify/components/VIcon";

import type { PropType, VNode, Component } from "vue";
import type { EdgeProps, GraphNode, EdgeEventsOn } from "@vue-flow/core";

export interface IssueStatusTransitionRules {
  [roleId: string]: {
    always: boolean;
    author: boolean;
    assignee: boolean;
  };
}

export interface IssueStatusTransitionEdgeData {
  current: IssueStatusTransitionRules;
}

export type IssueStatusTransitionProps =
  EdgeProps<IssueStatusTransitionEdgeData>;

export const IssueStatusTransitionEdge =
  defineComponent<IssueStatusTransitionProps>({
    name: "IssueStatusTransitionEdge",
    props: {
      id: {
        type: String,
        required: true,
      },
      sourceNode: {
        type: Object as PropType<GraphNode>,
        required: true,
      },
      targetNode: {
        type: Object as PropType<GraphNode>,
        required: true,
      },
      source: {
        type: String,
        required: true,
      },
      target: {
        type: String,
        required: true,
      },
      type: {
        type: String as PropType<"issue-status-transition">,
        default: "issue-status-transition",
      },
      label: {
        type: [String, Object] as PropType<
          string | VNode | Component | Object | undefined
        >,
        default: undefined,
      },
      style: {
        type: Object as PropType<CSSStyleDeclaration>,
        default: undefined,
      },
      selected: {
        type: Boolean,
        default: false,
      },
      sourcePosition: {
        type: String as PropType<Position>,
        required: true,
      },
      targetPosition: {
        type: String as PropType<Position>,
        required: true,
      },
      sourceHandleId: {
        type: String as PropType<string | undefined>,
        default: undefined,
      },
      targetHandleId: {
        type: String as PropType<string | undefined>,
        default: undefined,
      },
      animated: {
        type: Boolean,
        default: true,
      },
      updatable: {
        type: Boolean,
        default: true,
      },
      markerStart: {
        type: String,
        required: true,
      },
      markerEnd: {
        type: String,
        required: true,
      },
      curvature: {
        type: Number as PropType<number | undefined>,
        default: undefined,
      },
      interactionWidth: {
        type: Number as PropType<number | undefined>,
        default: undefined,
      },
      data: {
        type: Object as PropType<IssueStatusTransitionEdgeData>,
        required: true,
      },
      events: {
        type: Object as PropType<EdgeEventsOn>,
        default: () => ({}),
      },
      sourceX: {
        type: Number,
        required: true,
      },
      sourceY: {
        type: Number,
        required: true,
      },
      targetX: {
        type: Number,
        required: true,
      },
      targetY: {
        type: Number,
        required: true,
      },
    },
    emits: {
      "button:click": (id: string) => "string" === typeof id,
    },
    setup(props, { emit }) {
      const id = computed(() => props.id);
      const sourceNode = computed(() => props.sourceNode);
      const targetNode = computed(() => props.targetNode);
      const source = computed(() => props.source);
      const target = computed(() => props.target);
      const type = computed(() => props.type);
      const label = computed(() => props.label);
      const style = computed(() => props.style);
      const selected = computed(() => props.selected);
      const sourcePosition = computed(() => props.sourcePosition);
      const targetPosition = computed(() => props.targetPosition);
      const sourceHandleId = computed(() => props.sourceHandleId);
      const targetHandleId = computed(() => props.targetHandleId);
      const animated = computed(() => props.animated);
      const updatable = computed(() => props.updatable);
      const markerStart = computed(() => props.markerStart);
      const markerEnd = computed(() => props.markerEnd);
      const curvature = computed(() => props.curvature);
      const interactionWidth = computed(() => props.interactionWidth);
      const data = computed(() => props.data);
      const events = computed(() => props.events);
      const sourceX = computed(() => props.sourceX);
      const sourceY = computed(() => props.sourceY);
      const targetX = computed(() => props.targetX);
      const targetY = computed(() => props.targetY);
      const edgeProps = computed<IssueStatusTransitionProps>(() => ({
        id: id.value,
        sourceNode: sourceNode.value,
        targetNode: targetNode.value,
        source: source.value,
        target: target.value,
        type: type.value,
        label: label.value,
        style: style.value,
        selected: selected.value,
        sourcePosition: sourcePosition.value,
        targetPosition: targetPosition.value,
        sourceHandleId: sourceHandleId.value,
        targetHandleId: targetHandleId.value,
        animated: animated.value,
        updatable: updatable.value,
        markerStart: markerStart.value,
        markerEnd: markerEnd.value,
        curvature: curvature.value,
        interactionWidth: interactionWidth.value,
        data: data.value,
        events: events.value,
        sourceX: sourceX.value,
        sourceY: sourceY.value,
        targetX: targetX.value,
        targetY: targetY.value,
      }));
      const path = computed(() => getSmoothStepPath(edgeProps.value));
      return () => [
        h(SmoothStepEdge, edgeProps.value),
        h(EdgeLabelRenderer, [
          h(
            "div",
            {
              style: {
                pointerEvents: "all",
                position: "absolute",
                transform: `translate(-50%, -50%)
                  translate(${path.value[1]}px, ${path.value[2]}px)`,
              },
              class: ["no-drag", "no-pan"],
            },
            [
              h(
                VBtn,
                {
                  ...props,
                  size: "14",
                  density: "comfortable",
                  variant: "elevated",
                  icon: true,
                  color:
                    style.value && style.value.stroke
                      ? style.value.stroke
                      : "accent",
                  onClick: () => emit("button:click", props.id),
                },
                h(VIcon, { size: "10" }, "mdi-dots-vertical"),
              ),
            ],
          ),
        ]),
      ];
    },
  });

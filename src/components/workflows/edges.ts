import { defineComponent, computed, h, ref } from "vue";
import {
  SmoothStepEdge,
  Position,
  EdgeLabelRenderer,
  getSmoothStepPath,
} from "@vue-flow/core";
import { useI18n } from "vue-i18n";
import { VBtn } from "vuetify/components/VBtn";
import { VIcon } from "vuetify/components/VIcon";
import { VSpeedDial } from "vuetify/components/VSpeedDial";
import { VCard } from "vuetify/components/VCard";
import { VDivider } from "vuetify/components/VDivider";
import {
  VToolbar,
  VToolbarTitle,
  VToolbarItems,
} from "vuetify/components/VToolbar";
import { VDialog } from "vuetify/components/VDialog";
import { VSwitch } from "vuetify/components/VSwitch";
import { VTable } from "vuetify/components/VTable";
import { IssueStatusChip } from "@/components/issues";

import type { PropType, VNode, Component } from "vue";
import type {
  EdgeProps,
  RemoveEdges,
  GraphNode,
  EdgeEventsOn,
} from "@vue-flow/core";
import type { Role, IssueStatus } from "@/friday";
import type { IssueStatusChipProps } from "@/components/issues";

export interface IssueStatusTransitionEdgeData {
  actions: {
    removeEdges: RemoveEdges;
  };
  roles: Role[];
  statuses: IssueStatus[];
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
    setup(props) {
      const { t } = useI18n({ useScope: "global" });
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
      const showConfigurationDialog = ref(false);
      const dialogProps = computed(() => ({
        modelValue: showConfigurationDialog.value,
        "onUpdate:modelValue": (v: boolean) => {
          showConfigurationDialog.value = v;
        },
        maxWidth: 500,
      }));
      const sourceStatusId = computed(() =>
        sourceNode.value &&
        sourceNode.value.data &&
        sourceNode.value.data.statusId
          ? sourceNode.value.data.statusId
          : 0,
      );
      const sourceStatus = computed(() =>
        data.value.statuses.find((s) => s.id === sourceStatusId.value),
      );
      const targetStatusId = computed(() =>
        targetNode.value &&
        targetNode.value.data &&
        targetNode.value.data.statusId
          ? targetNode.value.data.statusId
          : 0,
      );
      const targetStatus = computed(() =>
        data.value.statuses.find((s) => s.id === targetStatusId.value),
      );
      const sourceIssueStatusChipProps = computed<IssueStatusChipProps>(() => ({
        id: sourceStatusId.value,
        name: sourceStatus.value ? sourceStatus.value.name : "Unknown",
        isClosed: undefined,
        Position: undefined,
        description: undefined,
        defaultDoneRatio: undefined,
        icon: sourceStatusId.value === 0 ? "mdi-alert" : undefined,
        textColor: sourceStatusId.value === 0 ? "#B71C1C" : undefined,
        backgroundColor: sourceStatusId.value === 0 ? "#FFF176" : undefined,
      }));
      const targetIssueStatusChipProps = computed<IssueStatusChipProps>(() => ({
        id: targetStatusId.value,
        name: targetStatus.value ? targetStatus.value.name : "Unknown",
        isClosed: undefined,
        Position: undefined,
        description: undefined,
        defaultDoneRatio: undefined,
        icon: targetStatusId.value === 0 ? "mdi-alert" : undefined,
        textColor: targetStatusId.value === 0 ? "#B71C1C" : undefined,
        backgroundColor: targetStatusId.value === 0 ? "#FFF176" : undefined,
      }));
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
                VSpeedDial,
                {
                  location: "top center",
                  transition: "fade-transition",
                },
                {
                  activator: ({
                    isActive,
                    props,
                  }: {
                    isActive: boolean;
                    props: Record<string, any>;
                  }) =>
                    h(
                      VBtn,
                      {
                        ...props,
                        size: "16",
                        density: "comfortable",
                        icon: true,
                        variant: isActive ? "tonal" : "elevated",
                        color:
                          style.value && style.value.stroke
                            ? style.value.stroke
                            : "accent",
                      },
                      h(
                        VIcon,
                        { size: "12" },
                        isActive ? "mdi-close" : "mdi-dots-vertical",
                      ),
                    ),
                  default: () => [
                    h(VBtn, {
                      icon: "mdi-delete",
                      onClick: () => data.value.actions.removeEdges([id.value]),
                      color: "error",
                    }),
                    h(VBtn, {
                      icon: "mdi-cog",
                      onClick: () => {
                        showConfigurationDialog.value = true;
                      },
                      color: "accent",
                    }),
                  ],
                },
              ),
            ],
          ),
          h(VDialog, dialogProps.value, [
            h(
              VCard,
              {
                color: "background",
                minHeight: 40,
              },
              [
                h(
                  VToolbar,
                  {
                    color: "transparent",
                    flat: true,
                    dense: true,
                  },
                  [
                    h(
                      VToolbarTitle,
                      h("span", { class: ["d-flex"] }, [
                        h(
                          "div",
                          { class: ["d-flex", "align-center"] },
                          h(IssueStatusChip, sourceIssueStatusChipProps.value),
                        ),
                        h(
                          "div",
                          { class: ["d-flex", "align-center", "mx-2"] },
                          h(VIcon, "mdi-arrow-right-thick"),
                        ),
                        h(
                          "div",
                          { class: ["d-flex", "align-center"] },
                          h(IssueStatusChip, targetIssueStatusChipProps.value),
                        ),
                      ]),
                    ),
                    h(VToolbarItems, [
                      h(VBtn, {
                        icon: "mdi-close",
                        onClick: () => {
                          showConfigurationDialog.value = false;
                        },
                      }),
                    ]),
                  ],
                ),
                h(VDivider),
                h(
                  VTable,
                  {
                    class: ["transparent", "bg-transparent"],
                  },
                  [
                    h("thead", [
                      h("tr", [
                        h("th", {
                          class: ["font-weight-bold", "no-wrap"],
                        }),
                        h(
                          "th",
                          {
                            class: ["font-weight-bold", "no-wrap"],
                          },
                          t("pages.workflows.admin.roles.canTransition"),
                        ),
                        h(
                          "th",
                          {
                            class: ["font-weight-bold", "no-wrap"],
                          },
                          t("pages.workflows.admin.roles.author"),
                        ),
                        h(
                          "th",
                          {
                            class: ["font-weight-bold", "no-wrap"],
                          },
                          t("pages.workflows.admin.roles.assignee"),
                        ),
                      ]),
                    ]),
                    h("tbody", [
                      ...data.value.roles.map((role) => {
                        return h("tr", [
                          h("td", { class: "font-weight-bold" }, role.name),
                          h(
                            "td",
                            h(VSwitch, { color: "accent", hideDetails: true }),
                          ),
                          h(
                            "td",
                            h(VSwitch, { color: "accent", hideDetails: true }),
                          ),
                          h(
                            "td",
                            h(VSwitch, { color: "accent", hideDetails: true }),
                          ),
                        ]);
                      }),
                    ]),
                  ],
                ),
              ],
            ),
          ]),
        ]),
      ];
    },
  });

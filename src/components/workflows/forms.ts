/* eslint-disable vue/one-component-per-file */
import { defineComponent, computed, h, ref, watch } from "vue";
import { useI18n, I18nT } from "vue-i18n";
import { VBtn } from "vuetify/components/VBtn";
import { VIcon } from "vuetify/components/VIcon";
import { VDivider } from "vuetify/components/VDivider";
import {
  VToolbar,
  VToolbarTitle,
  VToolbarItems,
} from "vuetify/components/VToolbar";
import { IssueStatusChip } from "@/components/issues";

import type { PropType } from "vue";
import type { IssueStatus, Role } from "@/friday";
import type { Node, Edge, RemoveEdges, RemoveNodes } from "@vue-flow/core";
import type { IssueStatusFieldPermissions } from "@/components/workflows/nodes";
import type { IssueStatusTransitionRules } from "@/components/workflows/edges";
import type { IssueStatusChipProps } from "@/components/issues";

export const IssueStatusTransitionForm = defineComponent({
  name: "IssueStatusTransitionForm",
  props: {
    selection: {
      type: Object as PropType<Edge>,
      required: true,
    },
    remove: {
      type: Function as PropType<RemoveEdges>,
      required: true,
    },
    roles: {
      type: Array as PropType<Role[]>,
      required: true,
    },
    statuses: {
      type: Array as PropType<IssueStatus[]>,
      required: true,
    },
    nodes: {
      type: Array as PropType<Node[]>,
      required: true,
    },
  },
  emits: {
    close: () => true,
  },
  setup(props, { emit }) {
    const selection = computed(() => props.selection);
    const roles = computed(() => props.roles);
    const statuses = computed(() => props.statuses);
    const current = computed<IssueStatusTransitionRules>(
      () => selection.value.data.current,
    );
    const { t } = useI18n({ useScope: "global" });
    const sourceNodeId = computed(() => selection.value?.source || "");
    const targetNodeId = computed(() => selection.value?.target || "");
    const sourceNode = computed(() =>
      props.nodes.find((n) => n.id === sourceNodeId.value),
    );
    const targetNode = computed(() =>
      props.nodes.find((n) => n.id === targetNodeId.value),
    );
    const sourceStatusId = computed(() => {
      if (sourceNode.value?.type === "tracker-workflow-start") {
        return -1;
      }
      return sourceNode.value &&
        sourceNode.value.data &&
        sourceNode.value.data.statusId
        ? sourceNode.value.data.statusId
        : 0;
    });
    const sourceStatus = computed(() => {
      if (sourceNode.value?.type === "tracker-workflow-start") {
        const ret: IssueStatus = {
          id: -1,
          name: t("pages.workflows.admin.trackerWorkflowStart.name"),
          is_closed: false,
          position: -1,
          description: t(
            "pages.workflows.admin.trackerWorkflowStart.description",
          ),
          default_done_ratio: null,
          icon: "mdi-import",
          text_color: "#FFFFFF",
          background_color: "#9E9E9E",
        };
        return ret;
      }
      return statuses.value.find((s) => s.id === sourceStatusId.value);
    });
    const targetStatusId = computed(() =>
      targetNode.value &&
      targetNode.value.data &&
      targetNode.value.data.statusId
        ? targetNode.value.data.statusId
        : 0,
    );
    const targetStatus = computed(() =>
      statuses.value.find((s) => s.id === targetStatusId.value),
    );
    const sourceIssueStatusChipProps = computed<IssueStatusChipProps>(() => ({
      id: sourceStatusId.value,
      name: sourceStatus.value ? sourceStatus.value.name : "Unknown",
      isClosed: undefined,
      Position: undefined,
      description: undefined,
      defaultDoneRatio: undefined,
      icon:
        sourceStatusId.value === 0
          ? "mdi-alert"
          : sourceStatus.value?.icon || undefined,
      textColor:
        sourceStatusId.value === 0
          ? "#B71C1C"
          : sourceStatus.value?.text_color || undefined,
      backgroundColor:
        sourceStatusId.value === 0
          ? "#FFF176"
          : sourceStatus.value?.background_color || undefined,
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
    const doDelete = () => {
      emit("close");
      props.remove([selection.value.id]);
    };
    return () =>
      h("div", { class: "issue-status-transition-form" }, [
        h(
          VToolbar,
          {
            color: "transparent",
            density: "compact",
          },
          [
            h(VToolbarTitle, [
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
            ]),
            h(VToolbarItems, [
              h(
                VBtn,
                {
                  onClick: () => {
                    doDelete();
                  },
                  color: "warning",
                },
                t("pages.workflows.admin.remove.edge"),
              ),
              h(VBtn, {
                icon: "mdi-close",
                onClick: () => {
                  emit("close");
                },
              }),
            ]),
          ],
        ),
        h(VDivider),
      ]);
  },
});

export const IssueStatusRestrictionsForm = defineComponent({
  name: "IssueStatusRestrictionsForm",
  props: {
    selection: {
      type: Object as PropType<Node>,
      required: true,
    },
    remove: {
      type: Function as PropType<RemoveNodes>,
      required: true,
    },
    roles: {
      type: Array as PropType<Role[]>,
      required: true,
    },
    statuses: {
      type: Array as PropType<IssueStatus[]>,
      required: true,
    },
  },
  emits: {
    close: () => true,
  },
  setup(props, { emit }) {
    const selection = computed(() => props.selection);
    const roles = computed(() => props.roles);
    const statuses = computed(() => props.statuses);
    const current = computed<IssueStatusFieldPermissions>(
      () => selection.value.data.current,
    );
    const { t } = useI18n({ useScope: "global" });
    const statusId = computed(() => selection.value?.data.statusId || 0);
    const issueStatus = computed(() =>
      statuses.value.find((s) => s.id === statusId.value),
    );
    const doDelete = () => {
      emit("close");
      props.remove([selection.value.id]);
    };
    const issueStatusChipProps = computed<IssueStatusChipProps>(() => ({
      id: issueStatus.value?.id || 0,
      name: issueStatus.value?.name || "",
      isClosed: undefined,
      Position: undefined,
      description: undefined,
      defaultDoneRatio: undefined,
      icon: !issueStatus.value ? "mdi-alert" : undefined,
      textColor: !issueStatus.value ? "#B71C1C" : undefined,
      backgroundColor: !issueStatus.value ? "#FFF176" : undefined,
    }));
    return () =>
      h("div", { class: "issue-status-restrictions-form" }, [
        h(
          VToolbar,
          {
            color: "transparent",
            density: "compact",
          },
          [
            h(VToolbarTitle, [
              h(
                "span",
                {
                  class: "d-flex",
                },
                h(
                  I18nT,
                  {
                    keypath: "pages.workflows.admin.fieldPermissions.title",
                  },
                  {
                    status: () =>
                      h(
                        "div",
                        {
                          class: "d-flex align-center me-2",
                        },
                        h(IssueStatusChip, issueStatusChipProps.value),
                      ),
                  },
                ),
              ),
            ]),
            h(VToolbarItems, [
              h(
                VBtn,
                {
                  onClick: () => {
                    doDelete();
                  },
                  color: "warning",
                },
                t("pages.workflows.admin.remove.node"),
              ),
              h(VBtn, {
                icon: "mdi-close",
                onClick: () => {
                  emit("close");
                },
              }),
            ]),
          ],
        ),
        h(VDivider),
      ]);
  },
});

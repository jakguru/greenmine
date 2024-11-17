import { defineComponent, computed, h, ref, onMounted } from "vue";
import { useI18n, I18nT } from "vue-i18n";
import { Handle, Position } from "@vue-flow/core";
import { NodeToolbar } from "@vue-flow/node-toolbar";
import { IssueStatusChip } from "@/components/issues";
import { VCard } from "vuetify/components/VCard";
import { VBtn } from "vuetify/components/VBtn";
import { VDivider } from "vuetify/components/VDivider";
import { VTable } from "vuetify/components/VTable";
import { VSelect } from "vuetify/components/VSelect";
import { VBadge } from "vuetify/components/VBadge";
import {
  VToolbar,
  VToolbarTitle,
  VToolbarItems,
} from "vuetify/components/VToolbar";
import { VDialog } from "vuetify/components/VDialog";
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
  RemoveNodes,
} from "@vue-flow/core";
import type { Role, FieldByTracker } from "@/friday";

export interface IssueStatusNodeData {
  statusId: number;
  statusName: string;
  forNewIssue?: boolean;
  preselectedStatusesFromForNew: number[];
  actions: {
    removeNodes: RemoveNodes;
  };
  roles: Role[];
  fieldsForTracker: FieldByTracker | undefined;
}

export const IssueStatusNodeDataSchema = Joi.object<IssueStatusNodeData>({
  statusId: Joi.number().required().min(0),
  statusName: Joi.string().required(),
  forNewIssue: Joi.boolean().optional().default(false),
  preselectedStatusesFromForNew: Joi.array().items(Joi.number()).default([]),
  actions: Joi.object({
    removeNodes: Joi.function()
      .required()
      .default(() => {}),
  }).required(),
  roles: Joi.array()
    .items(
      Joi.object({
        id: Joi.number().required(),
        name: Joi.string().required(),
        position: Joi.number().required(),
      }),
    )
    .required(),
  fieldsForTracker: Joi.object({
    trackerId: Joi.number().required(),
    coreFields: Joi.array()
      .items(
        Joi.object({
          value: Joi.string().required(),
          label: Joi.string().required(),
          required: Joi.boolean().required(),
        }),
      )
      .required(),
    issueCustomFields: Joi.array()
      .items(
        Joi.object({
          value: Joi.number().required(),
          label: Joi.string().required(),
          required: Joi.boolean().required(),
        }),
      )
      .required(),
  }).optional(),
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
    const { t } = useI18n({ useScope: "global" });
    const id = computed(() => props.id);
    const getIssueStatusNodeData = (data: unknown): IssueStatusNodeData => {
      const { value, error } = IssueStatusNodeDataSchema.validate(data);
      if (error) {
        return {
          statusId: 0,
          statusName: error.message,
          forNewIssue: false,
          preselectedStatusesFromForNew: [],
          actions: {
            removeNodes: () => {},
          },
          roles: [],
          fieldsForTracker: undefined,
        };
      }
      return value;
    };
    const data = computed(() => getIssueStatusNodeData(props.data));
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
    const removable = computed(
      () =>
        data.value.statusId !== 0 &&
        Array.isArray(data.value.preselectedStatusesFromForNew) &&
        !data.value.preselectedStatusesFromForNew.includes(data.value.statusId),
    );
    const showControls = ref(false);
    const nodeToolbarProps = computed(() => ({
      position: Position.Bottom,
      nodeId: id.value,
      isVisible: showControls.value,
    }));
    const nodeToolbarCardProps = computed(() => ({
      color: "background",
    }));
    const showSettingsDialog = ref(false);
    const nodeToolbarCardChildren = computed(() => [
      h(VBtn, {
        color: "error",
        icon: "mdi-delete",
        disabled: !removable.value,
        onClick: () => {
          data.value.actions.removeNodes(id.value);
        },
      }),
      h(VBtn, {
        color: "accent",
        icon: "mdi-cog",
        onClick: () => {
          showSettingsDialog.value = true;
        },
      }),
    ]);
    const fieldsForTracker = computed(
      () =>
        data.value.fieldsForTracker || {
          trackerId: 0,
          coreFields: [],
          issueCustomFields: [],
        },
    );
    const dialogProps = computed(() => ({
      modelValue: showSettingsDialog.value,
      "onUpdate:modelValue": (v: boolean) => {
        showSettingsDialog.value = v;
      },
      maxWidth: 200 * (data.value.roles.length + 1),
    }));
    const fieldPermissionItemsForRequired = [
      {
        value: "",
        title: t("pages.workflows.admin.fieldPermissions.unrestrictied"),
      },
      {
        value: "readonly",
        title: t("pages.workflows.admin.fieldPermissions.readonly"),
      },
    ];
    const fieldPermissionItemsForUnrequired = [
      {
        value: "",
        title: t("pages.workflows.admin.fieldPermissions.unrestrictied"),
      },
      {
        value: "readonly",
        title: t("pages.workflows.admin.fieldPermissions.readonly"),
      },
      {
        value: "required",
        title: t("pages.workflows.admin.fieldPermissions.required"),
      },
    ];
    const topLevelNodes = computed(() =>
      [
        h(NodeToolbar, nodeToolbarProps.value, [
          h(VCard, nodeToolbarCardProps.value, [
            h(
              VToolbar,
              {
                color: "transparent",
                density: "compact",
              },
              [h(VToolbarItems, nodeToolbarCardChildren.value)],
            ),
          ]),
        ]),
        data.value.forNewIssue
          ? undefined
          : h(Handle, {
              id: "in",
              type: "target",
              position: Position.Top,
            }),
        h(IssueStatusChip, issueStatusChipProps.value),
        h(Handle, {
          id: "out",
          type: "source",
          position: Position.Bottom,
        }),
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
                  h(VToolbarTitle, [
                    h(
                      "span",
                      {
                        class: "d-flex",
                      },
                      h(
                        I18nT,
                        {
                          keypath:
                            "pages.workflows.admin.fieldPermissions.title",
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
                    h(VBtn, {
                      icon: "mdi-close",
                      onClick: () => {
                        showSettingsDialog.value = false;
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
                      ...data.value.roles.map((role) => {
                        return h(
                          "th",
                          {
                            width: "200",
                            class: ["font-weight-bold", "no-wrap"],
                          },
                          role.name,
                        );
                      }),
                    ]),
                  ]),
                  h("tbody", [
                    ...fieldsForTracker.value.coreFields.map((field) => {
                      return h("tr", [
                        h(
                          "td",
                          { class: ["font-weight-bold", "no-wrap"] },
                          h(
                            VBadge,
                            {
                              color: "red",
                              dot: true,
                              modelValue: field.required,
                              floating: true,
                            },
                            field.label,
                          ),
                        ),
                        ...data.value.roles.map((_role) => {
                          return h(
                            "td",
                            { width: "200" },
                            h(VSelect, {
                              items: field.required
                                ? fieldPermissionItemsForRequired
                                : fieldPermissionItemsForUnrequired,
                              density: "compact",
                              modelValue: "",
                            }),
                          );
                        }),
                      ]);
                    }),
                    ...fieldsForTracker.value.issueCustomFields.map((field) => {
                      return h("tr", [
                        h(
                          "td",
                          { class: ["font-weight-bold"] },
                          h(
                            VBadge,
                            {
                              color: "red",
                              dot: true,
                              modelValue: field.required,
                              floating: true,
                            },
                            field.label,
                          ),
                        ),
                        ...data.value.roles.map((_role) => {
                          return h(
                            "td",
                            { width: "180" },
                            h(VSelect, {
                              items: field.required
                                ? fieldPermissionItemsForRequired
                                : fieldPermissionItemsForUnrequired,
                              density: "compact",
                              modelValue: "",
                            }),
                          );
                        }),
                      ]);
                    }),
                  ]),
                ],
              ),
            ],
          ),
        ]),
      ].filter((n) => "undefined" !== typeof n),
    );
    onMounted(() => {
      if (window) {
        window.addEventListener("click", () => {
          showControls.value = false;
        });
      }
    });
    return () =>
      h(
        "div",
        {
          class: "issue-status-node",
          onClick: (e: MouseEvent) => {
            e.preventDefault();
            e.stopPropagation();
            showControls.value = true;
          },
        },
        topLevelNodes.value,
      );
  },
});

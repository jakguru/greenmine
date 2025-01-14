<template>
  <v-container fluid class="workflow-management">
    <v-card min-height="100" color="surface">
      <v-toolbar color="transparent" density="compact">
        <v-toolbar-title class="font-weight-bold d-flex align-center" tag="h1">
          <v-icon size="20" class="me-3" style="position: relative; top: -2px">
            mdi-arrow-decision
          </v-icon>
          {{ $t("pages.workflows.admin.title") }}
        </v-toolbar-title>
      </v-toolbar>
      <v-divider />
      <v-tabs v-bind="vTabBindings" />
      <v-divider />
      <v-sheet v-bind="workflowEditorWrapperBindings">
        <v-layout full-height>
          <div class="w-100 h-100">
            <VueFlow v-bind="vueFlowProps">
              <Background />
              <template #node-issue-status="bindings">
                <IssueStatusNode v-bind="bindings" />
              </template>
              <template #edge-issue-status-transition="bindings">
                <IssueStatusTransitionEdge
                  v-bind="bindings"
                  @button:click="
                    (id) => setFocusOn('issue-status-transition', id)
                  "
                />
              </template>
              <template #node-tracker-workflow-start="bindings">
                <TrackerWorkflowStartNode v-bind="bindings" />
              </template>
            </VueFlow>
          </div>
          <v-navigation-drawer v-bind="sidebarBindings">
            <template #append>
              <v-btn
                class="sidebar-toggle"
                color="accent"
                variant="elevated"
                size="x-small"
                elevation="5"
                @click="sidebarOpen = !sidebarOpen"
              >
                <v-icon>{{
                  sidebarOpen ? "mdi-menu-up" : "mdi-menu-down"
                }}</v-icon>
              </v-btn>
            </template>
            <template v-if="'issue-status' === focus.type">
              <IssueStatusRestrictionsForm
                v-bind="issueStatusRestrictionsFormProps"
              />
            </template>
            <template v-else-if="'issue-status-transition' === focus.type">
              <IssueStatusTransitionForm
                v-bind="issueStatusTransitionFormProps"
              />
            </template>
            <template v-else>
              <v-toolbar color="transparent" density="compact">
                <v-toolbar-title>
                  {{ $t("pages.workflows.admin.sidebar.addStatuses.title") }}
                </v-toolbar-title>
                <v-toolbar-items>
                  <v-btn icon="mdi-close" @click="sidebarOpen = false" />
                </v-toolbar-items>
              </v-toolbar>
              <v-divider />
              <v-virtual-scroll v-bind="remainingStatusesVirtualScrollerProps">
                <template #default="{ item: status }">
                  <v-list-item>
                    <IssueStatusChip :id="status.id" :name="status.name" />
                    <template #append>
                      <v-btn
                        icon="mdi-plus"
                        color="accent"
                        size="x-small"
                        class="ms-2"
                        @click="doAddStatus(status)"
                      />
                    </template>
                  </v-list-item>
                </template>
              </v-virtual-scroll>
            </template>
          </v-navigation-drawer>
          <v-speed-dial
            app
            location="bottom center"
            transition="fade-transition"
            absolute
            attach="parent"
          >
            <template #activator="{ props: activatorProps }">
              <v-fab
                v-bind="activatorProps"
                color="accent"
                :icon="true"
                z-index="5"
                app
                location="top left"
                style="width: 72px !important"
              >
                <v-badge v-bind="speedDialBadgeProps">
                  <template v-if="saving" #badge>
                    <v-progress-circular
                      indeterminate
                      size="20"
                      color="primary"
                    />
                  </template>
                  <v-icon>mdi-wrench</v-icon>
                </v-badge>
              </v-fab>
            </template>

            <v-btn
              key="1"
              color="accent"
              size="x-small"
              icon="mdi-content-save"
              :loading="saving"
              @click="doSave"
            />
            <v-btn
              key="2"
              color="accent"
              size="x-small"
              icon="mdi-restore"
              @click="resetNodes"
            />
            <v-btn
              key="3"
              color="accent"
              size="x-small"
              icon="mdi-fit-to-screen-outline"
              @click="fitView"
            />
            <v-btn
              key="4"
              color="accent"
              size="x-small"
              icon="mdi-relation-one-to-one"
              @click="organizeWithDagre"
            />
            <v-btn
              key="5"
              color="accent"
              size="x-small"
              icon="mdi-content-copy"
              @click="showCopyFromDialog = true"
            />
          </v-speed-dial>
          <v-dialog v-model="showCopyFromDialog" max-width="400" contained>
            <v-card color="surface">
              <v-toolbar color="transparent" density="compact">
                <v-toolbar-title>
                  {{ $t("pages.workflows.admin.copyFrom.title") }}
                </v-toolbar-title>
                <v-toolbar-items>
                  <v-btn icon @click="showCopyFromDialog = false">
                    <v-icon>mdi-close</v-icon>
                  </v-btn>
                </v-toolbar-items>
              </v-toolbar>
              <v-divider />
              <v-container fluid>
                <v-autocomplete
                  v-model="copyFromTrackerId"
                  :items="[...trackers].filter((t) => t.id !== tracker?.id)"
                  item-title="name"
                  item-value="id"
                  :label="$t('pages.workflows.admin.copyFrom.field')"
                  dense
                  outlined
                  hide-details
                  :disabled="copying"
                />
              </v-container>
              <v-divider />
              <v-card-actions>
                <v-spacer />
                <v-btn color="accent" :loading="copying" @click="doCopyFrom">
                  {{ $t("pages.workflows.admin.copyFrom.copy") }}
                </v-btn>
              </v-card-actions>
            </v-card>
          </v-dialog>
        </v-layout>
      </v-sheet>
    </v-card>
  </v-container>
</template>

<script lang="ts">
import {
  defineComponent,
  computed,
  ref,
  nextTick,
  markRaw,
  watch,
  inject,
  onMounted,
  onBeforeUnmount,
} from "vue";
import { useI18n } from "vue-i18n";
import { useAppData, cloneObject, useReloadRouteData } from "@/utils/app";
import { useRoute, useRouter } from "vue-router";
import {
  VueFlow,
  useVueFlow,
  MarkerType,
  ConnectionMode,
} from "@vue-flow/core";
import { Background } from "@vue-flow/background";
import {
  useLayout,
  checkNodeListEquality,
  checkEdgeListEquality,
} from "@/utils/flowchart";
import { useDisplay } from "vuetify";
import {
  IssueStatusNode,
  TrackerWorkflowStartNode,
} from "@/components/workflows/nodes";
import { IssueStatusTransitionEdge } from "@/components/workflows/edges";
import {
  IssueStatusTransitionForm,
  IssueStatusRestrictionsForm,
} from "@/components/workflows/forms";
import { IssueStatusChip } from "@/components/issues";
import { getDebugger } from "@jakguru/vueprint/utilities/debug";

const debug = getDebugger("Friday:Workflows", "#62B682", "#FFFFFF");

import type { PropType } from "vue";
import type {
  Node,
  Edge,
  Connection,
  EdgeUpdateEvent,
  NodeTypesObject,
  EdgeTypesObject,
  NodeMouseEvent,
  EdgeMouseEvent,
} from "@vue-flow/core";
import type { IssueStatus, TruncatedRole, WorkflowTracker } from "@/friday";
import type {
  SwalService,
  ToastService,
  ApiService,
  BusService,
} from "@jakguru/vueprint";
import type { IssueStatusTransitionProps } from "@/components/workflows/edges";
import type { RealtimeApplicationUpdateEventWithTabUUIDPayload } from "@/utils/realtime";

export default defineComponent({
  name: "WorkflowsIndex",
  components: {
    VueFlow,
    Background,
    IssueStatusChip,
    IssueStatusNode,
    TrackerWorkflowStartNode,
    IssueStatusTransitionEdge,
    IssueStatusTransitionForm,
    IssueStatusRestrictionsForm,
  },
  props: {
    formAuthenticityToken: {
      type: String,
      required: true,
    },
    tracker: {
      type: Object as PropType<WorkflowTracker | null>,
      default: null,
    },
    trackers: {
      type: Array as PropType<WorkflowTracker[]>,
      required: true,
    },
  },
  setup(props) {
    const { t } = useI18n({ useScope: "global" });
    const { height, width } = useDisplay();
    const swal = inject<SwalService>("swal");
    const toast = inject<ToastService>("toast");
    const api = inject<ApiService>("api");
    const bus = inject<BusService>("bus");
    const formAuthenticityToken = computed(() => props.formAuthenticityToken);
    const tracker = computed(() => props.tracker);
    const trackers = computed(() => props.trackers);
    const firstTracker = computed(() => trackers.value[0]);
    const firstTrackerId = computed(() =>
      firstTracker.value ? firstTracker.value.id : 0,
    );
    const appData = useAppData();
    const roles = computed<TruncatedRole[]>(() => appData.value.roles);
    const statuses = computed<IssueStatus[]>(() => appData.value.statuses);
    const route = useRoute();
    const router = useRouter();
    const routeDataReloader = useReloadRouteData(route, api, toast);
    const onRtuWorkflows = (
      data: RealtimeApplicationUpdateEventWithTabUUIDPayload,
    ) => {
      if (data.from === bus?.uuid) {
        return;
      }
      debug("onRtuWorkflows", data);
      const { nodes, edges } = data;
      const trkr = Object.assign({}, cloneObject(tracker.value), {
        nodes,
        edges,
      });
      updateNodesFromTrackerUpdate(trkr).then(() => {
        updateEdgesFromTrackerUpdate(trkr);
      });
    };
    const onRtuUpdate = () => {
      if (!routeDataReloader.loading.value) {
        routeDataReloader.call();
      }
    };
    onMounted(() => {
      if (bus) {
        bus.on("rtu:workflows", onRtuWorkflows, { local: true });
        bus.on("rtu:trackers", onRtuUpdate, { local: true });
      }
    });
    onBeforeUnmount(() => {
      if (bus) {
        bus.off("rtu:workflows", onRtuWorkflows);
        bus.off("rtu:trackers", onRtuUpdate);
      }
    });
    const {
      fitView,
      removeEdges,
      removeNodes,
      addEdges,
      updateEdge,
      applyNodeChanges,
      applyEdgeChanges,
      addNodes,
      setNodes,
      setEdges,
      updateNodeData,
      updateEdgeData,
    } = useVueFlow();
    const tabs = computed(() =>
      [...trackers.value].map((t) => ({
        text: t.name,
        value: t.id.toString(),
        color: t.color,
        baseColor: t.color,
        prependIcon: t.icon,
      })),
    );
    const tab = computed({
      get: () =>
        (route.query.tracker as string | undefined) ??
        firstTrackerId.value.toString(),
      set: (v: string) => {
        router.push({ query: { tracker: v.toString() } });
      },
    });
    const vTabBindings = computed(() => ({
      modelValue: tab.value,
      items: tabs.value,
      density: "compact" as const,
      mandatory: true,
      showArrows: true,
      sliderColor: "accent",
      "onUpdate:modelValue": (v: unknown) => {
        if (typeof v === "string") {
          tab.value = v;
        }
      },
    }));
    const workflowEditorWrapperBindings = computed(() => ({
      width: "100%",
      height: height.value - 220,
      minHeight: 400,
      color: "transparent" as const,
      style: {
        position: "relative" as const,
      },
    }));
    const sidebarOpen = ref(false);
    const focusType = ref<
      | null
      | "tracker-workflow-start"
      | "issue-status"
      | "issue-status-transition"
    >(null);
    const focusId = ref<null | string>(null);
    const focus = computed(() => ({
      type: focusType.value,
      id: focusId.value,
    }));
    const sidebarWidth = computed(() => {
      if (!sidebarOpen.value) {
        return 256;
      }
      switch (focusType.value) {
        case "issue-status-transition":
          return 600;
        case "issue-status":
          return 200 * (roles.value.length + 1);
        case null:
        default:
          return 256;
      }
    });
    const sidebarBindings = computed(() => ({
      absolute: true,
      color: "surface" as const,
      location: "right" as const,
      modelValue: sidebarOpen.value,
      "onUpdate:modelValue": (v: boolean) => {
        sidebarOpen.value = v;
      },
      class: ["workflow-management-sidebar"],
      style: {
        height: "100%",
        top: 0,
        bottom: 0,
      },
      permanent: true,
      app: false,
      elevation: sidebarOpen.value ? 5 : 0,
      width: sidebarWidth.value,
      maxWidth: width.value - 62,
    }));
    const initialCoreFieldRestrictions = computed(() =>
      Object.assign(
        {},
        ...roles.value.map((r) => ({
          [r.id.toString()]: !tracker.value
            ? {}
            : Object.assign(
                {},
                ...tracker.value.coreFields.map((f) => ({
                  [f.value.toString()]: "",
                })),
              ),
        })),
      ),
    );
    const initialCustomFieldRestrictions = computed(() =>
      Object.assign(
        {},
        ...roles.value.map((r) => ({
          [r.id.toString()]: !tracker.value
            ? {}
            : Object.assign(
                {},
                ...tracker.value.issueCustomFields.map((f) => ({
                  [f.value.toString()]: "",
                })),
              ),
        })),
      ),
    );
    const initialFieldRestrictions = computed(() => ({
      coreFields: initialCoreFieldRestrictions.value,
      customFields: initialCustomFieldRestrictions.value,
    }));
    const initialTransitionRestrictions = computed(() =>
      Object.assign(
        {},
        ...roles.value.map((r) => ({
          [r.id.toString()]: {
            always: false,
            author: false,
            assignee: false,
          },
        })),
      ),
    );
    const updateCurrentFieldRestrictonsForNodes = () => {
      nodes.value.forEach((n) => {
        if (n.type === "issue-status") {
          const data = cloneObject(n.data);
          data.current = Object.assign(
            {},
            cloneObject(initialFieldRestrictions.value),
            n.data.current,
          );
          updateNodeData(n.id, data);
        }
      });
    };
    const updateCurrentTransitionRestrictionsForEdges = () => {
      edges.value.forEach((e) => {
        if (e.type === "issue-status-transition") {
          const data = cloneObject(e.data);
          data.current = Object.assign(
            {},
            cloneObject(initialTransitionRestrictions.value),
            e.data.current,
          );
          updateEdgeData(e.id, data);
        }
      });
    };
    watch(() => roles.value, updateCurrentFieldRestrictonsForNodes, {
      deep: true,
    });
    watch(() => roles.value, updateCurrentTransitionRestrictionsForEdges, {
      deep: true,
    });
    const remainingStatusesVirtualScrollerProps = computed(() => ({
      items: remainingStatuses.value,
      height:
        remainingStatuses.value.length > 0
          ? workflowEditorWrapperBindings.value.height - 49
          : workflowEditorWrapperBindings.value.height - 97,
    }));
    const doAddStatus = (status: IssueStatus) => {
      let x = 0;
      nodes.value.forEach((n) => {
        if (n.position.x >= x) {
          x = n.position.x;
        }
      });
      if (x > 0) {
        x += 100;
      }
      if (x === 0 && nodes.value.length > 0) {
        x += 100;
      }
      const node: Node = {
        id: `issue-status-${status.id}`,
        type: "issue-status",
        data: {
          statusId: status.id,
          statusName: status.name,
          current: cloneObject(initialFieldRestrictions.value),
        },
        position: { x, y: 0 },
      };
      addNodes([node]);
    };
    const nodeTypes: NodeTypesObject = {
      "issue-status": markRaw(IssueStatusNode),
      "tracker-workflow-start": markRaw(TrackerWorkflowStartNode),
    };
    const edgeTypes: EdgeTypesObject = {
      "issue-status-transition": markRaw(IssueStatusTransitionEdge),
    };
    const startNode = {
      id: "start-node",
      type: "tracker-workflow-start",
      data: {},
      position: { x: 0, y: 0 },
    };
    const nodes = ref<Node[]>([startNode]);
    const edges = ref<Edge[]>([]);
    const remainingStatuses = computed(() =>
      [...statuses.value].filter((s) =>
        nodes.value.every((n) => n.id !== `issue-status-${s.id}`),
      ),
    );
    onMounted(() => {
      if (remainingStatuses.value.length > 0) {
        sidebarOpen.value = true;
      }
    });
    const resetNodes = () => {
      setNodes([startNode]);
      setEdges([]);
    };
    const updateNodesFromTrackerUpdate = async (trkr: WorkflowTracker) => {
      const { nodes: updatedList } = trkr;
      const hasStartNode = updatedList.some((n) => n.id === "start-node");
      if (!hasStartNode) {
        updatedList.unshift(startNode);
      }
      await setNodes(updatedList);
    };
    const updateEdgesFromTrackerUpdate = async (trkr: WorkflowTracker) => {
      const { edges: updatedList } = trkr;
      const updatedListOfEdges = updatedList.map((connection) => {
        const sourceNode = nodes.value.find(
          (n) => n.id === connection.source,
        ) as Node;
        const sourceNodeStatusId = sourceNode ? sourceNode.data.statusId : 0;
        const sourceStatus = statuses.value.find(
          (s) => s.id === sourceNodeStatusId,
        );
        let transitionColor =
          sourceNode.type === "tracker-workflow-start" ? "#62B682" : "#fdab3d";
        if (sourceStatus) {
          if (sourceStatus.background_color) {
            transitionColor = sourceStatus.background_color;
          } else if (sourceStatus.is_closed) {
            transitionColor = "#323338";
          }
        }
        const partialEdge: any = {
          ...connection,
          source: connection.source!,
          target: connection.target!,
          markerEnd: MarkerType.ArrowClosed,
          animated: true,
          style: {
            stroke: transitionColor,
            strokeWidth: 2,
          },
        };
        return partialEdge;
      });
      await setEdges(updatedListOfEdges);
    };
    watch(
      () => tracker.value,
      (trkr) => {
        if (!trkr) {
          debug("Tracker is updated to non-existing. Resetting Nodes");
          resetNodes();
          return;
        } else {
          debug("Tracker is updated to existing. Updating Nodes and Edges");
        }
        updateNodesFromTrackerUpdate(trkr).then(() => {
          updateEdgesFromTrackerUpdate(trkr);
        });
      },
      { deep: true },
    );
    onMounted(() => {
      const trkr = tracker.value ? cloneObject(tracker.value) : null;
      if (!trkr) {
        debug("Tracker is non-existing. Resetting Nodes");
        resetNodes();
        return;
      } else {
        debug("Tracker is existing. Updating Nodes and Edges");
      }
      updateNodesFromTrackerUpdate(trkr).then(() => {
        updateEdgesFromTrackerUpdate(trkr);
      });
    });
    let clearFocusTimeout: NodeJS.Timeout | undefined;
    const setFocusOn = (
      type:
        | "tracker-workflow-start"
        | "issue-status"
        | "issue-status-transition",
      id: string,
    ) => {
      if (clearFocusTimeout) {
        clearTimeout(clearFocusTimeout);
      }
      focusType.value = type;
      focusId.value = id;
      sidebarOpen.value = true;
    };
    const selection = computed<Node | Edge | undefined>(() => {
      if (!focus.value) {
        return;
      }
      switch (focus.value.type) {
        case "issue-status":
          return nodes.value.find((n) => n.id === focus.value.id);
        case "issue-status-transition":
          return edges.value.find((e) => e.id === focus.value.id);
        default:
          return undefined;
      }
    });
    const clearFocus = () => {
      sidebarOpen.value = false;
      if (clearFocusTimeout) {
        clearTimeout(clearFocusTimeout);
      }
      clearFocusTimeout = setTimeout(() => {
        focusType.value = null;
        focusId.value = null;
      }, 300);
    };
    const vueFlowProps = computed(() => ({
      nodes: nodes.value,
      edges: edges.value,
      "onUpdate:nodes": (v: Node[]) => {
        nodes.value = v;
      },
      "onUpdate:edges": (v: Edge[]) => {
        edges.value = v;
      },
      edgesUpdatable: true,
      nodeTypes,
      edgeTypes,
      defaultEdgeOptions: { type: "issue-status-transition" },
      connectionLineOptions: {
        markerEnd: MarkerType.Arrow,
      },
      fitViewOnInit: true,
      snapToGrid: true,
      connectionMode: ConnectionMode.Strict,
      nodesConnectable: true,
      elevateEdgesOnSelect: true,
      onPaneClick: () => {
        clearFocus();
      },
      onNodeClick: (e: NodeMouseEvent) => {
        switch (e.node.type) {
          case "tracker-workflow-start":
          case "issue-status":
            setFocusOn(e.node.type, e.node.id);
            break;
          default:
            clearFocus();
            break;
        }
      },
      onEdgeClick: (e: EdgeMouseEvent) => {
        switch (e.edge.type) {
          case "issue-status-transition":
            setFocusOn(e.edge.type, e.edge.id);
            break;
          default:
            clearFocus();
            break;
        }
      },
    }));
    const { onConnect, onEdgeUpdate, onNodesChange, onEdgesChange } =
      useVueFlow();
    onConnect((connection: Connection) => {
      if (connection.source === connection.target) {
        if (swal) {
          swal.fire({
            title: t("pages.workflows.admin.error.connection.title"),
            text: t("pages.workflows.admin.error.connection.selfConnection"),
            icon: "error",
          });
        }
        return;
      }
      if (connection.sourceHandle !== "out") {
        if (toast) {
          toast.fire({
            text: t("pages.workflows.admin.error.connection.sourceMustBeOut"),
            icon: "error",
          });
        }
        return;
      }
      if (connection.targetHandle !== "in") {
        if (toast) {
          toast.fire({
            text: t("pages.workflows.admin.error.connection.targetMustBeIn"),
            icon: "error",
          });
        }
        return;
      }
      const sourceNode = nodes.value.find(
        (n) => n.id === connection.source,
      ) as Node;
      const sourceNodeStatusId = sourceNode ? sourceNode.data.statusId : 0;
      const sourceStatus = statuses.value.find(
        (s) => s.id === sourceNodeStatusId,
      );
      let transitionColor =
        sourceNode.type === "tracker-workflow-start" ? "#62B682" : "#fdab3d";
      if (sourceStatus) {
        if (sourceStatus.background_color) {
          transitionColor = sourceStatus.background_color;
        } else if (sourceStatus.is_closed) {
          transitionColor = "#323338";
        }
      }
      const partialEdge: Partial<IssueStatusTransitionProps> & {
        source: string;
        target: string;
      } = {
        ...connection,
        source: connection.source!,
        target: connection.target!,
        markerEnd: MarkerType.ArrowClosed,
        animated: true,
        data: {
          current: cloneObject(initialTransitionRestrictions.value),
        },
        style: {
          stroke: transitionColor,
          strokeWidth: 2,
        },
      };
      addEdges([partialEdge]);
    });
    onEdgeUpdate(({ edge, connection }: EdgeUpdateEvent) => {
      updateEdge(edge, connection);
    });
    onNodesChange((changes) => {
      applyNodeChanges(changes);
    });
    onEdgesChange((changes) => {
      applyEdgeChanges(changes);
    });
    let doSaveAbortController: AbortController | undefined;
    const saving = ref(false);
    const dirty = ref(false);
    const doSave = async (showFeedback: boolean = false) => {
      if (!api) {
        return;
      }
      if (doSaveAbortController) {
        doSaveAbortController.abort();
      }
      doSaveAbortController = new AbortController();
      saving.value = true;
      const payload = cloneObject({
        formAuthenticityToken: formAuthenticityToken.value,
        trackerId: parseInt(tab.value),
        nodes: nodes.value,
        edges: edges.value,
        status_ids_for_new: {},
        from: bus ? bus.uuid : "",
      });
      try {
        const { status } = await api.patch(`/workflows/update`, payload, {
          signal: doSaveAbortController.signal,
        });
        if (status !== 201) {
          if (toast) {
            toast.fire({
              text: t("pages.workflows.admin.error.saveFailed"),
              icon: "error",
            });
          }
        } else if (showFeedback && toast) {
          toast.fire({
            text: t("pages.workflows.admin.success.saveSuccess"),
            icon: "success",
          });
        }
        if (status === 201) {
          dirty.value = false;
        }
      } catch {
        // noop
      }
      saving.value = false;
    };
    let autoSaveTimeout: NodeJS.Timeout | undefined;
    const previousNodes = ref<Node[]>([]);
    const previousEdges = ref<Edge[]>([]);
    watch(
      () => nodes.value,
      () => {
        if (
          checkNodeListEquality(
            cloneObject(nodes.value),
            cloneObject(previousNodes.value),
          )
        ) {
          return;
        }
        debug("Nodes are not equal. Setting dirty and starting save");
        previousNodes.value = cloneObject(nodes.value);
        dirty.value = true;
        if (autoSaveTimeout) {
          clearTimeout(autoSaveTimeout);
        }
        autoSaveTimeout = setTimeout(() => {
          doSave();
        }, 500);
      },
      { deep: true },
    );
    watch(
      () => edges.value,
      () => {
        if (
          checkEdgeListEquality(
            cloneObject(edges.value),
            cloneObject(previousEdges.value),
          )
        ) {
          return;
        }
        debug("Edges are not equal. Setting dirty and starting save");
        previousEdges.value = cloneObject(edges.value);
        dirty.value = true;
        if (autoSaveTimeout) {
          clearTimeout(autoSaveTimeout);
        }
        autoSaveTimeout = setTimeout(() => {
          doSave();
        }, 500);
      },
      { deep: true },
    );
    const speedDialBadgeProps = computed(() => ({
      modelValue: saving.value || dirty.value,
      color: saving.value ? "primary" : "error",
      location: "bottom right" as const,
      icon: dirty.value && !saving.value ? "mdi-content-save-alert" : undefined,
      floating: true,
    }));
    const { layout: dagreLayout } = useLayout();
    const organizeWithDagre = () => {
      nodes.value = dagreLayout(nodes.value, edges.value, "LR");
      nextTick(() => {
        fitView();
      });
    };
    const issueStatusTransitionFormProps = computed(() => ({
      selection: selection.value as Edge,
      onClose: () => clearFocus(),
      remove: removeEdges,
      update: updateEdgeData,
      roles: roles.value,
      statuses: statuses.value,
      nodes: nodes.value,
      tracker: tracker.value,
    }));
    const issueStatusRestrictionsFormProps = computed(() => ({
      selection: selection.value as Node,
      onClose: () => clearFocus(),
      remove: removeNodes,
      update: updateNodeData,
      roles: roles.value,
      statuses: statuses.value,
      coreFields: tracker.value ? tracker.value.coreFields : [],
      issueCustomFields: tracker.value ? tracker.value.issueCustomFields : [],
      tracker: tracker.value,
    }));
    const showCopyFromDialog = ref(false);
    const copying = ref(false);
    const copyFromTrackerId = ref<number | null>(null);
    watch(
      () => showCopyFromDialog.value,
      () => {
        copyFromTrackerId.value = null;
      },
    );
    const doCopyFrom = () => {
      const trackerToCopyFrom = trackers.value.find(
        (t) => t.id === copyFromTrackerId.value,
      );
      if (!trackerToCopyFrom) {
        return;
      }
      const trkr = cloneObject(trackerToCopyFrom);
      copying.value = true;
      updateNodesFromTrackerUpdate(trkr).then(() => {
        updateEdgesFromTrackerUpdate(trkr).then(() => {
          showCopyFromDialog.value = false;
          copying.value = false;
        });
      });
    };
    return {
      vTabBindings,
      workflowEditorWrapperBindings,
      vueFlowProps,
      resetNodes,
      fitView,
      removeEdges,
      sidebarOpen,
      sidebarBindings,
      doAddStatus,
      remainingStatuses,
      remainingStatusesVirtualScrollerProps,
      setFocusOn,
      clearFocus,
      focus,
      doSave,
      saving,
      speedDialBadgeProps,
      organizeWithDagre,
      selection,
      issueStatusTransitionFormProps,
      issueStatusRestrictionsFormProps,
      showCopyFromDialog,
      copying,
      copyFromTrackerId,
      doCopyFrom,
    };
  },
});
</script>

<style lang="scss">
@import "@vue-flow/core/dist/style.css";
@import "@vue-flow/core/dist/theme-default.css";
@import "@vue-flow/controls/dist/style.css";

.vue-flow__node-default,
.vue-flow__node-input,
.vue-flow__node-output {
  padding: 0;
}

.workflow-management {
  .workflow-management-sidebar {
    .v-navigation-drawer__append {
      position: absolute;
      top: 0;
      left: -3px;
      bottom: 0;
      width: 3px;
      overflow: visible;
      display: flex;
      align-items: center;
      justify-content: start;

      .sidebar-toggle {
        transform: rotate(90deg) translate(0, 26px);
        border-top-left-radius: 0;
        border-top-right-radius: 0;
      }
    }
  }
  // .workflow-management-sidebar-indicator-wrapper {
  //   position: absolute;
  //   right: 0;
  //   top: 0;
  //   bottom: 0;
  //   width: 3px;
  //   background-color: rgb(var(--v-theme-accent));
  //   background: rgb(var(--v-theme-accent));
  //   z-index: 10;
  // }
}
</style>

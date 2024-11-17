<template>
  <v-container fluid>
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
      <v-container fluid>
        <v-slide-group show-arrows>
          <v-slide-group-item v-for="role in roles" :key="role.id">
            <v-sheet color="transparent" width="280" class="py-2 px-3">
              <v-autocomplete
                v-model:model-value="statusIdsForNew[role.id.toString()]"
                :items="statusesForNew"
                multiple
                item-title="name"
                item-value="id"
                :label="
                  $t('pages.workflows.admin.newIssueStatuses', {
                    role: role.name,
                  })
                "
                chips
                @update:model-value="updatePreSelectedStatusesFromForNew"
              >
                <template #chip="{ item, props }">
                  <IssueStatusChip
                    :id="
                      // @ts-ignore
                      item.raw.id
                    "
                    :name="
                      // @ts-ignore
                      item.raw.name
                    "
                    v-bind="props"
                  />
                </template>
              </v-autocomplete>
            </v-sheet>
          </v-slide-group-item>
        </v-slide-group>
      </v-container>
      <v-divider />
      <v-sheet v-bind="workflowEditorWrapperBindings">
        <v-container class="fill-height" fluid>
          <v-row no-gutters class="h-100">
            <v-col cols="12" md="10">
              <VueFlow
                v-model:nodes="nodes"
                v-model:edges="edges"
                :edges-updatable="true"
                :node-types="nodeTypes"
                :edge-types="edgeTypes"
                :default-edge-options="{ type: 'issue-status-transition' }"
                fit-view-on-init
                @nodes-initialized="layoutGraph()"
              >
                <Controls position="top-left" :show-interactive="false">
                </Controls>
                <Background />
                <template #node-issue-status="bindings">
                  <IssueStatusNode v-bind="bindings" />
                </template>
                <template #edge-issue-status-transition="bindings">
                  <IssueStatusTransitionEdge v-bind="bindings" />
                </template>
              </VueFlow>
            </v-col>
            <v-col cols="12" md="2">
              <v-list class="py-0 bg-transparent transparent">
                <v-list-item
                  v-for="status in statusesForStandard"
                  :key="status.id"
                >
                  <IssueStatusChip :id="status.id" :name="status.name" />
                  <template #append>
                    <v-btn
                      icon="mdi-plus"
                      color="accent"
                      size="x-small"
                      class="ms-2"
                      @click="onAddStatus(status)"
                    />
                  </template>
                </v-list-item>
              </v-list>
            </v-col>
          </v-row>
        </v-container>
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
  onMounted,
  inject,
} from "vue";
import { useI18n } from "vue-i18n";
import { useAppData } from "@/utils/app";
import { useRoute, useRouter } from "vue-router";
import { VueFlow, useVueFlow } from "@vue-flow/core";
import { Background } from "@vue-flow/background";
import { Controls } from "@vue-flow/controls";
import { useLayout } from "@/utils/flowchart";
import { useDisplay } from "vuetify";
import { IssueStatusNode } from "@/components/workflows/nodes";
import { IssueStatusTransitionEdge } from "@/components/workflows/edges";
import { IssueStatusChip } from "@/components/issues";

import type { PropType } from "vue";
import type {
  Node,
  Edge,
  Connection,
  EdgeUpdateEvent,
  NodeTypesObject,
  EdgeTypesObject,
} from "@vue-flow/core";
import type { IssueStatus, Tracker, Role, FieldByTracker } from "@/friday";
import type { SwalService } from "@jakguru/vueprint";
import type { IssueStatusTransitionProps } from "@/components/workflows/edges";

export default defineComponent({
  name: "WorkflowsIndex",
  components: {
    VueFlow,
    Background,
    Controls,
    IssueStatusChip,
    IssueStatusNode,
    IssueStatusTransitionEdge,
  },
  props: {
    formAuthenticityToken: {
      type: String,
      required: true,
    },
    fieldsByTracker: {
      type: Array as PropType<FieldByTracker[]>,
      required: true,
    },
  },
  setup(props) {
    const { t } = useI18n({ useScope: "global" });
    // const formAuthenticityToken = computed(() => props.formAuthenticityToken);
    const fieldsByTracker = computed(() => props.fieldsByTracker);
    const swal = inject<SwalService>("swal");
    const appData = useAppData();
    const roles = computed<Role[]>(() => appData.value.roles);
    const statuses = computed<IssueStatus[]>(() => appData.value.statuses);
    const trackers = computed<Tracker[]>(() => appData.value.trackers);
    const firstTracker = computed(() => trackers.value[0]);
    const firstTrackerId = computed(() =>
      firstTracker.value ? firstTracker.value.id : 0,
    );
    const route = useRoute();
    const router = useRouter();
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
    const statusIdsForNewByRoleId = ref<Record<string, number[]>>({});
    const tracker = computed(() =>
      trackers.value.find((t: Tracker) => t.id === parseInt(tab.value)),
    );
    const statusIdsForNew = computed<Record<string, number[]>>({
      get() {
        const ret: Record<string, number[]> = {};
        const defaultStatusId = tracker.value?.default_status_id;
        roles.value.forEach((role) => {
          ret[role.id.toString()] = [];
          if (defaultStatusId) {
            ret[role.id.toString()].push(defaultStatusId);
          }
          if (
            Array.isArray(statusIdsForNewByRoleId.value[role.id.toString()])
          ) {
            ret[role.id.toString()].push(
              ...statusIdsForNewByRoleId.value[role.id.toString()],
            );
          }
        });
        return ret;
      },
      set(v: Record<string, number[]>) {
        for (const key in v) {
          statusIdsForNewByRoleId.value[key] = v[key];
        }
      },
    });
    const statusesForNew = computed(() =>
      [...statuses.value].map((s) => ({
        ...s,
        props: {
          disabled: tracker.value?.default_status_id === s.id,
        },
      })),
    );
    const getUniquePreselectedStatuseFromForNew = () => {
      const ids = new Set<number>();
      for (const key in statusIdsForNew.value) {
        statusIdsForNew.value[key].forEach((id) => ids.add(id));
      }
      return [...ids];
    };
    const fieldsForTracker = computed(() =>
      fieldsByTracker.value.find((f) => f.trackerId === parseInt(tab.value)),
    );
    /**
     * Workflow Editor Shared
     */
    const { height } = useDisplay();
    const {
      fitView,
      addEdges,
      updateEdge,
      removeEdges,
      applyNodeChanges,
      applyEdgeChanges,
      addNodes,
      removeNodes,
    } = useVueFlow();
    const { layout } = useLayout();
    const { onConnect, onEdgeUpdate, onNodesChange, onEdgesChange } =
      useVueFlow();
    const nodes = ref<Node[]>([]);
    const edges = ref<Edge[]>([]);
    const preselectedStatusesFromForNew = ref<number[]>([]);
    const updatePreSelectedStatusesFromForNew = () => {
      preselectedStatusesFromForNew.value =
        getUniquePreselectedStatuseFromForNew();
    };
    /**
     * Workflow Editor List
     */
    const statusesForStandard = computed(() =>
      [...statuses.value].filter((s) =>
        nodes.value.every((n) => n.id !== `issue-status-${s.id}`),
      ),
    );
    const onAddStatus = (status: IssueStatus, forNewIssue: boolean = false) => {
      const node: Node = {
        id: `issue-status-${status.id}`,
        type: "issue-status",
        data: {
          statusId: status.id,
          statusName: status.name,
          forNewIssue,
          preselectedStatusesFromForNew,
          actions: {
            removeNodes,
          },
          roles: roles.value,
          fieldsForTracker,
        },
        position: { x: 0, y: 0 },
      };
      //   nodes.value.push(node);
      addNodes([node]);
    };
    watch(
      () => preselectedStatusesFromForNew.value,
      (ids) => {
        const toAdd = ids.filter(
          (id) => !nodes.value.some((n) => n.id === `issue-status-${id}`),
        );
        const toRemove = nodes.value.filter(
          (n) => n.type === "issue-status" && !ids.includes(n.data.statusId),
        );
        toRemove.forEach((n) => {
          removeNodes([n]);
        });
        toAdd.forEach((id) => {
          const status = statuses.value.find((s) => s.id === id);
          if (status) {
            onAddStatus(status);
          }
        });
      },
      { immediate: true, deep: true },
    );
    onMounted(() => {
      updatePreSelectedStatusesFromForNew();
    });
    /**
     * Workflow Editor UI
     * Based on VueFlow
     */
    const nodeTypes: NodeTypesObject = {
      "issue-status": markRaw(IssueStatusNode),
    };
    const edgeTypes: EdgeTypesObject = {
      "issue-status-transition": markRaw(IssueStatusTransitionEdge),
    };
    const workflowEditorWrapperBindings = computed(() => ({
      width: "100%",
      height: height.value - 334,
      minHeight: 400,
      color: "transparent",
    }));
    const layoutGraph = () => {
      nodes.value = layout(nodes.value, edges.value, "LR");
      nextTick(() => {
        fitView();
      });
    };
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
      const partialEdge: Partial<IssueStatusTransitionProps> & {
        source: string;
        target: string;
      } = {
        ...connection,
        source: connection.source!,
        target: connection.target!,
        data: {
          actions: {
            removeEdges,
          },
        },
      };
      addEdges([partialEdge]);
      layoutGraph();
    });
    onEdgeUpdate(({ edge, connection }: EdgeUpdateEvent) => {
      updateEdge(edge, connection);
    });
    onNodesChange((changes) => {
      applyNodeChanges(changes);
      layoutGraph();
    });
    onEdgesChange((changes) => {
      applyEdgeChanges(changes);
      layoutGraph();
    });
    return {
      tabs,
      vTabBindings,
      statuses,
      roles,
      statusIdsForNew,
      statusesForNew,
      updatePreSelectedStatusesFromForNew,
      // Workflow Editor List
      statusesForStandard,
      onAddStatus,
      // Workflow Editor
      workflowEditorWrapperBindings,
      nodes,
      nodeTypes,
      edgeTypes,
      edges,
      layoutGraph,
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
</style>

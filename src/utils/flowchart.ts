import dagre from "@dagrejs/dagre";
import ELK from "elkjs";
import { Position, useVueFlow } from "@vue-flow/core";
import { computed, ref } from "vue";
import { useAppData } from "./app";

import type { Node, Edge } from "@vue-flow/core";
import type { ElkNode, ElkExtendedEdge } from "elkjs";
import type { IssueStatus } from "@/friday";

export const useLayout = () => {
  const { findNode } = useVueFlow();
  const appData = useAppData();
  const graph = ref(new dagre.graphlib.Graph());
  const statuses = computed(() => appData.value.statuses);
  const previousDirection = ref("LR");

  function layout(nodes: Node[], edges: Edge[], direction: string) {
    // Create a new graph instance to avoid stale data
    const dagreGraph = new dagre.graphlib.Graph({ multigraph: true });

    graph.value = dagreGraph;

    dagreGraph.setDefaultEdgeLabel(() => ({}));

    const isHorizontal = direction === "LR";
    dagreGraph.setGraph({
      rankdir: direction,
    });

    previousDirection.value = direction;

    // Set nodes in the graph
    for (const node of nodes) {
      const graphNode = findNode(node.id);
      const nodeWidth = graphNode?.dimensions.width || 150;
      const nodeHeight = graphNode?.dimensions.height || 50;

      let rank = 1;
      if (node.type === "tracker-workflow-start") {
        // Set left-most rank for "tracker-workflow-start" nodes
        rank = 0;
      } else if (node.type === "issue-status") {
        // Set rank based on "position" attribute from the corresponding status
        const status = statuses.value.find(
          (s: IssueStatus) => s.id === node.data.statusId,
        );
        rank = status?.position || 1;
      }

      // Add to rank based on incoming connections to ensure nodes are placed after their dependencies
      const incomingEdges = edges.filter((edge) => edge.target === node.id);
      if (incomingEdges.length > 0) {
        const maxIncomingRank = Math.max(
          ...incomingEdges.map((edge) => {
            const sourceNode = dagreGraph.node(edge.source);
            return sourceNode?.rank || 0;
          }),
        );
        rank = Math.max(rank, maxIncomingRank + 1);
      }

      dagreGraph.setNode(node.id, {
        width: nodeWidth,
        height: nodeHeight,
        rank,
      });
    }

    // Set edges in the graph
    for (const edge of edges) {
      dagreGraph.setEdge(edge.source, edge.target, { weight: 1 });
    }

    // Perform layout calculation
    dagre.layout(dagreGraph);

    // Update node positions based on the calculated layout
    return nodes.map((node) => {
      const nodeWithPosition = dagreGraph.node(node.id);

      return {
        ...node,
        targetPosition: isHorizontal ? Position.Left : Position.Top,
        sourcePosition: isHorizontal ? Position.Right : Position.Bottom,
        position: { x: nodeWithPosition.x, y: nodeWithPosition.y },
      };
    });
  }

  return { graph, layout, previousDirection };
};

export const useElkLayout = () => {
  const { findNode } = useVueFlow();
  const elk = new ELK();

  async function elkLayout(nodes: Node[], edges: Edge[]) {
    // Create an ElkJS-compatible graph from the provided nodes and edges
    const elkGraph: ElkNode = {
      id: "root",
      layoutOptions: {
        "elk.algorithm": "mrtree",
        "elk.spacing.nodeNode": "100", // Optional: increase spacing between nodes
        "elk.spacing.edgeNode": "50", // Optional: increase spacing between edges and nodes
      },
      children: nodes.map((node) => {
        const graphNode = findNode(node.id);
        return {
          id: node.id,
          width: graphNode?.dimensions.width || 150,
          height: graphNode?.dimensions.height || 50,
        };
      }),
      edges: edges.map((edge) => ({
        id: edge.id,
        sources: [edge.source],
        targets: [edge.target],
      })) as ElkExtendedEdge[],
    };

    // Perform the layout calculation with elkjs
    const elkLayoutResult = await elk.layout(elkGraph);

    // Set nodes with updated positions from the layout result
    return nodes.map((node) => {
      const elkNode = elkLayoutResult?.children?.find((n) => n.id === node.id);
      if (elkNode) {
        return {
          ...node,
          position: { x: elkNode.x ?? 0, y: elkNode.y ?? 0 },
          targetPosition: Position.Left,
          sourcePosition: Position.Right,
        };
      }
      return node;
    });
  }

  return { layout: elkLayout };
};

export const checkNodeListEquality = (a: Node[], b: Node[]) => {
  if (a.length !== b.length) {
    return false;
  }
  let equal = true;
  for (let i = 0; i < a.length; i++) {
    if (
      a[i].id !== b[i].id ||
      JSON.stringify(a[i].position) !== JSON.stringify(b[i].position) ||
      JSON.stringify(a[i].data) !== JSON.stringify(b[i].data)
    ) {
      equal = false;
      break;
    }
  }
  if (equal) {
    for (let i = 0; i < b.length; i++) {
      if (
        a[i].id !== b[i].id ||
        JSON.stringify(a[i].position) !== JSON.stringify(b[i].position) ||
        JSON.stringify(a[i].data) !== JSON.stringify(b[i].data)
      ) {
        equal = false;
        break;
      }
    }
  }
  return equal;
};

export const checkEdgeListEquality = (a: Edge[], b: Edge[]) => {
  if (a.length !== b.length) {
    return false;
  }
  let equal = true;
  for (let i = 0; i < a.length; i++) {
    if (
      a[i].id !== b[i].id ||
      a[i].source !== b[i].source ||
      a[i].target !== b[i].target ||
      JSON.stringify(a[i].data) !== JSON.stringify(b[i].data)
    ) {
      equal = false;
      break;
    }
  }
  if (equal) {
    for (let i = 0; i < b.length; i++) {
      if (
        a[i].id !== b[i].id ||
        a[i].source !== b[i].source ||
        a[i].target !== b[i].target ||
        JSON.stringify(a[i].data) !== JSON.stringify(b[i].data)
      ) {
        equal = false;
        break;
      }
    }
  }
  return equal;
};

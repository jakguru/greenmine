import dagre from "@dagrejs/dagre";
import ELK from "elkjs";
import { Position, useVueFlow } from "@vue-flow/core";
import { ref } from "vue";

import type { Node, Edge } from "@vue-flow/core";
import type { ElkNode, ElkExtendedEdge } from "elkjs";

export const useLayout = () => {
  const { findNode } = useVueFlow();

  const graph = ref(new dagre.graphlib.Graph());

  const previousDirection = ref("LR");

  function layout(nodes: Node[], edges: Edge[], direction: string) {
    // we create a new graph instance, in case some nodes/edges were removed, otherwise dagre would act as if they were still there
    const dagreGraph = new dagre.graphlib.Graph();

    graph.value = dagreGraph;

    dagreGraph.setDefaultEdgeLabel(() => ({}));

    const isHorizontal = direction === "LR";
    dagreGraph.setGraph({
      rankdir: direction,
      ranksep: 100, // Increased separation between ranks (rows or columns)
      nodesep: 100, // Increased separation between nodes to reduce overlap
      edgesep: 50, // Increased separation between edges to minimize intersections
    });

    previousDirection.value = direction;

    for (const node of nodes) {
      // if you need width+height of nodes for your layout, you can use the dimensions property of the internal node (`GraphNode` type)
      const graphNode = findNode(node.id);

      dagreGraph.setNode(node.id, {
        width: graphNode?.dimensions.width || 150,
        height: graphNode?.dimensions.height || 50,
      });
    }

    for (const edge of edges) {
      dagreGraph.setEdge(edge.source, edge.target, { weight: 1 });
    }

    dagre.layout(dagreGraph);

    // set nodes with updated positions
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

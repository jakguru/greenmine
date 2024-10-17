import ProjectsLayoutsBoardWrapper from "./wrapper.vue";
import ProjectsLayoutsBoardPanel from "./panel.vue";

import type { ProjectsProject } from "@/redmine";

export interface ProjectsProjectTree extends ProjectsProject {
  children?: ProjectsProjectTree[];
}
export { ProjectsLayoutsBoardWrapper, ProjectsLayoutsBoardPanel };

export interface News {
  id: number;
  title: string;
  summary: string;
  description: string;
  created_on: string;
  comments_count: number;
  project: Project;
  author: Author;
}

export interface Project {
  id: number;
  name: string;
  identifier: string;
}

export interface JumpProject extends Project {
  level: number;
  lft: number;
  rgt: number;
}

export interface Author {
  id: number;
  login: string;
  firstname: string;
  lastname: string;
}

export interface ProjectsProject {
  id: number;
  name: string;
  description: string;
  homepage: string;
  is_public: boolean;
  parent_id: number | null;
  created_on: string; // ISO 8601 format date string
  updated_on: string; // ISO 8601 format date string
  identifier: string;
  status: number;
  lft: number;
  rgt: number;
  inherit_members: boolean;
  default_version_id: number | null;
  default_assigned_to_id: number | null;
  default_issue_query_id: number | null;
}

export interface QueryOptions {
  display_type: string;
  draw_progress_line?: boolean | null;
  draw_relations?: boolean | null;
  draw_selected_columns?: string[] | null;
  totalable_names: string[];
}

export interface QueriesQuery {
  id: number;
  project_id: number | null;
  name: string;
  filters: {
    [key: string]: {
      operator: string;
      values: string[];
    };
  };
  user_id: number;
  column_names: string[] | null;
  sort_criteria: string[];
  group_by: string | null;
  visibility: number;
  options: QueryOptions;
}

export interface ModelQuery {
  valid: boolean;
  type: string;
  new_record: boolean;
  columns: {
    names: string[] | null;
    current: QueryColumn[];
    available: QueryColumn[];
  };
  filters: {
    current: QueryFilterRaw;
    available: Record<string, QueryAvailableFilter>;
    groupable: QueryColumn[];
    blockable: QueryColumn[];
    totable: QueryColumn[];
    display_types: string[];
  };
  group_by: string | null;
  id: number | null;
  name: string;
  options: QueryOptions;
  project_id: number | null;
  sort_criteria: string[];
  user_id: number;
  visibility: number;
}

export interface QueryPermissions {
  query: {
    save: boolean;
  };
}

export interface QueryColumn {
  name: string;
  sortable: string;
  groupable: boolean;
  totalable: boolean;
  default_order: string | null;
  inline: boolean;
  caption_key: string;
  frozen: boolean | null;
}

export interface QueryOptions {
  operators: Record<string, string[]>;
}

export interface QueryFilterRaw {
  [key: string]: {
    operator: string;
    values: any[];
  };
}

export type QueryAvailableFilterOptionsValues =
  | {}
  | Array<[string, string]>
  | {
      name: string;
      type: string;
    };

export interface QueryAvailableFilterOptions {
  name: string;
  type: string;
  values?: QueryAvailableFilterOptionsValues;
}

export interface QueryAvailableFilter {
  field: string;
  options: QueryAvailableFilterOptions;
  remote: boolean;
}

export interface Issue {
  id: number;
  tracker_id: number;
  project_id: number;
  subject: string;
  description: string;
  due_date: string;
  category_id: number | null;
  status_id: number;
  assigned_to_id: number;
  priority_id: number;
  fixed_version_id: number | null;
  author_id: number;
  lock_version: number;
  created_on: string;
  updated_on: string;
  start_date: string;
  done_ratio: number;
  estimated_hours: number | null;
  parent_id: number | null;
  root_id: number;
  lft: number;
  rgt: number;
  is_private: boolean;
  closed_on: string | null;
}

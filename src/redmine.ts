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
  options: Record<string, unknown>;
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
  options: Record<string, unknown>;
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

export interface QueryAvailableFilterOptions {
  name: string;
  type: string;
  values:
    | {}
    | Array<[string, string]>
    | {
        name: string;
        type: string;
      };
}

export interface QueryAvailableFilter {
  field: string;
  remote: boolean;
  options: QueryAvailableFilterOptions;
  values?: any;
}

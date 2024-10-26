export interface QueryResponse<T = any> {
  params: QueryResponseParams;
  payload: QueryResponsePayload<T>;
  query: QueryData;
  queries: Array<DefinedQuery>;
  permissions: Permissions;
  createable: Array<Createable>;
}

export interface Createable {
  title: string;
  url: string;
}

export interface QueryResponseParams {
  [key: string]: any;
}

export interface QueryResponsePayload<T = any> {
  items: Array<Item<T>>;
  items_length: number;
  items_per_page: number;
  page: number;
  pages: PageDetails;
  totals: Array<ColumnTotal>;
}

export interface Item<T = any> {
  id: number;
  entry: EntryHash<T>;
  level: number;
  group_name: string | null;
  group_count: number | null;
  group_totals: GroupTotals;
}

export interface EntryHash<T = any> {
  [key: string]: EntryHashValue<T>;
}

export interface EntryHashValue<T = any> {
  type: string;
  display: string;
  value: T;
  url?: string;
}

export type KnownQueryTypes =
  | "IssueQuery"
  | "ProjectQuery"
  | "TimeEntryQuery"
  | "UserQuery";

export type QueryType = KnownQueryTypes | string;

export interface QueryData {
  valid: boolean;
  new_record: boolean;
  id: number | null;
  name: string;
  type: QueryType;
  columns: {
    current: ColumnGroups;
    available: ColumnGroups;
  };
  filters: {
    current: Record<string, Filter>;
    available: Record<string, AvailableFilter>;
  };
  display: {
    current: string;
    available: Array<string>;
  };
  options: QueryOptions;
  project: Project | null;
  sprint_association?: SprintAssociation;
}

export interface ColumnGroups {
  inline: Array<Column>;
  block: Array<Column>;
  totalable: Array<Column>;
  groupable: Array<Column>;
  sort: Array<ColumnSort>;
  all?: Array<Column>;
  sortable?: Array<Column>;
}

export interface Column {
  key: string;
  value: string;
  title: string;
  nowrap: boolean;
  sortable: boolean;
  meta: ColumnMeta;
  attributes?: ColumnAttributes;
}

export interface ColumnMeta {
  default_order: string | null;
  frozen: boolean | null;
  groupable: boolean;
  inline: boolean;
  sort_key: string;
  totalable: boolean;
}

export interface ColumnSort extends Column {
  sort: "asc" | "desc";
}

export interface ColumnTotal extends Column {
  total: string | number;
}

export interface DefinedQuery {
  id: number;
  project_id: number | null;
  name: string;
  filters: Record<string, Filter>;
  user_id: number;
  column_names: Array<string> | null;
  sort_criteria: Array<SortCriterion>;
  group_by: string | null;
  visibility: number;
  options: Record<string, any>;
}

export interface Permissions {
  create: boolean;
  edit: boolean;
}

export interface Project {
  id: number;
  name: string;
  description: string;
  homepage: string;
  is_public: boolean;
  parent_id: number | null;
  created_on: string;
  updated_on: string;
  identifier: string;
  status: number;
  lft: number;
  rgt: number;
  inherit_members: boolean;
  default_version_id: number | null;
  default_assigned_to_id: number | null;
  default_issue_query_id: number | null;
}

export interface PageDetails {
  item_count: number;
  per_page: number;
  page: number;
  page_param: string;
  total_pages?: number;
}

export interface Filter {
  operator: string;
  values: Array<string>;
  attributes?: FilterAttributes;
}

export interface AvailableFilter {
  field: string;
  options: FilterOptions;
  remote: boolean;
  required?: boolean;
}

export interface FilterOptions {
  type: string;
  values?: Record<string, string> | Array<[string, string]>;
  name: string;
  label?: string;
  placeholder?: string;
}

export interface QueryOptions {
  totalable_names: Array<string>;
  display_type: string;
  pagination?: boolean;
}

export interface GroupTotals {
  [key: string]: any;
}

export interface SortCriterion {
  key: string;
  order: "asc" | "desc";
}

export interface SprintAssociation {
  sprint_id: number;
  sprint_name: string;
  start_date: string;
  end_date: string;
}

export interface ColumnAttributes {
  editable?: boolean;
  visible?: boolean;
  required?: boolean;
}

export interface FilterAttributes {
  case_sensitive?: boolean;
  multi_select?: boolean;
}

export interface NewQueryPayload {
  f: string[];
  op: Record<string, string>;
  v: Record<string, string[]>;
  group_by: string;
  c: string[];
  t: string[];
  sort: string[] | string;
  display_type: string;
  per_page: string | number;
  set_filter: string | number;
  utf8: "✓";
  page: string | number;
  query_id?: string | number;
}

export interface PredefinedQueryPayload {
  query_id: string | number;
}

export type QueryPayload = NewQueryPayload | PredefinedQueryPayload;

export const makeNewQueryPayloadFromQueryAndQueryPayload = (
  query: QueryData,
  payload: QueryResponsePayload,
): NewQueryPayload => {
  return {
    utf8: "✓",
    set_filter: 1,
    query_id: query.id || undefined,
    page: payload.page,
    per_page: payload.items_per_page,
    f: [...Object.keys(query.filters.current), ""],
    op: Object.fromEntries(
      Object.entries(query.filters.current).map(([key, filter]) => [
        key,
        filter.operator,
      ]),
    ),
    v: Object.fromEntries(
      Object.entries(query.filters.current).map(([key, filter]) => [
        key,
        filter.values,
      ]),
    ),
    group_by: query.columns.current.groupable[0]
      ? query.columns.current.groupable[0].key
      : "",
    c: [
      ...query.columns.current.inline.map((column) => column.key),
      ...query.columns.current.block.map((column) => column.key),
    ],
    t: [...query.columns.current.totalable.map((column) => column.key), ""],
    sort: query.columns.current.sort
      .map((column) =>
        [column.key, column.sort === "desc" ? "desc" : undefined]
          .filter((v) => "string" === typeof v)
          .join(":"),
      )
      .join(","),
    display_type: query.options.display_type,
  };
};

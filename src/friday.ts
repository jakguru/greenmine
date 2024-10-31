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

export interface SettingsPayloadSettings {
  app_title: TextSettingField;
  welcome_text: MarkdownSettingField;
  per_page_options: TextSettingField;
  search_results_per_page: TextSettingField;
  activity_days_default: TextSettingField;
  host_name: TextSettingField;
  protocol: SelectSingleSettingField;
  wiki_compression: SelectSingleSettingField;
  feeds_limit: TextSettingField;
  default_language: SelectSingleSettingField;
  force_default_language_for_anonymous: CheckboxSettingField;
  force_default_language_for_loggedin: CheckboxSettingField;
  user_format: SelectSingleSettingField;
  gravatar_enabled: CheckboxSettingField;
  gravatar_default: SelectSingleSettingField;
  login_required: SelectSingleSettingField;
  self_registration: SelectSingleSettingField;
  show_custom_fields_on_registration: CheckboxSettingField;
  password_min_length: TextSettingField;
  password_required_char_classes: SelectMultipleSettingField;
  password_max_age: SelectSingleSettingField;
  lost_password: CheckboxSettingField;
  twofa: SelectSingleSettingField;
  session_lifetime: SelectSingleSettingField;
  session_timeout: SelectSingleSettingField;
  rest_api_enabled: CheckboxSettingField;
  jsonp_enabled: CheckboxSettingField;
  default_projects_public: CheckboxSettingField;
  default_projects_modules: SelectMultipleSettingField;
  default_projects_tracker_ids: SelectMultipleSettingField;
  sequential_project_identifiers: CheckboxSettingField;
  new_project_user_role_id: SelectSingleSettingField;
  "project_list_defaults.column_names": QueryColumnSelectionSettingField;
  default_project_query: SelectSingleSettingField;
  max_additional_emails: TextSettingField;
  email_domains_allowed: CsvSettingField;
  email_domains_denied: CsvSettingField;
  unsubscribe: CheckboxSettingField;
  default_users_hide_mail: CheckboxSettingField;
  default_notification_option: SelectSingleSettingField;
  default_users_no_self_notified: CheckboxSettingField;
  default_users_time_zone: SelectSingleSettingField;
  cross_project_issue_relations: CheckboxSettingField;
  link_copied_issue: SelectSingleSettingField;
  cross_project_subtasks: SelectSingleSettingField;
  close_duplicate_issues: CheckboxSettingField;
  issue_group_assignment: CheckboxSettingField;
  default_issue_start_date_to_creation_date: CheckboxSettingField;
  display_subprojects_issues: CheckboxSettingField;
  issue_done_ratio: SelectSingleSettingField;
  non_working_week_days: SelectMultipleSettingField;
  issues_export_limit: TextSettingField;
  gantt_items_limit: TextSettingField;
  gantt_months_limit: TextSettingField;
  parent_issue_dates: SelectSingleSettingField;
  parent_issue_done_ratio: SelectSingleSettingField;
  issue_list_default_columns: QueryColumnSelectionSettingField;
  issue_list_default_totals: SelectMultipleSettingField;
  default_issue_query: SelectSingleSettingField;
  timelog_required_fields: SelectMultipleSettingField;
  timelog_max_hours_per_day: TextSettingField;
  timelog_accept_0_hours: CheckboxSettingField;
  timelog_accept_future_dates: CheckboxSettingField;
  "time_entry_list_defaults.column_names": QueryColumnSelectionSettingField;
  "time_entry_list_defaults.totalable_names": SelectMultipleSettingField;
  attachment_max_size: TextSettingField;
  bulk_download_max_size: TextSettingField;
  attachment_extensions_allowed: CsvSettingField;
  attachment_extensions_denied: CsvSettingField;
  file_max_size_displayed: TextSettingField;
  diff_max_lines_displayed: TextSettingField;
  repositories_encodings: CsvSettingField;
  mail_from: TextSettingField;
  plain_text_mail: CheckboxSettingField;
  show_status_changes_in_mail_subject: CheckboxSettingField;
  notified_events: SelectMultipleSettingField;
  emails_header: MarkdownSettingField;
  emails_footer: MarkdownSettingField;
  mail_handler_body_delimiters: LbsvSettingField;
  mail_handler_enable_regex_delimiters: CheckboxSettingField;
  mail_handler_excluded_filenames: LbsvSettingField;
  mail_handler_enable_regex_excluded_filenames: CheckboxSettingField;
  mail_handler_preferred_body_part: SelectSingleSettingField;
  mail_handler_api_enabled: CheckboxSettingField;
  mail_handler_api_key: TextSettingField;
  enabled_scm: SelectMultipleSettingField;
  autofetch_changesets: CheckboxSettingField;
  sys_api_enabled: CheckboxSettingField;
  sys_api_key: TextSettingField;
  repository_log_display_limit: TextSettingField;
  commit_logs_formatting: CheckboxSettingField;
  commit_ref_keywords: CsvSettingField;
  commit_cross_project_ref: CheckboxSettingField;
  commit_logtime_enabled: CheckboxSettingField;
  commit_logtime_activity_id: SelectSingleSettingField;
}

export type SettingField =
  | TextSettingField
  | MarkdownSettingField
  | SelectSingleSettingField
  | SelectMultipleSettingField
  | CheckboxSettingField
  | CsvSettingField
  | LbsvSettingField
  | QueryColumnSelectionSettingField;

export interface TextSettingField {
  type: "text";
  props: TextProps;
  value: string;
}

export interface MarkdownSettingField {
  type: "markdown";
  props: MarkdownProps;
  value: string;
}

export interface SelectSingleSettingField {
  type: "select";
  props: SelectSingleProps;
  value: string | number | null;
}

export interface SelectMultipleSettingField {
  type: "select";
  props: SelectMultipleProps;
  value: (string | number | null)[];
}

export interface CheckboxSettingField {
  type: "checkbox";
  props: CheckboxProps;
  value: boolean;
}

export interface CsvSettingField {
  type: "csv";
  props: CsvProps;
  value: string;
}

export interface LbsvSettingField {
  type: "lbsv";
  props: LbsvProps;
  value: string;
}

export interface QueryColumnSelectionSettingField {
  type: "querycolumnselection";
  props: QueryColumnSelectionProps;
  value: string[];
}

export interface TextProps {
  type?: "text" | "password" | "email" | "number";
  min?: number;
  max?: number;
  hint?: string;
}

export interface MarkdownProps {}

export interface SelectSingleProps {
  items: Option[];
  multiple: false;
  disabled?: boolean;
}

export interface SelectMultipleProps {
  items: Option[];
  multiple: true;
  disabled?: boolean;
}

export interface CheckboxProps {
  disabled?: boolean;
}

export interface CsvProps {}

export interface LbsvProps {
  hint?: string;
}

export interface QueryColumnSelectionProps {
  formKey: string;
  items: Option[];
}

export interface Option {
  value: string | number | null;
  label: string;
}

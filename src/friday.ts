import type { Node, Edge } from "@vue-flow/core";

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
  mail_handler_api_key: PasswordSettingField;
  enabled_scm: SelectMultipleSettingField;
  autofetch_changesets: CheckboxSettingField;
  sys_api_enabled: CheckboxSettingField;
  sys_api_key: PasswordSettingField;
  repository_log_display_limit: TextSettingField;
  commit_logs_formatting: CheckboxSettingField;
  commit_ref_keywords: CsvSettingField;
  commit_cross_project_ref: CheckboxSettingField;
  commit_logtime_enabled: CheckboxSettingField;
  commit_logtime_activity_id: SelectSingleSettingField;
  commit_update_keywords: RepositoryCommitUpdateKeywordsSettingField;
  "plugin_friday.repository_base_path": TextSettingField;
  "plugin_friday.monday_access_token": PasswordSettingField;
  "plugin_friday.monday_board_id": TextSettingField;
  "plugin_friday.monday_group_id": TextSettingField;
  "plugin_friday.monday_enabled": CheckboxSettingField;
  "plugin_friday.gitlab_api_base_url": TextSettingField;
  "plugin_friday.gitlab_api_token": PasswordSettingField;
  "plugin_friday.gitlab_api_enabled": CheckboxSettingField;
  "plugin_friday.sentry_api_base_url": TextSettingField;
  "plugin_friday.sentry_api_token": PasswordSettingField;
  "plugin_friday.sentry_api_organization": TextSettingField;
  "plugin_friday.sentry_api_enabled": CheckboxSettingField;
  "plugin_friday.google_translate_api_key": PasswordSettingField;
  "plugin_friday.google_translate_enabled": TextSettingField;
  "plugin_friday.chatgpt_api_key": PasswordSettingField;
  "plugin_friday.chatgpt_org_id": TextSettingField;
  "plugin_friday.chatgpt_project_id": TextSettingField;
  "plugin_friday.chatgpt_enabled": CheckboxSettingField;
  "plugin_friday.users_allowed_to_manage_sprints": SelectMultipleSettingField;
  "plugin_friday.groups_allowed_to_manage_sprints": SelectMultipleSettingField;
  "plugin_friday.issue_dates_clear_on_backlog": CheckboxSettingField;
  "plugin_friday.unstarted_issue_statuses": SelectMultipleSettingField;
}

export type SettingField =
  | TextSettingField
  | PasswordSettingField
  | MarkdownSettingField
  | SelectSingleSettingField
  | SelectMultipleSettingField
  | CheckboxSettingField
  | CsvSettingField
  | LbsvSettingField
  | QueryColumnSelectionSettingField
  | RepositoryCommitUpdateKeywordsSettingField;

export interface TextSettingField {
  type: "text";
  props: TextProps;
  value: string;
}

export interface PasswordSettingField {
  type: "password";
  props: PasswordProps;
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

export interface RepositoryCommitUpdateKeywordsSettingField {
  type: "repository_commit_update_keywords";
  props: RepositoryCommitUpdateKeywordsProps;
  value: Array<{
    if_tracker_id?: string;
    keywords?: string;
    status_id?: string;
    done_ratio?: string;
  }>;
}

interface BaseProps {
  formKey?: string;
}

export interface RepositoryCommitUpdateKeywordsProps extends BaseProps {
  trackers: Option[];
  statuses: Option[];
  percentages: Option[];
}

export interface TextProps extends BaseProps {
  type?: "text" | "email" | "number";
  min?: number;
  max?: number;
  hint?: string;
  optional?: boolean;
}

export interface PasswordProps extends BaseProps {
  type?: "password";
  min?: number;
  max?: number;
  hint?: string;
}

export interface MarkdownProps extends BaseProps {}

export interface SelectSingleProps extends BaseProps {
  items: Option[];
  multiple: false;
  disabled?: boolean;
}

export interface SelectMultipleProps extends BaseProps {
  items: Option[];
  multiple: true;
  disabled?: boolean;
}

export interface CheckboxProps extends BaseProps {
  disabled?: boolean;
}

export interface CsvProps extends BaseProps {}

export interface LbsvProps extends BaseProps {
  hint?: string;
}

export interface QueryColumnSelectionProps extends BaseProps {
  formKey: string;
  items: Option[];
}

export interface Option {
  value: string | number | null;
  label: string;
}

export interface EnumerableValue {
  id: number;
  name: string;
  is_default: boolean;
  position: number;
  active: boolean;
}

export interface EnumerableProp {
  name: string;
  values: EnumerableValue[];
}

export interface SprintResponse {
  sprint: Sprint;
  issues: QueryResponse<Issue>;
  progress: Progress;
  workload: WorkloadAllocation[];
  releases: Release[];
  by_calculated_priority: BreakdownByCalculatedPriority[];
  by_tracker: BreakdownByTracker[];
  by_activity: BreakdownByActivity[];
  by_project: BreakdownByProject[];
}

export interface Sprint {
  id: number | null;
  name: string;
  state?: string;
  start_date: string; // ISO string format
  end_date: string; // ISO string format
  total_estimated_work?: number;
  total_time_logged?: number;
  progress?: number;
}

export interface SprintQueryColumnItem {
  id: number | null;
  name: string;
  startDate: string;
  endDate: string;
}

export interface Issue {
  id: number;
  entry: EntryHash;
  level: number;
  group_name?: string;
  group_count?: number;
  group_totals?: GroupTotals;
  calculated_priority?: string;
  tracker?: IssueTrackerItem;
  project?: Project;
  estimated_hours?: number;
  logged_hours?: number;
  status?: string;
}

export interface IssueTrackerItem {
  id: number;
  name: string;
}

export interface Progress {
  percent_complete: number;
  completed_points?: number;
  total_points?: number;
}

export interface DailyBreakdown {
  assigned_estimated_hours: number;
  workable_hours: number;
  remaining_capacity: number;
}

export interface WorkloadAllocation {
  user: {
    id: number;
    firstname: string;
    lastname: string;
  };
  total_assigned_estimate: number;
  average_assigned_estimate_daily: number;
  total_workable_hours: number;
  average_workable_hours_daily: number;
  remaining_capacity_total: number;
  daily_breakdown: { [date: string]: DailyBreakdown };
}

export interface Release {
  id: number;
  name: string;
  date: string; // ISO string format
}

export interface BreakdownByCalculatedPriority {
  priority: string;
  total_estimated_hours: number;
  total_logged_hours: number;
}

export interface BreakdownByTracker {
  tracker: string;
  total_estimated_hours: number;
  total_logged_hours: number;
}

export interface BreakdownByActivity {
  activity: string;
  total_estimated_hours: number;
  total_logged_hours: number;
}

export interface BreakdownByProject {
  project: string;
  total_estimated_hours: number;
  total_logged_hours: number;
}

export interface SprintNavigation {
  next: number;
  previous: number;
}

export interface SprintPermissions {
  edit: boolean;
}

export interface SprintBurndown {
  [date: string]: DailyBurndownData;
}

export interface DailyBurndownData {
  ideal_remaining_work: number;
  actual_remaining_work: number;
  estimated_work: number;
  logged_work: number;
}

export interface IssueStatus {
  id: number;
  name: string;
  is_closed: boolean;
  position: number;
  description: string | null;
  default_done_ratio: number | null;
  icon: `mdi-${string}` | null;
  text_color: `#${string}` | "on-working" | "on-mud" | null;
  background_color: `#${string}` | "working" | "mud" | null;
}

export interface Tracker {
  id: number;
  name: string;
  default_status_id: number;
  is_in_roadmap: boolean;
  description: string;
  core_fields: string[];
  custom_field_ids: number[];
  position: number;
  icon: `mdi-${string}` | null;
  color: `#${string}` | null;
  project_ids: number[];
}

export interface TruncatedRole {
  id: number;
  name: string;
  position: number;
}

export interface SelectableListItem<T = string> {
  value: T;
  label: string;
}

export interface CoreField {
  value: string;
  label: string;
  required: boolean;
}

export interface IssueCustomField {
  value: number;
  label: string;
  required: boolean;
}

export interface FieldByTracker {
  trackerId: number;
  coreFields: CoreField[];
  issueCustomFields: IssueCustomField[];
}

export interface WorkflowTracker extends Tracker {
  nodes: Node[];
  edges: Edge[];
  newIssueStatuses: Record<string, number[]>;
  coreFields: CoreField[];
  issueCustomFields: IssueCustomField[];
}

export interface Role {
  all_roles_managed: boolean;
  assignable: boolean;
  builtin: number;
  default_time_entry_activity_id: number | null;
  id: number;
  issues_visibility: string;
  managed_role_ids: number[];
  name: string;
  permissions: string[];
  permissions_all_trackers: Record<string, "0" | "1">;
  permissions_tracker_ids: Record<string, number[]>;
  position: number;
  settings: Record<string, any>;
  time_entries_visibility: string;
  users_visibility: string;
}

export interface PrincipalRole {
  all_roles_managed: boolean;
  assignable: boolean;
  builtin: number;
  default_time_entry_activity_id: number | null;
  id: number;
  issues_visibility: string;
  managed_role_ids: number[];
  name: string;
  permissions: string[];
  position: number;
  settings: Record<string, any>;
  time_entries_visibility: string;
  users_visibility: string;
  is_external: boolean;
}

export interface Permission extends SelectableListItem<string> {
  module: string | null;
  group: string;
}

export interface RoleValuesProp {
  groups: SelectableListItem<string>[];
  issueVisibilities: SelectableListItem<string>[];
  permissions: Permission[];
  roles: SelectableListItem<number>[];
  timeEntryVisibilities: SelectableListItem<string>[];
  trackers: SelectableListItem<number>[];
  userVisibilities: SelectableListItem<string>[];
  activities: SelectableListItem<number>[];
}
export interface Principal {
  admin: boolean;
  auth_source_id: number | null;
  avatar: string | null;
  created_on: string;
  firstname: string;
  hashed_password: string;
  id: number;
  language: string;
  last_login_on: string | null;
  lastname: string;
  login: string;
  mail_notifications: string;
  monday_person_id: string;
  must_change_passwd: boolean;
  passwd_changed_on: string | null;
  salt: string | null;
  status: number;
  twofa_required: boolean;
  twofa_scheme: string | null;
  twofa_totp_key: string | null;
  twofa_totp_last_used_at: string | null;
  type: string;
  updated_on: string | null;
  name: string;
}

export interface PrincipalMembership {
  project: number;
  roles: number[];
}

export interface User extends Principal {
  type: "User";
  auto_watch_on: Array<"issue_created" | "issue_contributed_to">;
  comments_sorting: "asc" | "desc";
  default_issue_query: "" | number;
  default_project_query: "" | number;
  gantt_months: number;
  gantt_zoom: number;
  groups: number[];
  hide_mail: boolean;
  history_default_tab: string;
  mail_notification: string;
  mails: string[];
  memberships: PrincipalMembership[];
  my_page_layout: Record<string, string[]>;
  my_page_settings: any;
  name: string;
  no_self_notified: "0" | "1";
  notify_about_high_priority_issues: "0" | "1";
  recently_used_project_ids: string;
  recently_used_projects: number;
  textarea_font: string;
  timezone: string;
  toolbar_language_options: string;
  warn_on_leaving_unsaved: "0" | "1";
}

export interface UserValuesProp {
  commmentsSortingOptions: SelectableListItem<string>[];
  defaultIssueQueryOptions: SelectableListItem<"" | number>[];
  defaultProjectQueryOptions: SelectableListItem<"" | number>[];
  groups: SelectableListItem<number>[];
  historyDefaultTabOptions: SelectableListItem<string>[];
  languages: SelectableListItem<string>[];
  mailNotificationOptions: SelectableListItem<string>[];
  projects: SelectableListItem<number>[];
  roles: SelectableListItem<number>[];
  timezones: SelectableListItem<string>[];
  userStatusOptions: SelectableListItem<number>[];
  passwordMinLength: number;
  passwordRequiredCharClasses: string[];
  emailDomainsAllowed: string | null;
  emailDomainsDenied: string | null;
}

export interface Group extends Principal {
  auth_source_id: null;
  firstname: "";
  hashed_password: "";
  language: "";
  login: "";
  mail_notifications: "";
  monday_person_id: "";
  type: "Group";
  passwd_changed_on: null;
  salt: null;
  status: 1;
  twofa_scheme: null;
  twofa_totp_key: null;
  twofa_totp_last_used_at: null;
  name: string;
  users: number[];
  memberships: PrincipalMembership[];
}

export interface GroupValuesProp {
  roles: SelectableListItem<number>[];
  projects: SelectableListItem<number>[];
  users: SelectableListItem<number>[];
}

export interface GitLabUser {
  id: number;
  gitlab_id: number;
  user_id: number;
  name: string;
  username: string;
  redmine_user: any | null;
  redmine_user_id: number | null;
}

export interface GitLab {
  name: string;
  url: string;
  api_token: string;
  active: boolean;
  users: GitLabUser[];
}

export interface GitLabValuesProp {
  users: SelectableListItem<number>[];
}

export interface GitLabProject {
  id: number;
  gitlab_id: number;
  project_id: number;
  name: string;
  name_with_namespace: string;
  path: string;
  path_with_namespace: string;
  created_at: string;
  updated_at: string;
  projects: number[];
  remote_info: GitLabProjectRemoteInfo;
  web_url: string;
  git_http_url: string;
  git_ssh_url: string;
}

export interface GitLabProjectRemoteInfo {
  id: number;
  description: string | null;
  name: string;
  name_with_namespace: string;
  path: string;
  path_with_namespace: string;
  created_at: string;
  default_branch: string;
  tag_list: string[];
  topics: string[];
  ssh_url_to_repo: string;
  http_url_to_repo: string;
  web_url: string;
  readme_url: string;
  forks_count: number;
  avatar_url: string | null;
  star_count: number;
  last_activity_at: string;
  namespace: GitLabProjectNamespace;
  container_registry_image_prefix: string;
  _links: GitLabProjectLinks;
  packages_enabled: boolean;
  empty_repo: boolean;
  archived: boolean;
  visibility: string;
  resolve_outdated_diff_discussions: boolean;
  container_expiration_policy: GitLabProjectContainerExpirationPolicy;
  repository_object_format: string;
  issues_enabled: boolean;
  merge_requests_enabled: boolean;
  wiki_enabled: boolean;
  jobs_enabled: boolean;
  snippets_enabled: boolean;
  container_registry_enabled: boolean;
  service_desk_enabled: boolean;
  service_desk_address: string;
  can_create_merge_request_in: boolean;
  issues_access_level: string;
  repository_access_level: string;
  merge_requests_access_level: string;
  forking_access_level: string;
  wiki_access_level: string;
  builds_access_level: string;
  snippets_access_level: string;
  pages_access_level: string;
  analytics_access_level: string;
  container_registry_access_level: string;
  security_and_compliance_access_level: string;
  releases_access_level: string;
  environments_access_level: string;
  feature_flags_access_level: string;
  infrastructure_access_level: string;
  monitor_access_level: string;
  model_experiments_access_level: string;
  model_registry_access_level: string;
  emails_disabled: boolean;
  emails_enabled: boolean;
  shared_runners_enabled: boolean;
  lfs_enabled: boolean;
  creator_id: number;
  import_url: string | null;
  import_type: string | null;
  import_status: string;
  import_error: string | null;
  open_issues_count: number;
  description_html: string;
  updated_at: string;
  ci_default_git_depth: number;
  ci_forward_deployment_enabled: boolean;
  ci_forward_deployment_rollback_allowed: boolean;
  ci_job_token_scope_enabled: boolean;
  ci_separated_caches: boolean;
  ci_allow_fork_pipelines_to_run_in_parent_project: boolean;
  ci_id_token_sub_claim_components: string[];
  build_git_strategy: string;
  keep_latest_artifact: boolean;
  restrict_user_defined_variables: boolean;
  ci_pipeline_variables_minimum_override_role: string;
  runners_token: string | null;
  runner_token_expiration_interval: number | null;
  group_runners_enabled: boolean;
  auto_cancel_pending_pipelines: string;
  build_timeout: number;
  auto_devops_enabled: boolean;
  auto_devops_deploy_strategy: string;
  ci_push_repository_for_job_token_allowed: boolean;
  ci_config_path: string;
  public_jobs: boolean;
  shared_with_groups: any[];
  only_allow_merge_if_pipeline_succeeds: boolean;
  allow_merge_on_skipped_pipeline: boolean | null;
  request_access_enabled: boolean;
  only_allow_merge_if_all_discussions_are_resolved: boolean;
  remove_source_branch_after_merge: boolean;
  printing_merge_request_link_enabled: boolean;
  merge_method: string;
  squash_option: string;
  enforce_auth_checks_on_uploads: boolean;
  suggestion_commit_message: string | null;
  merge_commit_template: string | null;
  squash_commit_template: string | null;
  issue_branch_template: string | null;
  warn_about_potentially_unwanted_characters: boolean;
  autoclose_referenced_issues: boolean;
  external_authorization_classification_label: string;
  requirements_enabled: boolean;
  requirements_access_level: string;
  security_and_compliance_enabled: boolean;
  compliance_frameworks: any[];
  permissions: GitLabProjectPermissions;
}

export interface GitLabProjectNamespace {
  id: number;
  name: string;
  path: string;
  kind: string;
  full_path: string;
  parent_id: number;
  avatar_url: string;
  web_url: string;
}

export interface GitLabProjectLinks {
  self: string;
  issues: string;
  merge_requests: string;
  repo_branches: string;
  labels: string;
  events: string;
  members: string;
  cluster_agents: string;
}

export interface GitLabProjectContainerExpirationPolicy {
  cadence: string;
  enabled: boolean;
  keep_n: number;
  older_than: string;
  name_regex: string;
  name_regex_keep: string | null;
  next_run_at: string;
}

export interface GitLabProjectPermissions {
  project_access: any | null;
  group_access: GitLabProjectGroupAccess;
}

export interface GitLabProjectGroupAccess {
  access_level: number;
  notification_level: number;
}

export interface GitLabProjectValuesProp {
  projects: SelectableListItem<number>[];
}

export interface GitHubUser {
  id: number;
  gitlab_id: number;
  user_id: number;
  name: string;
  username: string;
  redmine_user: any | null;
  redmine_user_id: number | null;
}

export interface GitHub {
  name: string;
  url: string;
  api_token: string;
  active: boolean;
  users: GitHubUser[];
}

export interface GitHubValuesProp {
  users: SelectableListItem<number>[];
}

export interface GitHubRepository {
  id: number;
  gitlab_id: number;
  repository_id: number;
  name: string;
  name_with_namespace: string;
  path: string;
  path_with_namespace: string;
  created_at: string;
  updated_at: string;
  projects: number[];
  web_url: string;
  git_http_url: string;
  git_ssh_url: string;
  remote_info: GitHubRepositoryRemoteInfo;
}

export interface GitHubRepositoryRemoteInfo {
  id: number;
  node_id: string;
  name: string;
  full_name: string;
  private: boolean;
  owner: GitHubRepositoryRemoteInfoOwner;
  html_url: string;
  description: string | null;
  fork: boolean;
  url: string;
  forks_url: string;
  keys_url: string;
  collaborators_url: string;
  teams_url: string;
  hooks_url: string;
  issue_events_url: string;
  events_url: string;
  assignees_url: string;
  branches_url: string;
  tags_url: string;
  blobs_url: string;
  git_tags_url: string;
  git_refs_url: string;
  trees_url: string;
  statuses_url: string;
  languages_url: string;
  stargazers_url: string;
  contributors_url: string;
  subscribers_url: string;
  subscription_url: string;
  commits_url: string;
  git_commits_url: string;
  comments_url: string;
  issue_comment_url: string;
  contents_url: string;
  compare_url: string;
  merges_url: string;
  archive_url: string;
  downloads_url: string;
  issues_url: string;
  pulls_url: string;
  milestones_url: string;
  notifications_url: string;
  labels_url: string;
  releases_url: string;
  deployments_url: string;
  created_at: string;
  updated_at: string;
  pushed_at: string;
  git_url: string;
  ssh_url: string;
  clone_url: string;
  svn_url: string;
  homepage: string | null;
  size: number;
  stargazers_count: number;
  watchers_count: number;
  language: string | null;
  has_issues: boolean;
  has_projects: boolean;
  has_downloads: boolean;
  has_wiki: boolean;
  has_pages: boolean;
  has_discussions: boolean;
  forks_count: number;
  mirror_url: string | null;
  archived: boolean;
  disabled: boolean;
  open_issues_count: number;
  license: GitHubRepositoryRemoteInfoLicense | null;
  allow_forking: boolean;
  is_template: boolean;
  web_commit_signoff_required: boolean;
  topics: string[];
  visibility: string;
  forks: number;
  open_issues: number;
  watchers: number;
  default_branch: string;
  permissions: GitHubRepositoryRemoteInfoPermissions;
  temp_clone_token: string;
  allow_squash_merge: boolean;
  allow_merge_commit: boolean;
  allow_rebase_merge: boolean;
  allow_auto_merge: boolean;
  delete_branch_on_merge: boolean;
  allow_update_branch: boolean;
  use_squash_pr_title_as_default: boolean;
  squash_merge_commit_message: string;
  squash_merge_commit_title: string;
  merge_commit_message: string;
  merge_commit_title: string;
  security_and_analysis: GitHubRepositoryRemoteInfoSecurityAndAnalysis;
  network_count: number;
  subscribers_count: number;
}

export interface GitHubRepositoryRemoteInfoOwner {
  login: string;
  id: number;
  node_id: string;
  avatar_url: string;
  gravatar_id: string;
  url: string;
  html_url: string;
  followers_url: string;
  following_url: string;
  gists_url: string;
  starred_url: string;
  subscriptions_url: string;
  organizations_url: string;
  repos_url: string;
  events_url: string;
  received_events_url: string;
  type: string;
  user_view_type: string;
  site_admin: boolean;
}

export interface GitHubRepositoryRemoteInfoLicense {
  key: string;
  name: string;
  spdx_id: string;
  url: string | null;
  node_id: string;
}

export interface GitHubRepositoryRemoteInfoPermissions {
  admin: boolean;
  maintain: boolean;
  push: boolean;
  triage: boolean;
  pull: boolean;
}

export interface GitHubRepositoryRemoteInfoSecurityAndAnalysis {
  secret_scanning: GitHubRepositoryRemoteInfoSecurityItem;
  secret_scanning_push_protection: GitHubRepositoryRemoteInfoSecurityItem;
  dependabot_security_updates: GitHubRepositoryRemoteInfoSecurityItem;
  secret_scanning_non_provider_patterns: GitHubRepositoryRemoteInfoSecurityItem;
  secret_scanning_validity_checks: GitHubRepositoryRemoteInfoSecurityItem;
}

export interface GitHubRepositoryRemoteInfoSecurityItem {
  status: string;
}

export interface GitHubRepositoryValuesProp {
  projects: SelectableListItem<number>[];
}

export interface ProjectMember {
  id: number;
  roles: number[];
}

export interface ProjectEnumeration {
  custom_field_values: Record<string, string | null>;
  active: boolean;
}

export interface ProjectModelIssueCategory {
  name: string;
  assigned_to_id: number;
}

export interface ProjectModel {
  id: number | null;
  name: string;
  description: string | null;
  homepage: string;
  is_public: boolean;
  parent_id: number | null;
  created_on: string | null;
  updated_on: string | null;
  identifier: string | null;
  status: number;
  lft: number | null;
  rgt: number | null;
  inherit_members: boolean;
  default_version_id: number | null;
  default_assigned_to_id: number | null;
  default_issue_query_id: number | null;
  avatar: string | null;
  banner: string | null;
  custom_field_values: Record<string, string | null>;
  enabled_module_names: string[];
  tracker_ids: number[];
  issue_custom_field_ids: number[];
  gitlab_projects: number[];
  github_repositories: number[];
  gitlab_project_ids: number[];
  github_repository_ids: number[];
  eumerations: Record<string, ProjectEnumeration>;
  issue_categories: ProjectModelIssueCategory[];
  activities: number[];
}

export interface ProjectIssueCategory {
  assigned_to_id: number | null;
  id: number;
  name: string;
  project_id: number;
}

export interface ProjectVersion {
  id: number;
  project_id: number;
  name: string;
  description: string | null;
  effective_date: string | null;
  created_on: string;
  updated_on: string | null;
  wiki_page_title: string | null;
  status: "open" | "locked" | "closed";
  sharing: "none" | "descendants" | "hierarchy" | "tree" | "system";
}

export interface ProjectRepository {
  id: number;
  project_id: number;
  url: string;
  login: string;
  password: string;
  root_url: string;
  type: string;
  path_encoding: string;
  log_encoding: string;
  extra_info: string;
  identifier: string;
  is_default: boolean;
  created_on: string;
}

export interface ProjectCustomField {
  default_value: string | boolean | number | null;
  description: string;
  editable: boolean;
  field_format:
    | "attachment"
    | "bool"
    | "date"
    | "enumeration"
    | "float"
    | "int"
    | "link"
    | "list"
    | "string"
    | "text"
    | "user"
    | "version";
  format_store: any;
  id: number;
  is_filter: boolean;
  is_for_all: boolean;
  is_required: boolean;
  max_length: number | null;
  min_length: number | null;
  multiple: boolean;
  name: string;
  position: number;
  possible_values: string[] | number[] | null;
  regexp: string | null;
  searchable: boolean;
  visible: boolean;
  enumerations: EnumerableValue[];
}

export interface ProjectValuesPropMember extends SelectableListItem<number> {
  kind: "user" | "group";
}

export interface ProjectValuesActivity extends SelectableListItem<number> {
  is_system: boolean;
}

export interface ProjectValuesStatus extends SelectableListItem<number> {
  disabled?: boolean;
  color: string;
  icon: string;
}

export interface ProjectValuesRole extends SelectableListItem<number> {
  assignable: boolean;
  external: boolean;
}

export interface ProjectValuesProp {
  identifierMaxLength: number;
  members: ProjectValuesPropMember[];
  modules: SelectableListItem<string>[];
  trackers: SelectableListItem<number>[];
  activities: ProjectValuesActivity[];
  versions: SelectableListItem<number>[];
  assignees: SelectableListItem<number>[];
  queries: SelectableListItem<number>[];
  gitlabProjects: SelectableListItem<number>[];
  parents: SelectableListItem<number>[];
  issueCustomFields: IssueCustomField[];
  statuses: ProjectValuesStatus[];
  roles: ProjectValuesRole[];
}

export interface ProjectPermissions {
  add_project: boolean;
  edit_project: boolean;
  close_project: boolean;
  delete_project: boolean;
  select_project_publicity: boolean;
  select_project_modules: boolean;
  manage_members: boolean;
  manage_versions: boolean;
  add_subprojects: boolean;
  manage_public_queries: boolean;
  save_queries: boolean;
  view_associated_gitlab_projects: boolean;
  manage_associated_gitlab_projects: boolean;
  view_associated_github_repositories: boolean;
  manage_associated_github_repositories: boolean;
  view_time_entries: boolean;
  view_issues: boolean;
  view_files: boolean;
  manage_files: boolean;
  view_documents: boolean;
  add_documents: boolean;
}

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

export interface Author {
  id: number;
  login: string;
  firstname: string;
  lastname: string;
}

export interface FridayMenuItem {
  children: FridayMenuItem[] | null;
  key: string;
  title: string;
  to: {
    name: string;
    params?: Record<string, string | number>;
  };
}

export interface ProjectWikiPageLink {
  id: number;
  title: string;
  url: string;
  parent: number | null;
}

export interface ProjectDocumentLink {
  id: number;
  title: string;
  description: string;
  category: string;
  attachment: File;
}

export interface File {
  author_id: number;
  container_id: number;
  container_type: string;
  content_type: string;
  created_on: string;
  description: string;
  digest: string;
  disk_directory: string;
  disk_filename: string;
  downloads: number;
  filename: string;
  filesize: number;
  id: number;
}

// export interface ProjectModelForShow extends ProjectModel {
//   principalsByRole: Record<string, Principal[]>;
//   subprojects: ProjectModel[];
//   news: News[];
//   trackers: Tracker[];
//   openIssuesByTracker: Record<string, number>;
//   totalIssuesByTracker: Record<string, number>;
//   totalHours: number | null;
//   totalEstimatedHours: number | null;
//   gitlabProjects: GitLabProject[];
// }

export interface Monday {
  name: string;
  api_token: string;
  active: boolean;
  users: MondayUser[];
}

export interface MondayUser {
  created_at: string;
  id: number;
  monday_id: string;
  redmine_user: any | null;
  redmine_user_id: number | null;
  updated_at: string;
  user_id: number;
  user_meta_data: {
    email: string;
    id: string;
    name: string;
    photo_original: string;
    title: string | null;
  };
}

export interface MondayValuesProp {
  users: SelectableListItem<number>[];
}

export type MondayFieldType =
  | "button"
  | "checkbox"
  | "color_picker"
  | "board_relation"
  | "country"
  | "creation_log"
  | "date"
  | "dependency"
  | "dropdown"
  | "email"
  | "file"
  | "formula"
  | "hour"
  | "item_id"
  | "last_updated"
  | "link"
  | "location"
  | "long_text"
  | "mirror"
  | "doc"
  | "name"
  | "numbers"
  | "people"
  | "phone"
  | "rating"
  | "status"
  | "tags"
  | "text"
  | "timeline"
  | "time_tracking"
  | "vote"
  | "week"
  | "world_clock"
  | "auto_number"
  | "progress";

export interface MondayBoardColumn {
  id: string;
  type: MondayFieldType;
  title: string;
  settings_str: string;
}

export interface MondayBoard {
  id: number;
  monday_id: number;
  project_id: number;
  monday_board_id: string;
  board_meta_data: {
    columns: MondayBoardColumn[];
    description: string | null;
    id: string;
    item_terminology: string;
    name: string;
    state: string;
    type: string;
    url: string;
  };
  board_field_mapping: Record<string, string>;
}

export interface MondayFridayField extends SelectableListItem<string> {
  monday_can_edit: boolean;
  monday_types: MondayFieldType[];
}

export interface MondayBoardValuesProp {
  projects: SelectableListItem<number>[];
  fields: MondayFridayField[];
}

export interface ProjectPrincipalMembership {
  principal: number;
  roles: number[];
}

export type ActivityEventType =
  | "attachment"
  | "changeset"
  | "document"
  | "issue"
  | "issue-closed"
  | "issue-edit"
  | "issue-note"
  | "message"
  | "reply"
  | "news"
  | "project"
  | "time-entry"
  | "wiki-page"
  | "remote-git-commit"
  | "remote-git-merge-request-opened"
  | "remote-git-merge-request-merged"
  | "remote-git-merge-request-closed"
  | "remote-git-pipeline-started"
  | "remote-git-pipeline-ended"
  | "remote-git-release"
  | "remote-git-tag";

export interface ActivityEvent {
  datetime: string;
  title: string;
  description: string;
  author: {
    id: number;
    name: string;
  } | null;
  url: string | null;
  type: ActivityEventType;
}

export interface ProjectVersionIssueRelatedProperty {
  id: number;
  name: string;
}

export interface ProjectVersionIssue {
  id: number;
  subject: string;
  tracker: ProjectVersionIssueRelatedProperty;
  status: ProjectVersionIssueRelatedProperty;
  project: ProjectVersionIssueRelatedProperty;
  priority: number;
}

export interface ProjectReleaseVersion {
  id: number;
  name: string;
  status: string;
  sharing: string;
  project_id: number;
  completed: boolean;
  issues: ProjectVersionIssue[];
  count_issues_total: number;
  count_issues_open: number;
  count_issues_closed: number;
  percent_issues_closed: number;
  percent_issues_completed: number;
  can_edit: boolean;
}

export interface ProjectReleaseVersionPermissions {
  manage_versions: boolean;
}

export interface TimeEntry {
  activity: {
    active: boolean;
    color: string | null;
    id: number;
    is_default: boolean;
    name: string;
    parent_id: number | null;
    position: number;
    position_name: string;
    project_id: number;
  };
  comments: string;
  hours: number;
  issue: Issue;
  spent_on: string;
  user: User;
}

export interface CalendarResponse {}

export interface NewsResponse {
  articles: News[];
  total: number;
  pages: number;
}

export interface Doc {}

export interface WikiResponse {
  toc: WikiTableOfContents[];
  permissions: {
    edit_wiki_pages: boolean;
    export_wiki_pages: boolean;
    view_wiki_edits: boolean;
  };
}

export interface AttachedFile {}

export interface QueryResponseGanttEntryDependencyMarker {
  fillColor: string;
  lineColor: string;
  lineWidth: number;
  radius: number;
  symbol: string;
}

export interface QueryResponseGanttEntryDependency {
  dashStyle: string;
  endMarker: QueryResponseGanttEntryDependencyMarker;
  lineColor: string;
  lineWidth: number;
  startMarker: QueryResponseGanttEntryDependencyMarker;
  to: string;
  type: string;
}

export interface QueryResponseGanttEntry {
  color: string;
  completed: number;
  custom: {
    id: number;
    model: string;
    assignee: string | null;
    route: {
      name: string;
      params: Record<string, string>;
    };
  };
  dependancy: QueryResponseGanttEntryDependency[];
  description: string;
  end: number;
  id: string;
  labelrank: number;
  name: string;
  start: number;
}

export interface QueryResponseGanttSeries {
  name: string;
  custom: {
    count: unknown;
    totals: unknown;
  };
  data: Array<QueryResponseGanttEntry>;
  type: "gantt";
}

export interface QueryResponseGanttPayload {
  items: Array<QueryResponseGanttSeries>;
  items_length: number;
  items_per_page: number;
  page: number;
  pages: PageDetails;
  totals: Array<ColumnTotal>;
}

export interface QueryResponseGantt {
  params: QueryResponseParams;
  payload: QueryResponseGanttPayload;
  query: QueryData;
  queries: Array<DefinedQuery>;
  permissions: Permissions;
  creatable: Array<Createable>;
}

export const makeNewQueryPayloadFromQueryAndQueryGanttPayload = (
  query: QueryData,
  payload: QueryResponseGanttPayload,
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

export interface WikiTableOfContents {
  id: number;
  path: string;
  title: string;
  children: WikiTableOfContents[] | null;
}

export default {
  actions: {
    login: "Sign In",
    register: "Register",
  },
  pages: {
    home: { title: "Home" },
    projects: { title: "Projects" },
    help: { title: "Help" },
    search: { title: "Search" },
    "account-activate": { title: "" },
    "account-activation-email": { title: "" },
    "account-lost-password": { title: "" },
    "account-register": { title: "" },
    "account-twofa": { title: "" },
    "account-twofa-confirm": { title: "" },
    activity: { title: "Activity" },
    admin: { title: "Administration", menu: { title: "View All" } },
    "admin-info": {
      title: "System Information",
      content: {
        redmine: "Redmine Build Version",
        checklist: {
          defaultAdministratorAccountChanged:
            "Default administrator account changed",
          fileRepositoryWritable: "Attachments directory writable",
          pluginAssetsWritable: "Plugin assets directory writable",
          allMigrationsHaveBeenRun: "All database migrations have been run",
          minimagickAvailable: "MiniMagick available",
          convertAvailable: "ImageMagick convert available",
          gsAvailable: "ImageMagick PDF support available",
          defaultActiveJobQueueChanged: "Default queue adapter changed",
        },
      },
    },
    "admin-plugins": { title: "Integrated Plugins" },
    "admin-projects-context-menu": { title: "" },
    "admin-projects": { title: "Project Management" },
    "admin-sidekiq": {
      title: "Sidekiq Information",
      content: {
        stats: {
          processed: "Processed",
          failed: "Failed",
          busy: "Busy",
          scheduled_size: "Scheduled",
          retry_size: "Retries",
          enqueued: "Enqueued",
        },
      },
    },
    "attachments-id": { title: "" },
    "attachments-id-filename": { title: "" },
    "attachments-object-type-object-id-download": { title: "" },
    "attachments-object-type-object-id-edit": { title: "" },
    "attachments-download-id": { title: "" },
    "attachments-download-id-filename": { title: "" },
    "auth-sources": {
      title: "",
      admin: { title: "Authentication Source Management" },
    },
    "auth-sources-id": { title: "" },
    "auth-sources-id-edit": { title: "" },
    "auth-sources-id-test-connection": { title: "" },
    "auth-sources-autocomplete-for-new-user": { title: "" },
    "auth-sources-new": { title: "" },
    "boards-board-id-topics-id": { title: "" },
    "boards-board-id-topics-id-edit": { title: "" },
    "boards-board-id-topics-new": { title: "" },
    "boards-board-id-topics-quote-id": { title: "" },
    "custom-fields": { title: "", admin: { title: "Custom Field Management" } },
    "custom-fields-custom-field-id-enumerations": { title: "" },
    "custom-fields-id-edit": { title: "" },
    "custom-fields-new": { title: "" },
    "documents-id": { title: "" },
    "documents-id-edit": { title: "" },
    enumerations: { title: "", admin: { title: "Enumeration Management" } },
    "enumerations-id-edit": { title: "" },
    "enumerations-type": { title: "" },
    "enumerations-new": { title: "" },
    groups: { title: "", admin: { title: "Group Management" } },
    "groups-group-id-memberships": { title: "" },
    "groups-group-id-memberships-id": { title: "" },
    "groups-group-id-memberships-id-edit": { title: "" },
    "groups-group-id-memberships-new": { title: "" },
    "groups-id": { title: "" },
    "groups-id-autocomplete-for-user": { title: "" },
    "groups-id-edit": { title: "" },
    "groups-id-users-new": { title: "" },
    "groups-new": { title: "" },
    "imports-id": { title: "" },
    "imports-id-mapping": { title: "" },
    "imports-id-run": { title: "" },
    "imports-id-settings": { title: "" },
    "issue-categories-id": { title: "" },
    "issue-categories-id-edit": { title: "" },
    "issue-statuses": {
      title: "",
      admin: { title: "Issue Status Management" },
    },
    "issue-statuses-id-edit": { title: "" },
    "issue-statuses-new": { title: "" },
    issues: { title: "Issues" },
    "issues-id": { title: "" },
    "issues-id-edit": { title: "" },
    "issues-id-tab-name": { title: "" },
    "issues-issue-id-relations": { title: "" },
    "issues-issue-id-time-entries-new": { title: "" },
    "issues-auto-complete": { title: "" },
    "issues-bulk-edit": { title: "" },
    "issues-calendar": { title: "Calendar" },
    "issues-changes": { title: "" },
    "issues-context-menu": { title: "" },
    "issues-gantt": { title: "Gantt" },
    "issues-imports-new": { title: "" },
    "issues-new": { title: "" },
    "issues-preview": { title: "" },
    "journals-id-diff": { title: "" },
    "journals-id-edit": { title: "" },
    login: {
      title: "Log In",
      content: {
        form: {
          header: "Login to {name}",
        },
      },
      dialog: {
        success: {
          title: "Welcome",
        },
      },
    },
    logout: {
      title: "Logging Out",
      content: {
        form: {
          header: "Signing out of your {name} account",
        },
        pleaseWaitWhileProcessing:
          "Please wait a moment while we process your request. You will be redirected when complete.",
      },
    },
    "mail-handler": { title: "" },
    "memberships-id": { title: "" },
    "memberships-id-edit": { title: "" },
    my: { title: "My Page" },
    "my-account": { title: "My Account" },
    "my-account-destroy": { title: "Delete my Account" },
    "my-api-key": { title: "My API Key" },
    "my-page": { title: "My Page" },
    "my-password": { title: "My Password" },
    "my-twofa-scheme-activate": { title: "" },
    "my-twofa-scheme-activate-confirm": { title: "" },
    "my-twofa-scheme-deactivate": { title: "" },
    "my-twofa-scheme-deactivate-confirm": { title: "" },
    "my-twofa-backup-codes": { title: "" },
    "my-twofa-backup-codes-confirm": { title: "" },
    "my-twofa-backup-codes-create": { title: "" },
    "my-twofa-select-scheme": { title: "" },
    news: { title: "News" },
    "news-id": { title: "" },
    "news-id-edit": { title: "" },
    "news-new": { title: "" },
    "news-preview": { title: "" },
    "preview-text": { title: "" },
    "projects-id": { title: "" },
    "projects-id-activity": { title: "" },
    "projects-id-copy": { title: "" },
    "projects-id-edit": { title: "" },
    "projects-id-issues-report": { title: "" },
    "projects-id-issues-report-detail": { title: "" },
    "projects-id-repository": { title: "" },
    "projects-id-repository-repository-id": { title: "" },
    "projects-id-repository-repository-id-annotate-path": { title: "" },
    "projects-id-repository-repository-id-browse-path": { title: "" },
    "projects-id-repository-repository-id-changes-path": { title: "" },
    "projects-id-repository-repository-id-diff-path": { title: "" },
    "projects-id-repository-repository-id-entry-path": { title: "" },
    "projects-id-repository-repository-id-graph": { title: "" },
    "projects-id-repository-repository-id-raw-path": { title: "" },
    "projects-id-repository-repository-id-revision": { title: "" },
    "projects-id-repository-repository-id-revisions": { title: "" },
    "projects-id-repository-repository-id-revisions-rev": { title: "" },
    "projects-id-repository-repository-id-show-path": { title: "" },
    "projects-id-repository-repository-id-statistics": { title: "" },
    "/projects/:id/search": { title: "" },
    "projects-id-settings-tab": { title: "" },
    "projects-id-wiki-destroy": { title: "" },
    "projects-project-id-boards": { title: "" },
    "projects-project-id-boards-id": { title: "" },
    "projects-project-id-boards-id-edit": { title: "" },
    "projects-project-id-boards-new": { title: "" },
    "projects-project-id-documents": { title: "" },
    "projects-project-id-documents-new": { title: "" },
    "projects-project-id-files": { title: "" },
    "projects-project-id-files-new": { title: "" },
    "projects-project-id-issue-categories": { title: "" },
    "projects-project-id-issue-categories-new": { title: "" },
    "projects-project-id-issues": { title: "" },
    "projects-project-id-issues-copy-from-copy": { title: "" },
    "projects-project-id-issues-calendar": { title: "" },
    "projects-project-id-issues-gantt": { title: "" },
    "projects-project-id-issues-new": { title: "" },
    "projects-project-id-memberships": { title: "" },
    "projects-project-id-memberships-autocomplete": { title: "" },
    "projects-project-id-memberships-new": { title: "" },
    "projects-project-id-news": { title: "" },
    "projects-project-id-news-new": { title: "" },
    "projects-project-id-queries-new": { title: "" },
    "projects-project-id-repositories-new": { title: "" },
    "projects-project-id-roadmap": { title: "" },
    "projects-project-id-time-entries": { title: "" },
    "projects-project-id-time-entries-new": { title: "" },
    "projects-project-id-time-entries-report": { title: "" },
    "projects-project-id-versions": { title: "" },
    "projects-project-id-versions-new": { title: "" },
    "projects-project-id-wiki": { title: "" },
    "projects-project-id-wiki-id": { title: "" },
    "projects-project-id-wiki-id-version": { title: "" },
    "projects-project-id-wiki-id-version-annotate": { title: "" },
    "projects-project-id-wiki-id-version-diff": { title: "" },
    "projects-project-id-wiki-id-diff": { title: "" },
    "projects-project-id-wiki-id-edit": { title: "" },
    "projects-project-id-wiki-id-history": { title: "" },
    "projects-project-id-wiki-id-rename": { title: "" },
    "projects-project-id-wiki-date-index": { title: "" },
    "projects-project-id-wiki-export": { title: "" },
    "projects-project-id-wiki-index": { title: "" },
    "projects-project-id-wiki-new": { title: "" },
    "projects-autocomplete": { title: "" },
    "projects-new": { title: "" },
    queries: { title: "" },
    "queries-id-edit": { title: "" },
    "queries-filter": { title: "" },
    "queries-new": { title: "" },
    "relations-id": { title: "" },
    "repositories-id-committers": { title: "" },
    "repositories-id-edit": { title: "" },
    roles: { title: "", admin: { title: "Role Management" } },
    "roles-id": { title: "" },
    "roles-id-edit": { title: "" },
    "roles-new": { title: "" },
    "roles-permissions": { title: "" },
    settings: {
      title: "System Settings",
      admin: { title: "System Settings" },
      onSave: {
        success: "Settings updated successfully",
        error: "An error occurred while updating the settings",
      },
      content: {
        tabs: {
          general: "General",
          display: "Display",
          authentication: "Authentication",
          api: "API",
          projects: "Projects",
          users: "Users",
          issues: "Issue Tracking",
          activities: "Time Tracking",
          files: "Files",
          notifications: "Notifications",
          email: "Incoming Email",
          repositories: "Repositories",
          monday_com: "Monday.com Integration",
          gitlab: "GitLab Integration",
          sentry: "Sentry Integration",
          google_translate: "Google Translate Integration",
          chat_gpt: "ChatGPT Integration",
          slack: "Slack Integration",
          pagerduty: "PagerDuty Integration",
        },
        fields: {
          app_title: "Application Title",
          welcome_text: "Welcome Text",
          per_page_options: "Objects per page options",
          search_results_per_page: "Search results per page",
          activity_days_default: "Days displayed on project activity",
          host_name: "Host name and path",
          protocol: "Protocol",
          wiki_compression: "Wiki history compression",
          feeds_limit: "Max # of items in Atom feeds",
          default_language: "Default language",
          force_default_language_for_anonymous:
            "Force default language for anonymous users",
          force_default_language_for_loggedin:
            "Force default language for logged-in users",
          user_format: "User Display Format",
          gravatar_enabled: "Use Gravatar Icons",
          gravatar_default: "Default Gravatar Icon",
          login_required: "Authentication required",
          self_registration: "Self-registration",
          show_custom_fields_on_registration:
            "Show custom fields on registration",
          password_min_length: "Minimum password length",
          password_required_char_classes:
            "Required character classes for passwords",
          password_max_age: "Require password change after",
          lost_password: "Allow lost password recovery",
          twofa: "Two-factor authentication",
          session_lifetime: "Session Maxium Lifetime",
          session_timeout: "Session Inactivity Timeout",
          rest_api_enabled: "Enable RESTful API",
          jsonp_enabled: "Enable JSONP support",
          default_projects_public: "New Projects are public by default",
          default_projects_modules: "Default enabled modules for new projects",
          default_projects_tracker_ids:
            "Default issue trackers for new projects",
          sequential_project_identifiers:
            "Generate sequential project identifiers",
          new_project_user_role_id:
            "Role for non-admin user that creates a project",
          default_project_query: "Default project query",
          max_additional_emails: "Maximum number of additional email addresses",
          email_domains_allowed: "Allowed email domains",
          email_domains_denied: "Disallowed email domains",
          unsubscribe: "Allow users to delete their own account",
          default_users_hide_mail: "Hide user emails by default",
          default_notification_option: "Default notification option",
          default_users_no_self_notified: "Don't notify own changes by default",
          default_users_time_zone: "Default time zone",
          cross_project_issue_relations: "Allow cross-project issue relations",
          link_copied_issue: "Link issues on copy",
          cross_project_subtasks: "Allow cross-project subtasks",
          close_duplicate_issues: "Close duplicate issues automatically",
          issue_group_assignment: "Allow issues to be assigned to groups",
          default_issue_start_date_to_creation_date:
            "Use current date as start date for new issues",
          display_subprojects_issues:
            "Display subprojects issues on main project by default",
          issue_done_ratio: "Calculate the issue done ratio using",
          non_working_week_days: "Non-working week days",
          issues_export_limit: "Issues export limit",
          gantt_items_limit: "Max items displayed in Gantt chart",
          gantt_months_limit: "Max months displayed in Gantt chart",
          parent_issue_dates: "Parent issue start/due dates",
          parent_issue_done_ratio: "Parent issue done ratio",
          issue_list_default_columns: "Default Columns Displayed",
          issue_list_default_totals: "Default Totals Displayed",
          default_issue_query: "Default issue query",
          timelog_required_fields: "Required fields for time logs",
          timelog_max_hours_per_day: "Max hours per day per user",
          timelog_accept_0_hours: "Allow time logs with 0 hours",
          timelog_accept_future_dates: "Allow time logs with future dates",
          attachment_max_size: "Max Upload Size",
          bulk_download_max_size: "Max total size of bulk download",
          attachment_extensions_allowed: "Allowed Upload Extensions",
          attachment_extensions_denied: "Disallowed Upload Extensions",
          file_max_size_displayed: "Max size of inline displayed files",
          diff_max_lines_displayed: "Max lines displayed in diff",
          repositories_encodings: "Allowed Encodings",
          mail_from: "Email Sender Address",
          plain_text_mail: "Send plaintext emails only",
          show_status_changes_in_mail_subject:
            "Show status changes in issue mail subject",
          notified_events: "Actions to notify by email",
          emails_header: "Email Header",
          emails_footer: "Email Footer",
          mail_handler_body_delimiters: "Truncate emails after",
          mail_handler_enable_regex_delimiters: "Enable regular expressions",
          mail_handler_excluded_filenames: "Excluded attachment filenames",
          mail_handler_enable_regex_excluded_filenames:
            "Enable regular expressions",
          mail_handler_preferred_body_part: "Preferred part of HTML emails",
          mail_handler_api_enabled: "Enable Webservice for incoming emails",
          mail_handler_api_key: "Incoming email Webservice API key",
          enabled_scm: "Enabled Version Control Systems",
          autofetch_changesets: "Fetch commits automatically",
          sys_api_enabled: "Enable Webservice for Repository Management",
          sys_api_key: "Repository Management API Key",
          repository_log_display_limit:
            "Maximum number of revisions displayed on file log",
          commit_logs_formatting: "Apply text formatting to commit messages",
          commit_ref_keywords: "Referencing keywords",
          commit_cross_project_ref:
            "Allow issues of all other projects to be referenced and fixed",
          commit_logtime_enabled: "Enable time logging",
          commit_logtime_activity_id: "Activity for time logging",
          commit_update_keywords: "Auto-Update on Commit Rules",
          project_list_defaults: {
            column_names: "Default Columns Displayed",
          },
          time_entry_list_defaults: {
            column_names: "Default Columns Displayed",
            totalable_names: "Default Totals Displayed",
          },
        },
      },
    },
    "settings-edit": { title: "System Settings" },
    "settings-plugin-id": {
      title: "Manage Plugin",
      specificTitle: "{plugin} Configuration",
      content: {
        incompatible: {
          headline: "I'm sorry Dave, I'm afraid I can't do that.",
          title: "Incompatible Plugin",
          text: "This plugin cannot be managed via the Friday UI. Please disable the Friday UI to manage this plugin.",
        },
      },
      fields: {
        repository_base_path: "Repository Storage Directory Path",
        monday_access_token: "Monday.com API Access Token",
        monday_board_id: "Monday.com Board ID",
        monday_group_id: "Monday.com Board Group ID",
        monday_enabled: "Enable Monday.com Integration",
        gitlab_api_base_url: "GitLab API Base URL",
        gitlab_api_token: "GitLab API Token",
        gitlab_api_enabled: "Enable GitLab Integration",
        sentry_api_base_url: "Sentry API Base URL",
        sentry_api_token: "Sentry API Token",
        sentry_api_organization: "Sentry Organization Slug",
        sentry_api_enabled: "Enable Sentry Integration",
        google_translate_api_key: "Google Translate API Key",
        google_translate_enabled: "Enable Google Translate",
        chatgpt_api_key: "ChatGPT API Key",
        chatgpt_org_id: "ChatGPT Organization ID",
        chatgpt_project_id: "ChatGPT Project ID",
        chatgpt_enabled: "Enable ChatGPT",
      },
      onSave: {
        success: "Plugin settings saved successfully",
        error: "An error occurred while saving the plugin settings",
      },
    },
    "sys-fetch-changesets": { title: "" },
    "sys-projects": { title: "" },
    "time-entries": { title: "" },
    "time-entries-id": { title: "" },
    "time-entries-id-edit": { title: "" },
    "time-entries-bulk-edit": { title: "" },
    "time-entries-context-menu": { title: "" },
    "time-entries-imports-new": { title: "" },
    "time-entries-new": { title: "" },
    "time-entries-report": { title: "" },
    trackers: { title: "", admin: { title: "Tracker Management" } },
    "trackers-id-edit": { title: "" },
    "trackers-fields": { title: "" },
    "trackers-new": { title: "" },
    users: { title: "", admin: { title: "User Management" } },
    "users-id": { title: "" },
    "users-id-edit": { title: "" },
    "users-user-id-email-addresses": { title: "" },
    "users-user-id-memberships": { title: "" },
    "users-user-id-memberships-id": { title: "" },
    "users-user-id-memberships-id-edit": { title: "" },
    "users-user-id-memberships-new": { title: "" },
    "users-context-menu": { title: "" },
    "users-imports-new": { title: "" },
    "users-new": { title: "" },
    "versions-id": { title: "" },
    "versions-id-edit": { title: "" },
    "watchers-autocomplete-for-mention": { title: "" },
    "watchers-autocomplete-for-user": { title: "" },
    "watchers-new": { title: "" },
    "wiki-pages-auto-complete": { title: "" },
    workflows: { title: "", admin: { title: "Workflow Management" } },
    "workflows-copy": { title: "" },
    "workflows-edit": { title: "" },
    "workflows-permissions": { title: "" },
  },
  labels: {
    home: "Home",
    latestNews: "Latest News",
    allNews: "View all news",
    error: "Error",
    success: "Success",
    jumper: {
      title: "Jump to a Project",
      recent: "Recently Viewed",
      bookmarked: "Favorites",
      all: "All Projects",
    },
    all: "All",
    new: "New",
    none: "None",
    filters: "Filters",
    columns: "Columns",
    groupings: "Groupings",
    options: "Options",
    clear: "Clear",
    apply: "Apply",
    forgotPassword: "Forgot Password",
    loggedInAs: "Logged in as",
    queries: {
      operators: {
        "=": "is",
        "!": "is not",
        o: "open",
        c: "closed",
        "!*": "none",
        "*": "any",
        ">=": ">=",
        "<=": "<=",
        "><": "between",
        "<t+": "in less than",
        ">t+": "in more than",
        "><t+": "in the next",
        "t+": "in",
        nd: "tomorrow",
        t: "today",
        ld: "yesterday",
        nw: "next week",
        w: "this week",
        lw: "last week",
        l2w: "last 2 weeks",
        nm: "next month",
        m: "this month",
        lm: "last month",
        y: "this year",
        ">t-": "less than days ago",
        "<t-": "more than days ago",
        "><t-": "in the past",
        "t-": "days ago",
        "~": "contains",
        "!~": "doesn't contain",
        "*~": "contains any of",
        "^": "starts with",
        $: "ends with",
        "=p": "any issues in project",
        "=!p": "any issues not in project",
        "!p": "no issues in project",
        "*o": "any open issues",
        "!o": "no open issues",
        ev: "has been",
        "!ev": "has never been",
        cf: "changed from",
      },
      where: "Where",
      and: "and",
    },
    settings: {
      browser: "Local Settings",
      application: "{name} Administration",
    },
    clearAll: "Clear All",
    save: "Save",
    addFilter: "New Filter",
    displayType: "Show as",
    displayTypes: {
      board: "Board",
      list: "List",
    },
    groupBy: "Group by value of",
    selected: "Selected",
    available: "Available",
    active: "Active",
    inactive: "Inactive",
    archived: "Archived",
    public: "Public",
    private: "Private",
    main: "Main",
    more: "More",
    refresh: "Refresh",
    reset: "Reset",
    noFilters: "No filters selected",
    days: "days",
    showExpandable: "Additional Information",
    showTotalsFor: "Show Totals for",
    yes: "Yes",
    no: "No",
    sorting: "Sorting",
    current: "Current",
    order: {
      asc: "Asc.",
      desc: "Desc.",
    },
    configure: "Configure",
    generate: "Generate",
    add: "Add",
    remove: "Remove",
    repositoryCommitUpdateKeywords: {
      tracker: "Issue Tracker",
      keywords: "Keywords in Commit Message",
      status: "Status to Apply",
      percentages: "Done Ratio to Apply",
    },
  },
  theme: {
    base: {
      colorScheme: "Color Scheme",
    },
  },
  generics: {
    addedLine: "Added by {author} {when}",
    "404": {
      headline: "Whoops, 404",
      title: "Page not found",
      text: "The page you are looking for does not exist.",
    },
  },
  views: {
    "404": {
      title: "Page not found",
    },
  },
  fields: {
    username: "Username",
    password: "Password",
  },
  errors: {
    response: {
      not_json: {
        title: "Invalid Response",
        text: "The server returned an invalid response",
      },
      error: {
        title: "Operation Failed",
        text: "An error occurred while processing your request",
      },
    },
    copy: {
      failed: {
        caught: "Failed to copy to clipboard due to error: {0}",
      },
    },
    search: {
      failed: "Unable to search at this time",
    },
  },
  successes: {
    copy: "Copied to clipboard",
  },
  validation: {
    bad: "The value is not a valid {label}",
    notAFile: "Please select {label}",
    tooManyFiles: "Please select only 1 file",
    fileTooLarge: "The file you have selected is too large",
    invalidFileType:
      "The file you have selected is not an acceptable file type",
    fileTypeNotAccepted:
      "The file you have selected is not an acceptable file type",
    invalid: "Please enter your {label}",
    required: "Please enter your {label}",
    requiredSelection: "Please choose a {label}",
    requiredUpload: "Please select {label}",
    email: "Please enter a valid email address",
    min: "Your {label} must be at least {min} characters long",
    characters: "The {label} you have input contains invalid characters",
    invalidRsaId: "Please enter a valid {label}",
    country: "Please choose your country of residence",
    valid: "Please enter a valid {label}",
    alternatives: {
      all: "The value did not match all of the criteria.",
      any: "No alternative was found to test against the input due to try criteria.",
      match:
        "No alternative matched the input due to specific matching rules for at least one of the alternatives.",
      one: "The value matched more than one alternative schema.",
      types: "The provided input did not match any of the allowed types.",
    },
    any: {
      custom: "Please enter a valid {label}",
      default: "Please contact support",
      failover: "Please contact support",
      invalid: "The value matched a value listed in the invalid values.",
      only: "Only some values were allowed, the input didn't match any of them.",
      ref: "The input is not valid.",
      required: "A required value wasn't present.",
      unknown: "A value was present while it wasn't expected.",
    },
    boolean: {
      base: "{label} is required",
      accepted: "You must accept the {label}",
    },
    phone: {
      invalid: "Please enter a valid {label}",
      mobile: "Please enter a valid mobile number",
    },
    string: {
      alphanum: "{label} contains characters that are not alphanumeric.",
      alpha: "{label} contains non-alphabetic characters.",
      base: "{label} is required",
      country: "Please select a valid {label}",
      email: "Please enter a valid email.",
      empty: "{label} cannot be empty.",
      length: "{label} is not of the required length.",
      max: "{label} is longer than the maximum allowed length.",
      min: "{label} is shorter than the minimum allowed length.",
      pattern: {
        base: "{label} contains invalid characters.",
        name: "{label} contains invalid characters.",
        invert: {
          base: "{label} contains invalid characters.",
          name: "{label} contains invalid characters.",
        },
      },
    },
  },
  countries: {
    ad: "Andorra",
    ae: "United Arab Emirates",
    af: "Afghanistan",
    ag: "Antigua and Barbuda",
    ai: "Anguilla",
    al: "Albania",
    am: "Armenia",
    ao: "Angola",
    aq: "Antarctica",
    ar: "Argentina",
    as: "American Samoa",
    at: "Austria",
    au: "Australia",
    aw: "Aruba",
    ax: "Åland Islands",
    az: "Azerbaijan",
    ba: "Bosnia and Herzegovina",
    bb: "Barbados",
    bd: "Bangladesh",
    be: "Belgium",
    bf: "Burkina Faso",
    bg: "Bulgaria",
    bh: "Bahrain",
    bi: "Burundi",
    bj: "Benin",
    bl: "Saint Barthélemy",
    bm: "Bermuda",
    bn: "Brunei Darussalam",
    bo: "Bolivia, Plurinational State of",
    bq: "Bonaire, Sint Eustatius and Saba",
    br: "Brazil",
    bs: "Bahamas",
    bt: "Bhutan",
    bv: "Bouvet Island",
    bw: "Botswana",
    by: "Belarus",
    bz: "Belize",
    ca: "Canada",
    cc: "Cocos (Keeling) Islands",
    cd: "Congo, Democratic Republic of the",
    cf: "Central African Republic",
    cg: "Congo",
    ch: "Switzerland",
    ci: "Côte d'Ivoire",
    ck: "Cook Islands",
    cl: "Chile",
    cm: "Cameroon",
    cn: "China",
    co: "Colombia",
    cr: "Costa Rica",
    cu: "Cuba",
    cv: "Cabo Verde",
    cw: "Curaçao",
    cx: "Christmas Island",
    cy: "Cyprus",
    cz: "Czechia",
    de: "Germany",
    dj: "Djibouti",
    dk: "Denmark",
    dm: "Dominica",
    do: "Dominican Republic",
    dz: "Algeria",
    ec: "Ecuador",
    ee: "Estonia",
    eg: "Egypt",
    eh: "Western Sahara",
    er: "Eritrea",
    es: "Spain",
    et: "Ethiopia",
    fi: "Finland",
    fj: "Fiji",
    fk: "Falkland Islands (Malvinas)",
    fm: "Micronesia, Federated States of",
    fo: "Faroe Islands",
    fr: "France",
    ga: "Gabon",
    gb: "United Kingdom",
    gd: "Grenada",
    ge: "Georgia",
    gf: "French Guiana",
    gg: "Guernsey",
    gh: "Ghana",
    gi: "Gibraltar",
    gl: "Greenland",
    gm: "Gambia",
    gn: "Guinea",
    gp: "Guadeloupe",
    gq: "Equatorial Guinea",
    gr: "Greece",
    gs: "South Georgia and the South Sandwich Islands",
    gt: "Guatemala",
    gu: "Guam",
    gw: "Guinea-Bissau",
    gy: "Guyana",
    hk: "Hong Kong",
    hm: "Heard Island and McDonald Islands",
    hn: "Honduras",
    hr: "Croatia",
    ht: "Haiti",
    hu: "Hungary",
    id: "Indonesia",
    ie: "Ireland",
    il: "Israel",
    im: "Isle of Man",
    in: "India",
    io: "British Indian Ocean Territory",
    iq: "Iraq",
    ir: "Iran, Islamic Republic of",
    is: "Iceland",
    it: "Italy",
    je: "Jersey",
    jm: "Jamaica",
    jo: "Jordan",
    jp: "Japan",
    ke: "Kenya",
    kg: "Kyrgyzstan",
    kh: "Cambodia",
    ki: "Kiribati",
    km: "Comoros",
    kn: "Saint Kitts and Nevis",
    kp: "Korea, Democratic People's Republic of",
    kr: "Korea, Republic of",
    kw: "Kuwait",
    ky: "Cayman Islands",
    kz: "Kazakhstan",
    la: "Lao People's Democratic Republic",
    lb: "Lebanon",
    lc: "Saint Lucia",
    li: "Liechtenstein",
    lk: "Sri Lanka",
    lr: "Liberia",
    ls: "Lesotho",
    lt: "Lithuania",
    lu: "Luxembourg",
    lv: "Latvia",
    ly: "Libya",
    ma: "Morocco",
    mc: "Monaco",
    md: "Moldova, Republic of",
    me: "Montenegro",
    mf: "Saint Martin, (French part)",
    mg: "Madagascar",
    mh: "Marshall Islands",
    mk: "North Macedonia",
    ml: "Mali",
    mm: "Myanmar",
    mn: "Mongolia",
    mo: "Macao",
    mp: "Northern Mariana Islands",
    mq: "Martinique",
    mr: "Mauritania",
    ms: "Montserrat",
    mt: "Malta",
    mu: "Mauritius",
    mv: "Maldives",
    mw: "Malawi",
    mx: "Mexico",
    my: "Malaysia",
    mz: "Mozambique",
    na: "Namibia",
    nc: "New Caledonia",
    ne: "Niger",
    nf: "Norfolk Island",
    ng: "Nigeria",
    ni: "Nicaragua",
    nl: "Netherlands",
    no: "Norway",
    np: "Nepal",
    nr: "Nauru",
    nu: "Niue",
    nz: "New Zealand",
    om: "Oman",
    pa: "Panama",
    pe: "Peru",
    pf: "French Polynesia",
    pg: "Papua New Guinea",
    ph: "Philippines",
    pk: "Pakistan",
    pl: "Poland",
    pm: "Saint Pierre and Miquelon",
    pn: "Pitcairn",
    pr: "Puerto Rico",
    ps: "Palestine, State of",
    pt: "Portugal",
    pw: "Palau",
    py: "Paraguay",
    qa: "Qatar",
    re: "Réunion",
    ro: "Romania",
    rs: "Serbia",
    ru: "Russian Federation",
    rw: "Rwanda",
    sa: "Saudi Arabia",
    sb: "Solomon Islands",
    sc: "Seychelles",
    sd: "Sudan",
    se: "Sweden",
    sg: "Singapore",
    sh: "Saint Helena, Ascension and Tristan da Cunha",
    si: "Slovenia",
    sj: "Svalbard and Jan Mayen",
    sk: "Slovakia",
    sl: "Sierra Leone",
    sm: "San Marino",
    sn: "Senegal",
    so: "Somalia",
    sr: "Suriname",
    ss: "South Sudan",
    st: "Sao Tome and Principe",
    sv: "El Salvador",
    sx: "Sint Maarten, (Dutch part)",
    sy: "Syrian Arab Republic",
    sz: "Eswatini",
    tc: "Turks and Caicos Islands",
    td: "Chad",
    tf: "French Southern Territories",
    tg: "Togo",
    th: "Thailand",
    tj: "Tajikistan",
    tk: "Tokelau",
    tl: "Timor-Leste",
    tm: "Turkmenistan",
    tn: "Tunisia",
    to: "Tonga",
    tr: "Turkey",
    tt: "Trinidad and Tobago",
    tv: "Tuvalu",
    tw: "Taiwan",
    tz: "Tanzania, United Republic of",
    ua: "Ukraine",
    ug: "Uganda",
    um: "United States Minor Outlying Islands",
    us: "United States",
    uy: "Uruguay",
    uz: "Uzbekistan",
    va: "Holy See",
    vc: "Saint Vincent and the Grenadines",
    ve: "Venezuela, Bolivarian Republic of",
    vg: "Virgin Islands, British",
    vi: "Virgin Islands, U.S.",
    vn: "Viet Nam",
    vu: "Vanuatu",
    wf: "Wallis and Futuna",
    ws: "Samoa",
    xx: "Unknown",
    xk: "Kosovo",
    ye: "Yemen",
    yt: "Mayotte",
    za: "South Africa",
    zm: "Zambia",
    zw: "Zimbabwe",
  },
  $vuetify: {
    badge: "Badge",
    open: "Open",
    close: "Close",
    dismiss: "Dismiss",
    confirmEdit: {
      ok: "OK",
      cancel: "Cancel",
    },
    dataIterator: {
      noResultsText: "No matching records found",
      loadingText: "Loading items...",
    },
    dataTable: {
      itemsPerPageText: "Rows per page:",
      ariaLabel: {
        sortDescending: "Sorted descending.",
        sortAscending: "Sorted ascending.",
        sortNone: "Not sorted.",
        activateNone: "Activate to remove sorting.",
        activateDescending: "Activate to sort descending.",
        activateAscending: "Activate to sort ascending.",
      },
      sortBy: "Sort by",
    },
    dataFooter: {
      itemsPerPageText: "Items per page:",
      itemsPerPageAll: "All",
      nextPage: "Next page",
      prevPage: "Previous page",
      firstPage: "First page",
      lastPage: "Last page",
      pageText: "{0}-{1} of {2}",
    },
    dateRangeInput: {
      divider: "to",
    },
    datePicker: {
      itemsSelected: "{0} selected",
      range: {
        title: "Select dates",
        header: "Enter dates",
      },
      title: "Select date",
      header: "Enter date",
      input: {
        placeholder: "Enter date",
      },
    },
    noDataText: "No data available",
    carousel: {
      prev: "Previous visual",
      next: "Next visual",
      ariaLabel: {
        delimiter: "Carousel slide {0} of {1}",
      },
    },
    calendar: {
      moreEvents: "{0} more",
      today: "Today",
    },
    input: {
      clear: "Clear {0}",
      prependAction: "{0} prepended action",
      appendAction: "{0} appended action",
      otp: "Please enter OTP character {0}",
    },
    fileInput: {
      counter: "{0} files",
      counterSize: "{0} files ({1} in total)",
    },
    timePicker: {
      am: "AM",
      pm: "PM",
      title: "Select Time",
    },
    pagination: {
      ariaLabel: {
        root: "Pagination Navigation",
        next: "Next page",
        previous: "Previous page",
        page: "Go to page {0}",
        currentPage: "Page {0}, Current page",
        first: "First page",
        last: "Last page",
      },
    },
    stepper: {
      next: "Next",
      prev: "Previous",
    },
    rating: {
      ariaLabel: {
        item: "Rating {0} of {1}",
      },
    },
    loading: "Loading...",
    infiniteScroll: {
      loadMore: "Load more",
      empty: "No more",
    },
  },
  columns: {
    projectquery: {
      status: "Status",
      short_description: "Description",
      homepage: "Homepage",
      identifier: "Identifier",
    },
    issuequery: {
      id: "ID",
      project: "Project",
      tracker: "Tracker",
      status: "Status",
      priority: "Priority",
      author: "Author",
      assigned_to: "Assignee",
      category: "Category",
      fixed_version: "Target Version",
      parent: {
        "": "Parent",
        subject: "Parent",
      },
      total_estimated_hours: "Estimated Time",
      spent_hours: "Spent Time",
      total_spent_hours: "Total Spent Time",
      relations: "Relations",
      attachments: "Attachments",
      last_notes: "Last Notes",
    },
  },
  password_char_classes: {
    uppercase: "Uppercase",
    lowercase: "Lowercase",
    digits: "Numbers",
    special_chars: "Special Characters",
  },
  rtu: {
    disconnected: {
      title: "No Connection",
      text: "Please wait while a connection is re-established",
    },
  },
};

module FridayPlugin
  module SettingsControllerPatch
    def self.included(base)
      base.class_eval do
        base.send(:include, FridayHelper)
        base.send(:include, SettingsHelper)
        alias_method :redmine_base_index, :index
        alias_method :redmine_base_edit, :edit
        alias_method :redmine_base_plugin, :plugin

        def index
          if friday_request?
            redmine_base_edit
            project_query = ProjectQuery.new(Setting.project_list_defaults)
            issue_query = IssueQuery.new(column_names: Setting.issue_list_default_columns)
            time_entry_query = TimeEntryQuery.new(Setting.time_entry_list_defaults)
            render json: {
              errors: @setting_errors,
              settings: {
                app_title: {
                  type: "text",
                  props: {},
                  value: Setting.send(:app_title)
                },
                welcome_text: {
                  type: "markdown",
                  props: {},
                  value: Setting.send(:welcome_text)
                },
                per_page_options: {
                  type: "text",
                  props: {},
                  value: Setting.send(:per_page_options)
                },
                search_results_per_page: {
                  type: "text",
                  props: {
                    type: "number",
                    min: 1
                  },
                  value: Setting.send(:search_results_per_page)
                },
                activity_days_default: {
                  type: "text",
                  props: {
                    type: "number",
                    min: 1
                  },
                  value: Setting.send(:activity_days_default)
                },
                host_name: {
                  type: "text",
                  props: {
                    hint: @guessed_host_and_path
                  },
                  value: Setting.send(:host_name)
                },
                protocol: {
                  type: "select",
                  props: {
                    options: [
                      {value: "http", label: "HTTP"},
                      {value: "https", label: "HTTPS"}
                    ]
                  },
                  value: Setting.send(:protocol)
                },
                wiki_compression: {
                  type: "select",
                  props: {
                    options: [
                      {value: "gzip", label: "GZIP"},
                      {value: nil, label: "labels.none"}
                    ]
                  },
                  value: Setting.send(:wiki_compression)
                },
                feeds_limit: {
                  type: "text",
                  props: {
                    type: "number",
                    min: 1
                  },
                  value: Setting.send(:feeds_limit)
                },
                default_language: {
                  type: "select",
                  props: {
                    options: ::I18n.backend.available_locales.map { |locale| {value: locale.to_s, label: "languages.#{locale}"} }.sort_by(&:first)
                  },
                  value: Setting.send(:default_language)
                },
                force_default_language_for_anonymous: {
                  type: "checkbox",
                  props: {
                    trueValue: "1",
                    falseValue: "0"
                  },
                  value: Setting.send(:force_default_language_for_anonymous)
                },
                force_default_language_for_loggedin: {
                  type: "checkbox",
                  props: {
                    trueValue: "1",
                    falseValue: "0"
                  },
                  value: Setting.send(:force_default_language_for_loggedin)
                },
                user_format: {
                  type: "select",
                  props: {
                    options: @options[:user_format].map { |format| {value: format[1], label: format[0]} }
                  },
                  value: Setting.send(:user_format)
                },
                gravatar_enabled: {
                  type: "checkbox",
                  props: {
                    trueValue: "1",
                    falseValue: "0",
                    hint: t(:text_avatar_server_config_html, url: Redmine::Configuration["avatar_server_url"])
                  },
                  value: Setting.send(:gravatar_enabled)
                },
                gravatar_default: {
                  type: "select",
                  props: {
                    options: gravatar_default_setting_options.map { |option| {value: option[1], label: option[0]} } << {value: nil, label: "labels.none"}
                  },
                  value: Setting.send(:gravatar_default)
                },
                login_required: {
                  type: "select",
                  props: {
                    options: [
                      {value: "1", label: "labels.yes"},
                      {value: "0", label: "labels.no"}
                    ]
                  },
                  value: Setting.send(:login_required)
                },
                self_registration: {
                  type: "select",
                  props: {
                    options: [
                      {value: "0", label: l(:label_disabled)},
                      {value: "1", label: l(:label_registration_activation_by_email)},
                      {value: "2", label: l(:label_registration_manual_activation)},
                      {value: "3", label: l(:label_registration_automatic_activation)}
                    ]
                  },
                  value: Setting.send(:self_registration)
                },
                show_custom_fields_on_registration: {
                  type: "checkbox",
                  props: {
                    trueValue: "1",
                    falseValue: "0",
                    disabled: !Setting.self_registration?
                  },
                  value: Setting.send(:show_custom_fields_on_registration)
                },
                password_min_length: {
                  type: "text",
                  props: {
                    type: "number",
                    min: 1
                  },
                  value: Setting.send(:password_min_length)
                },
                password_required_char_classes: {
                  type: "select",
                  props: {
                    multiple: true,
                    options: Setting::PASSWORD_CHAR_CLASSES.keys.collect { |c| {value: c, label: "password_char_classes.#{c}"} }
                  },
                  value: Setting.send(:password_required_char_classes)
                },
                password_max_age: {
                  type: "select",
                  props: {
                    options: [
                      {value: "0", label: "labels.none"}
                    ] + [7, 30, 60, 90, 180, 365].collect { |days| {value: days.to_s, label: l("datetime.distance_in_words.x_days", count: days)} }
                  },
                  value: Setting.send(:password_max_age)
                },
                lost_password: {
                  type: "checkbox",
                  props: {
                    trueValue: "1",
                    falseValue: "0"
                  },
                  value: Setting.send(:lost_password)
                },
                twofa: {
                  type: "select",
                  props: {
                    options: [
                      {value: "0", label: l(:label_disabled)},
                      {value: "1", label: l(:label_optional)},
                      {value: "3", label: l(:label_required_administrators)},
                      {value: "2", label: l(:label_required_lower)}
                    ]
                  },
                  value: Setting.send(:twofa)
                },
                session_lifetime: {
                  type: "select",
                  props: {
                    options: session_lifetime_options.map { |option| {value: option[1], label: option[0]} }
                  },
                  value: Setting.send(:session_lifetime)
                },
                session_timeout: {
                  type: "select",
                  props: {
                    options: session_timeout_options.map { |option| {value: option[1], label: option[0]} }
                  },
                  value: Setting.send(:session_timeout)
                },
                rest_api_enabled: {
                  type: "checkbox",
                  props: {
                    trueValue: "1",
                    falseValue: "0"
                  },
                  value: Setting.send(:rest_api_enabled)
                },
                jsonp_enabled: {
                  type: "checkbox",
                  props: {
                    trueValue: "1",
                    falseValue: "0"
                  },
                  value: Setting.send(:jsonp_enabled)
                },
                default_projects_public: {
                  type: "checkbox",
                  props: {
                    trueValue: "1",
                    falseValue: "0"
                  },
                  value: Setting.send(:default_projects_public)
                },
                default_projects_modules: {
                  type: "select",
                  props: {
                    multiple: true,
                    options: Redmine::AccessControl.available_project_modules.collect { |m| {value: m.to_s, label: l_or_humanize(m, prefix: "project_module_")} }
                  },
                  value: Setting.send(:default_projects_modules)
                },
                default_projects_tracker_ids: {
                  type: "select",
                  props: {
                    multiple: true,
                    options: Tracker.sorted.collect { |t| {value: t.id.to_s, label: t.name} }
                  },
                  value: Setting.send(:default_projects_tracker_ids)
                },
                sequential_project_identifiers: {
                  type: "checkbox",
                  props: {
                    trueValue: "1",
                    falseValue: "0"
                  },
                  value: Setting.send(:sequential_project_identifiers)
                },
                new_project_user_role_id: {
                  type: "select",
                  props: {
                    options: Role.find_all_givable.collect { |r| {value: r.id.to_s, label: r.name} }
                  },
                  value: Setting.send(:new_project_user_role_id)
                },
                "project_list_defaults.column_names": {
                  type: "querycolumnselection",
                  props: {
                    formKey: "project_list_defaults.column_names",
                    options: project_query.available_inline_columns.collect { |c| {value: c.name, label: c.caption} }
                  },
                  value: project_query.inline_columns.collect(&:name)
                },
                default_project_query: {
                  type: "select",
                  props: {
                    options: default_global_project_query_options.collect { |option| {value: option[1], label: option[0]} }
                  },
                  value: Setting.send(:default_project_query)
                },
                max_additional_emails: {
                  type: "text",
                  props: {
                    type: "number",
                    min: 0
                  },
                  value: Setting.send(:max_additional_emails)
                },
                email_domains_allowed: {
                  type: "csv",
                  props: {},
                  value: Setting.send(:email_domains_allowed)
                },
                email_domains_denied: {
                  type: "csv",
                  props: {},
                  value: Setting.send(:email_domains_denied)
                },
                unsubscribe: {
                  type: "checkbox",
                  props: {
                    trueValue: "1",
                    falseValue: "0"
                  },
                  value: Setting.send(:unsubscribe)
                },
                default_users_hide_mail: {
                  type: "checkbox",
                  props: {
                    trueValue: "1",
                    falseValue: "0"
                  },
                  value: Setting.send(:default_users_hide_mail)
                },
                default_notification_option: {
                  type: "select",
                  props: {
                    options: User.valid_notification_options.collect { |o| {value: o.first.to_s, label: l(o.last)} }
                  },
                  value: Setting.send(:default_notification_option)
                },
                default_users_no_self_notified: {
                  type: "checkbox",
                  props: {
                    trueValue: "1",
                    falseValue: "0"
                  },
                  value: Setting.send(:default_users_no_self_notified)
                },
                default_users_time_zone: {
                  type: "select",
                  props: {
                    options: ActiveSupport::TimeZone.all.collect { |tz| {value: tz.name, label: tz.to_s} } << {value: nil, label: l(:label_none)}
                  },
                  value: Setting.send(:default_users_time_zone)
                },
                cross_project_issue_relations: {
                  type: "checkbox",
                  props: {
                    trueValue: "1",
                    falseValue: "0"
                  },
                  value: Setting.send(:cross_project_issue_relations)
                },
                link_copied_issue: {
                  type: "select",
                  props: {
                    options: link_copied_issue_options.map { |option| {value: option[1], label: option[0]} }
                  },
                  value: Setting.send(:link_copied_issue)
                },
                cross_project_subtasks: {
                  type: "select",
                  props: {
                    options: cross_project_subtasks_options.map { |option| {value: option[1], label: option[0]} }
                  },
                  value: Setting.send(:cross_project_subtasks)
                },
                close_duplicate_issues: {
                  type: "checkbox",
                  props: {
                    trueValue: "1",
                    falseValue: "0"
                  },
                  value: Setting.send(:close_duplicate_issues)
                },
                issue_group_assignment: {
                  type: "checkbox",
                  props: {
                    trueValue: "1",
                    falseValue: "0"
                  },
                  value: Setting.send(:issue_group_assignment)
                },
                default_issue_start_date_to_creation_date: {
                  type: "checkbox",
                  props: {
                    trueValue: "1",
                    falseValue: "0"
                  },
                  value: Setting.send(:default_issue_start_date_to_creation_date)
                },
                display_subprojects_issues: {
                  type: "checkbox",
                  props: {
                    trueValue: "1",
                    falseValue: "0"
                  },
                  value: Setting.send(:display_subprojects_issues)
                },
                issue_done_ratio: {
                  type: "select",
                  props: {
                    options: Issue::DONE_RATIO_OPTIONS.collect { |i| {value: i, label: l("setting_issue_done_ratio_#{i}")} }
                  },
                  value: Setting.send(:issue_done_ratio)
                },
                non_working_week_days: {
                  type: "select",
                  props: {
                    multiple: true,
                    options: (1..7).map { |d| {value: d.to_s, label: day_name(d)} }
                  },
                  value: Setting.send(:non_working_week_days)
                },
                issues_export_limit: {
                  type: "text",
                  props: {
                    type: "number",
                    min: 1
                  },
                  value: Setting.send(:issues_export_limit)
                },
                gantt_items_limit: {
                  type: "text",
                  props: {
                    type: "number",
                    min: 1
                  },
                  value: Setting.send(:gantt_items_limit)
                },
                gantt_months_limit: {
                  type: "text",
                  props: {
                    type: "number",
                    min: 1
                  },
                  value: Setting.send(:gantt_months_limit)
                },
                parent_issue_dates: {
                  type: "select",
                  props: {
                    options: parent_issue_dates_options.map { |option| {value: option[1], label: option[0]} }
                  },
                  value: Setting.send(:parent_issue_dates)
                },
                parent_issue_done_ratio: {
                  type: "select",
                  props: {
                    options: parent_issue_done_ratio_options.map { |option| {value: option[1], label: option[0]} }
                  },
                  value: Setting.send(:parent_issue_done_ratio)
                },
                issue_list_default_columns: {
                  type: "querycolumnselection",
                  props: {
                    options: issue_query.available_inline_columns.collect { |c| {value: c.name, label: c.caption} }
                  },
                  value: issue_query.inline_columns.collect(&:name)
                },
                issue_list_default_totals: {
                  type: "select",
                  props: {
                    multiple: true,
                    options: IssueQuery.new(totalable_names: Setting.issue_list_default_totals).available_totalable_columns.map { |c| {value: c.name.to_s, label: c.caption} }
                  },
                  value: Setting.send(:issue_list_default_totals)
                },
                default_issue_query: {
                  type: "select",
                  props: {
                    options: default_global_issue_query_options.collect { |option| {value: option[1], label: option[0]} }
                  },
                  value: Setting.send(:default_issue_query)
                },
                timelog_required_fields: {
                  type: "select",
                  props: {
                    multiple: true,
                    options: [
                      {value: "issue_id", label: l(:field_issue)},
                      {value: "comments", label: l(:field_comments)}
                    ]
                  },
                  value: Setting.send(:timelog_required_fields)
                },
                timelog_max_hours_per_day: {
                  type: "text",
                  props: {
                    type: "number",
                    min: 0
                  },
                  value: Setting.send(:timelog_max_hours_per_day)
                },
                timelog_accept_0_hours: {
                  type: "checkbox",
                  props: {
                    trueValue: "1",
                    falseValue: "0"
                  },
                  value: Setting.send(:timelog_accept_0_hours)
                },
                timelog_accept_future_dates: {
                  type: "checkbox",
                  props: {
                    trueValue: "1",
                    falseValue: "0"
                  },
                  value: Setting.send(:timelog_accept_future_dates)
                },
                "time_entry_list_defaults.column_names": {
                  type: "querycolumnselection",
                  props: {
                    formKey: "time_entry_list_defaults.column_names",
                    options: time_entry_query.available_inline_columns.collect { |c| {value: c.name, label: c.caption} }
                  },
                  value: time_entry_query.inline_columns.collect(&:name)
                },
                "time_entry_list_defaults.totalable_names": {
                  type: "select",
                  props: {
                    multiple: true,
                    options: time_entry_query.available_totalable_columns.map { |c| {value: c.name.to_s, label: c.caption} }
                  },
                  value: time_entry_query.totalable_columns.collect(&:name)
                }
              }
            }
          else
            redmine_base_index
          end
        end

        def edit
          if friday_request?
            index
          else
            redmine_base_edit
          end
        end

        def plugin
          if friday_request?
            plugin = Redmine::Plugin.find(params[:id])
            unless plugin.configurable?
              render_404
              nil
            end
            if request.post?
              setting = params[:settings] ? params[:settings].permit!.to_h : {}
              Setting.send :"plugin_#{plugin.id}=", setting
            end
            settings = Setting.send :"plugin_#{plugin.id}"
            render json: {plugin: plugin, settings: settings}
          else
            redmine_base_plugin
          end
        end
      end
    end
  end
end

SettingsController.send(:include, FridayPlugin::SettingsControllerPatch) unless SettingsController.included_modules.include?(FridayPlugin::SettingsControllerPatch)

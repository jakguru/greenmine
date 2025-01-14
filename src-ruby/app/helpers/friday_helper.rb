module FridayHelper
  include QueriesHelper
  include Rails.application.routes.url_helpers

  # This method is used to determine if the request is a Friday Request by checking
  # for the presence of the 'X-Requested-For' header and that is has the value 'Friday'
  def friday_request?
    request.headers["X-Requested-For"] == "Friday"
  end

  # This method is called to generate the standardized response for Query models
  # including IssueQuery, ProjectQuery, TimeEntryQuery, and UserQuery
  # The responses are designed to be used by the QueriesList component,
  # but may also be used by other components
  def query_response(query, scope, klass, project, user, params = {}, per_page_option = 25)
    payload = {
      items: [],
      items_length: 0,
      items_per_page: 0,
      page: 1,
      pages: 0,
      totals: query.totals.map { |total_entry| make_column_total_hash(total_entry[0], total_entry[1], params) }.compact
    }
    query_data = {
      valid: query.valid?,
      new_record: query.new_record?,
      id: query.id,
      name: query.name,
      type: query.type,
      columns: {
        current: {
          inline: query.inline_columns.map { |column| make_column_hash(column, params) }.compact,
          block: query.block_columns.map { |column| make_column_hash(column, params) }.compact,
          totalable: query.totalable_columns.map { |column| make_column_hash(column, params) }.compact,
          groupable: query.group_by.nil? ? [] : [make_column_hash_by_name(query.group_by, query.groupable_columns, params)].compact,
          sort: query.sort_criteria.map { |sort_entry| make_column_sort_hash(sort_entry[0], sort_entry[1], query.columns, params) }.compact
        },
        available: {
          all: query.columns.map { |column| make_column_hash(column, params) }.compact,
          inline: query.available_inline_columns.map { |column| make_column_hash(column, params) }.compact,
          block: query.available_block_columns.map { |column| make_column_hash(column, params) }.compact,
          totalable: query.available_totalable_columns.map { |column| make_column_hash(column, params) }.compact,
          groupable: query.groupable_columns.map { |column| make_column_hash(column, params) }.compact,
          sortable: query.available_columns.select(&:sortable?).map { |column| make_column_hash(column, params) }.compact
        }
      },
      filters: {
        current: query.filters.nil? ? {} : query.filters,
        available: query.available_filters
      },
      display: {
        current: query.options.include?(:display_type) ? query.options[:display_type].to_s : "list",
        available: query.available_display_types.reject { |type| type == "gantt" }
      },
      options: query.options,
      project: query.project_id.nil? ? nil : Project.find(query.project_id)
    }
    permissions = {
      create: query.new_record? && user.allowed_to?(:save_queries, nil, global: true),
      edit: query.editable_by?(user)
    }
    order_option = if query.respond_to?(:order_option)
      query.order_option
    else
      [query.group_by_sort_order, query.options[:order] || query.sort_clause].flatten.reject(&:blank?)
    end
    if query.valid?
      payload[:items_length] = scope.count
      payload[:items_per_page] = per_page_option
      payload[:page] = params[:page].nil? ? 1 : params[:page].to_i
      payload[:pages] = Redmine::Pagination::Paginator.new payload[:items_length], payload[:items_per_page], params[:page]
      raw = case @query.display_type
      when "list"
        scope
          .offset(payload[:pages].offset)
          .limit(payload[:items_per_page])
          .order(order_option)
          .joins(query.joins_for_order_statement(order_option.join(",")))
          .to_a
      when "gantt"
        scope
          .joins(query.joins_for_order_statement(order_option.join(",")))
          .to_a
      else
        scope.to_a
      end
      case @query.display_type
      when "gantt"
        series_by_group = {}
        grouped_friday_list(raw, query) do |entry, level, group_name, group_count, group_totals|
          group_name_as_symbol = group_name.nil? ? :gantt : group_name.to_sym
          series_by_group[group_name_as_symbol] ||= {
            name: group_name.nil? ? l(:label_gantt) : group_name.to_sym,
            custom: {
              count: group_count,
              totals: group_totals
            },
            data: [],
            type: "gantt"
          }
          series_by_group[group_name_as_symbol][:data] << make_entry_gantt_hash(entry, user)
        end
        payload[:page] = 1
        payload[:pages] = 1
        payload[:items_per_page] = payload[:items_length]
        payload[:items] = series_by_group.values
      else
        grouped_friday_list(raw, query) do |entry, level, group_name, group_count, group_totals|
          payload[:items] << {
            id: entry.id,
            entry: make_entry_hash(entry, query_data[:columns][:current], user),
            level: level,
            group_name: group_name,
            group_count: group_count,
            group_totals: group_totals
          }
        end
      end
    end

    {
      params: params,
      payload: payload,
      query: query_data,
      queries: sidebar_queries(klass, project),
      permissions: permissions,
      creatable: make_creatable_list(klass, project, user)
    }
  end

  # This method is used to render the standardized response for Query models as JSON
  # for consumption by the Friday API Client
  def render_query_response(query, scope, klass, project, user, params = {}, per_page_option = 25)
    render json: query_response(query, scope, klass, project, user, params, per_page_option)
  end

  def render_blank
    render template: "blank"
  end

  def get_project_nested_items(projects)
    result = []
    if projects.any?
      ancestors = []
      projects.sort_by(&:lft).each do |project|
        # Remove ancestors that are no longer part of the current project's hierarchy
        while ancestors.any? && !project.is_descendant_of?(ancestors.last)
          ancestors.pop
        end

        # Create label with '>' symbols to indicate depth level
        depth_indicator = ">" * ancestors.size
        label = "#{depth_indicator} #{project.name}".strip

        # Add the project to the result array as a hash with value and label
        result << {value: project.id, label: label}

        # Add the current project to ancestors stack
        ancestors << project
      end
    end
    result
  end

  def render_project_response(additional = {})
    custom_field_values = {}
    @project.visible_custom_field_values.each do |cfv|
      id = cfv.custom_field.id
      custom_field_values[id] = cfv.value
    end
    users = User.all.map { |user|
      {
        value: user.id,
        label: user.name,
        kind: "user"
      }
    }
    groups = Group.all.map { |group|
      {
        value: group.id,
        label: group.name,
        kind: "group"
      }
    }
    assignees = get_project_default_assigned_to_options(@project)
    versions = get_project_default_version_options(@project)
    eumerations = {}
    @project.activities(true).each do |activity|
      eumerations[activity.id] = {
        custom_field_values: {},
        active: activity.active
      }
      activity.custom_field_values.each do |cfv|
        eumerations[activity.id][:custom_field_values][cfv.custom_field.id] = cfv.value
      end
    end
    menu_name = @project.new_record? ? nil : :project_menu
    menu_nodes = []
    if menu_name.present? && Redmine::MenuManager.items(menu_name).children.present?
      menu_items_for(menu_name, @project) do |node|
        menu_nodes << {
          key: node.name,
          title: node.caption(@project),
          to: node.url.nil? ? nil : get_vue_router_route_for_url(node.url, @project),
          children: if node.children.present? || !node.child_menus.nil?
                      node.children.map { |child|
                        {
                          key: child.name,
                          title: child.caption(@project),
                          to: child.url.nil? ? nil : get_vue_router_route_for_url(child.url, @project)
                        }
                      }
                    end
        }
      end
    end
    wiki = @project.wiki
    wiki_pages = []
    if wiki.present?
      wiki_pages = wiki.pages.with_updated_on.includes(wiki: :project).includes(:parent).to_a.map { |page|
        {
          id: page.id,
          title: page.title,
          url: project_wiki_page_path(page.wiki.project, page.title, parent: page.parent_id),
          parent: page.parent_id
        }
      }
    end
    parents = []
    project = @project
    while project.parent
      parents << project.parent
      project = project.parent
    end
    render json: {
      formAuthenticityToken: form_authenticity_token,
      id: @project.new_record? ? nil : @project.id,
      model: @project.attributes.merge({
        custom_field_values: custom_field_values,
        enabled_module_names: @project.enabled_module_names.reject { |name| name == "repository" || name == "boards" },
        tracker_ids: @project.trackers.map(&:id),
        issue_custom_field_ids: @project.all_issue_custom_fields.ids,
        gitlab_projects: @project.gitlab_projects,
        github_repositories: @project.github_repositories,
        gitlab_project_ids: @project.gitlab_projects.map(&:id),
        github_repository_ids: @project.github_repositories.map(&:id),
        eumerations: eumerations,
        description: @project.description.nil? ? "" : @project.description,
        memberships: @project.memberships.preload(:member_roles, :roles).collect { |membership|
          {
            principal: membership.principal[:id],
            roles: membership.roles.sort.collect(&:id)
          }
        },
        issue_categories: @project.issue_categories.sort_by(&:id).map { |category|
          {
            name: category.name,
            assigned_to_id: category.assigned_to_id
          }
        },
        activities: @project.activities(true).select { |activity| activity.active }.map(&:id)
      }),
      members: @project.members.map { |member|
        {
          id: member.id,
          roles: member.roles.map(&:id)
        }
      },
      issueCategories: @project.issue_categories,
      versions: versions,
      repositories: @project.repositories,
      customFields: @project.visible_custom_field_values.map(&:custom_field).map { |cf|
        case cf.field_format
        when "user"
          cf.attributes.merge({
            enumerations: get_enumerations_for_project_custom_user_field(cf)
          })
        when "version"
          cf.attributes.merge({
            enumerations: get_enumerations_for_project_custom_versions_field(cf)
          })
        else
          cf.attributes.merge({
            enumerations: cf.enumerations.collect { |v| {id: v.id, name: v.name, is_default: nil, position: v.position, active: v.active} }
          })
        end
      },
      values: {
        identifierMaxLength: Project::IDENTIFIER_MAX_LENGTH,
        members: users + groups,
        modules: Redmine::AccessControl.available_project_modules.map { |module_name|
          {
            value: module_name,
            label: l_or_humanize(module_name, prefix: "project_module_")
          }
        },
        trackers: Tracker.sorted.preload(:default_status).map { |tracker|
          {
            id: tracker.id,
            name: tracker.name
          }
        },
        activities: @project.activities(true).map { |activity|
          {
            id: activity.id,
            name: activity.name,
            is_system: !activity.project
          }
        },
        versions: versions.map { |version|
          {
            value: version.id,
            label: version.name
          }
        },
        assignees: assignees,
        queries: get_project_default_issue_query_options(@project),
        gitlabProjects: GitlabProject.preload(:gitlab_instance).map { |gitlab_project|
          {
            id: gitlab_project.id,
            name: gitlab_project.name,
            web_url: gitlab_project.web_url,
            gitlab: gitlab_project.gitlab_instance.name
          }
        },
        githubRepositories: GithubRepository.preload(:github_instance).map { |github_repository|
          {
            id: github_repository.id,
            name: github_repository.name,
            web_url: github_repository.web_url,
            github: github_repository.github_instance.name
          }
        },
        parents: @project.allowed_parents.compact.map { |project|
          {
            value: project.id,
            label: project.name
          }
        },
        issueCustomFields: IssueCustomField.sorted.to_a,
        statuses: [
          {value: Project::STATUS_ACTIVE, color: "success", icon: "mdi-folder-play", label: l(:label_status_active)},
          {value: Project::STATUS_CLOSED, color: "info", icon: "mdi-folder", label: l(:label_status_closed)},
          {value: Project::STATUS_ARCHIVED, color: "warning", icon: "mdi-folder-lock", label: l(:label_status_archived)},
          {value: Project::STATUS_SCHEDULED_FOR_DELETION, color: "error", icon: "mdi-folder-remove", label: l(:label_status_scheduled_for_deletion), disabled: true}
        ],
        roles: Role.givable.map { |role|
          {
            value: role.id,
            label: role.name,
            assignable: role.assignable,
            external: role.is_external
          }
        }
      },
      permissions: {
        add_project: User.current.allowed_to?(:add_project, @project),
        edit_project: User.current.allowed_to?(:edit_project, @project),
        close_project: User.current.allowed_to?(:close_project, @project),
        delete_project: User.current.allowed_to?(:delete_project, @project),
        select_project_publicity: User.current.allowed_to?(:select_project_publicity, @project),
        select_project_modules: User.current.allowed_to?(:select_project_modules, @project),
        manage_members: User.current.allowed_to?(:manage_members, @project),
        manage_versions: User.current.allowed_to?(:manage_versions, @project),
        add_subprojects: User.current.allowed_to?(:add_subprojects, @project),
        manage_public_queries: User.current.allowed_to?(:manage_public_queries, @project),
        save_queries: User.current.allowed_to?(:save_queries, @project),
        view_associated_gitlab_projects: User.current.allowed_to?(:view_associated_gitlab_projects, @project),
        manage_associated_gitlab_projects: User.current.allowed_to?(:manage_associated_gitlab_projects, @project),
        view_associated_github_repositories: User.current.allowed_to?(:view_associated_github_repositories, @project),
        manage_associated_github_repositories: User.current.allowed_to?(:manage_associated_github_repositories, @project),
        view_time_entries: User.current.allowed_to?(:view_time_entries, @project),
        view_issues: User.current.allowed_to?(:view_issues, @project),
        view_files: User.current.allowed_to?(:view_files, @project),
        manage_files: User.current.allowed_to?(:manage_files, @project),
        view_documents: User.current.allowed_to?(:view_documents, @project),
        add_documents: User.current.allowed_to?(:add_documents, @project),
        get_chart_for_issues_by_status: User.current.allowed_to?(:get_chart_for_issues_by_status, @project),
        get_chart_for_issues_by_tracker: User.current.allowed_to?(:get_chart_for_issues_by_tracker, @project),
        get_chart_for_activity_summary: User.current.allowed_to?(:get_chart_for_activity_summary, @project),
        get_chart_for_time_summary: User.current.allowed_to?(:get_chart_for_time_summary, @project),
        view_associated_monday_board: User.current.allowed_to?(:view_associated_monday_board, @project)
      },
      menu: menu_nodes,
      wiki: wiki_pages,
      documents: @project.documents.to_a.map { |document|
        {
          id: document.id,
          title: document.title,
          description: document.description,
          category: document.category&.name,
          attachment: document.attachments.first&.attributes
        }
      },
      files: @project.attachments.to_a,
      mondayBoard: @project.monday_board,
      parents: parents.reverse
    }.merge(additional)
  end

  def get_project_default_version_options(project)
    versions = project.shared_versions.open.to_a
    if project.default_version && !versions.include?(project.default_version)
      versions << project.default_version
    end
    versions
  end

  def get_project_default_assigned_to_options(project)
    results = (project.assignable_users.to_a + [project.default_assigned_to]).uniq.compact
    results.map { |user|
      {
        value: user.id,
        label: user.name
      }
    }
  end

  def get_project_default_issue_query_options(project)
    public_queries = IssueQuery.only_public
    options = []
    public_queries.where(project_id: nil).pluck(:name, :id).each do |name, id|
      options << {value: id, label: name}
    end
    public_queries.where(project: project).pluck(:name, :id).each do |name, id|
      options << {value: id, label: name}
    end
    options
  end

  def get_enumerations_for_project_custom_user_field(custom_field)
    enumerations = @project.members
    if custom_field[:format_store][:user_role].present?
      enumerations = enumerations.select { |member| member.roles.any? { |role| role.id == custom_field[:format_store][:user_role].to_i } }
    end
    enumerations.map { |member|
      {
        id: member.id,
        name: member.name,
        is_default: false,
        position: 1,
        active: true
      }
    }
  end

  def get_enumerations_for_project_custom_versions_field(custom_field)
    enumerations = @project.shared_versions
    if custom_field[:format_store][:version_status].present?
      enumerations = enumerations.select { |version| version.status == custom_field[:format_store][:version_status] }
    end
    enumerations.map { |version|
      {
        id: version.id,
        name: version.name,
        is_default: false,
        position: 1,
        active: true
      }
    }
  end

  def menu_items_for(menu, project = nil)
    items = []
    Redmine::MenuManager.items(menu).root.children.each do |node|
      if node.allowed?(User.current, project)
        if block_given?
          yield node
        else
          items << node
        end
      end
    end
    block_given? ? nil : items
  end

  def use_absolute_controller(url)
    if url.is_a?(Hash) && url[:controller].present? && !url[:controller].start_with?("/")
      url[:controller] = "/#{url[:controller]}"
    end
    url
  end

  def get_vue_router_route_for_url(url, project)
    case url[:controller]
    when "projects"
      case url[:action]
      when "settings"
        {name: "projects-id-settings", params: {id: project.identifier}}
      else
        {name: "projects-id", params: {id: project.identifier}}
      end
    when "gantt"
      {name: "projects-project-id-issues-gantt", params: {project_id: project.identifier}}
    when "calendar"
      {name: "projects-project-id-issues-calendar", params: {project_id: project.identifier}}
    else
      case url[:action]
      when "new"
        {name: "projects-project-id-#{url[:controller]}-new", params: {project_id: project.identifier}}
      else
        {name: "projects-project-id-#{url[:controller]}", params: {project_id: project.identifier}}
      end
    end
  end

  private

  def make_creatable_list(klass, project, user)
    ret = []

    if klass == ProjectQuery
      # Add project or subproject links
      if project.nil?
        if user.allowed_to?(:add_project, nil, global: true) || user.admin?
          ret << {
            title: l(:label_project_new),
            url: new_project_path
          }
        end
      elsif user.allowed_to?(:add_subproject, project) || user.admin?
        ret << {
          title: l(:label_subproject_new),
          url: new_project_path(parent_id: project)
        }
      end

      # Add issue links (global or project scope)
      if project.nil?
        if user.allowed_to?(:add_issues, nil, global: true) || user.admin?
          ret << {
            title: l(:label_issue_new),
            url: new_issue_path
          }
        end
      elsif user.allowed_to?(:add_issues, project) || user.admin?
        ret << {
          title: l(:label_issue_new),
          url: new_project_issue_path(project)
        }
      end

      # Add time entry links (global or project scope)
      if project.nil?
        if user.allowed_to?(:log_time, nil, global: true) || user.allowed_to?(:log_time_for_other_users, nil, global: true) || user.admin?
          ret << {
            title: l(:button_log_time),
            url: new_time_entry_path
          }
        end
      elsif user.allowed_to?(:log_time, project) || user.allowed_to?(:log_time_for_other_users, project) || user.admin?
        ret << {
          title: l(:button_log_time),
          url: new_project_time_entry_path(project)
        }
      end
    elsif klass == IssueQuery
      # Add issue links (global or project scope)
      if project.nil?
        if user.allowed_to?(:add_issues, nil, global: true) || user.admin?
          ret << {
            title: l(:label_issue_new),
            url: new_issue_path
          }
        end
      elsif user.allowed_to?(:add_issues, project) || user.admin?
        ret << {
          title: l(:label_issue_new),
          url: new_project_issue_path(project)
        }
      end

      # Add time entry links (global or project scope)
      if project.nil?
        if user.allowed_to?(:log_time, nil, global: true) || user.allowed_to?(:log_time_for_other_users, nil, global: true) || user.admin?
          ret << {
            title: l(:button_log_time),
            url: new_time_entry_path
          }
        end
      elsif user.allowed_to?(:log_time, project) || user.allowed_to?(:log_time_for_other_users, project) || user.admin?
        ret << {
          title: l(:button_log_time),
          url: new_project_time_entry_path(project)
        }
      end
    elsif klass == TimeEntryQuery
      # Add time entry links (global or project scope)
      if project.nil?
        if user.allowed_to?(:log_time, nil, global: true) || user.allowed_to?(:log_time_for_other_users, nil, global: true) || user.admin?
          ret << {
            title: l(:button_log_time),
            url: new_time_entry_path
          }
        end
      elsif user.allowed_to?(:log_time, project) || user.allowed_to?(:log_time_for_other_users, project) || user.admin?
        ret << {
          title: l(:button_log_time),
          url: new_project_time_entry_path(project)
        }
      end
    elsif klass == SprintsQuery
      if user.allowed_to?(:manage_sprints, nil, global: true) || user.admin?
        ret << {
          title: l(:label_sprint_new),
          url: new_sprint_path
        }
      end
      if user.allowed_to?(:add_project, nil, global: true) || user.admin?
        ret << {
          title: l(:label_project_new),
          url: new_project_path
        }
      end
      if user.allowed_to?(:add_issues, nil, global: true) || user.admin?
        ret << {
          title: l(:label_issue_new),
          url: new_issue_path
        }
      end
      if user.allowed_to?(:log_time, nil, global: true) || user.allowed_to?(:log_time_for_other_users, nil, global: true) || user.admin?
        ret << {
          title: l(:button_log_time),
          url: new_time_entry_path
        }
      end
    elsif klass == CustomFieldQuery
      if user.admin
        ret << {
          title: l(:label_custom_field_new),
          url: new_custom_field_path({tab: ""})
        }
        ret << {
          title: l(:cf_type_document_category_custom_field_new),
          url: new_custom_field_path({type: DocumentCategoryCustomField})
        }
        ret << {
          title: l(:cf_type_document_custom_field_new),
          url: new_custom_field_path({type: DocumentCustomField})
        }
        ret << {
          title: l(:cf_type_group_custom_field_new),
          url: new_custom_field_path({type: GroupCustomField})
        }
        ret << {
          title: l(:cf_type_issue_custom_field_new),
          url: new_custom_field_path({type: IssueCustomField})
        }
        ret << {
          title: l(:cf_type_issue_priority_custom_field_new),
          url: new_custom_field_path({type: IssuePriorityCustomField})
        }
        ret << {
          title: l(:cf_type_issue_impact_custom_field_new),
          url: new_custom_field_path({type: IssueImpactCustomField})
        }
        ret << {
          title: l(:cf_type_project_custom_field_new),
          url: new_custom_field_path({type: ProjectCustomField})
        }
        ret << {
          title: l(:cf_type_time_entry_activity_custom_field_new),
          url: new_custom_field_path({type: TimeEntryActivityCustomField})
        }
        ret << {
          title: l(:cf_type_time_entry_custom_field_new),
          url: new_custom_field_path({type: TimeEntryCustomField})
        }
        ret << {
          title: l(:cf_type_user_custom_field_new),
          url: new_custom_field_path({type: UserCustomField})
        }
        ret << {
          title: l(:cf_type_version_custom_field_new),
          url: new_custom_field_path({type: VersionCustomField})
        }
      end
    elsif klass == RoleQuery
      if user.admin
        ret << {
          title: l(:label_role_new),
          url: new_role_path
        }
      end
    elsif klass == GroupQuery
      if user.admin
        ret << {
          title: l(:label_group_new),
          url: new_group_path
        }
      end
    elsif klass == UserQuery
      if user.admin
        ret << {
          title: l(:label_user_new),
          url: new_user_path
        }
      end
    elsif klass == GitlabsQuery
      if user.admin
        ret << {
          title: l(:label_gitlab_new),
          url: new_admin_integrations_gitlab_path
        }
      end
    elsif klass == GithubsQuery
      if user.admin
        ret << {
          title: l(:label_github_new),
          url: new_admin_integrations_github_path
        }
      end
    elsif klass == MondaysQuery
      if user.admin
        ret << {
          title: l(:label_monday_new),
          url: new_admin_integrations_monday_path
        }
      end
    end
    ret
  end

  # Make a standardized hash of the column for the response
  def make_column_hash(column, params)
    if column.nil?
      return nil
    end
    {
      key: column.name,
      value: make_column_value(column.name, params[:controller]),
      title: column.caption,
      nowrap: true,
      sortable: column.sortable?,
      meta: {
        default_order: column.default_order,
        frozen: column.frozen?,
        groupable: column.groupable?,
        inline: column.inline?,
        sort_key: column.sortable,
        totalable: column.totalable.present? ? column.totalable : false
      }
    }
  end

  # Make a standardized hash of the column for the response, with sort direction
  def make_column_sort_hash(column, direction, all, params)
    base_hash = make_column_hash_by_name(column, all, params)
    if !base_hash.nil?
      base_hash[:sort] = direction
    end
    base_hash
  end

  # Make a standardized hash of the column for the response, with sort direction
  def make_column_total_hash(column, total, params)
    base_hash = make_column_hash(column, params)
    base_hash[:total] = total
    base_hash
  end

  # Make a standardized hash of the column for the response, knowing only the name of the column
  # and the list of all columns
  def make_column_hash_by_name(name, all, params)
    column = get_column_by_name(name, all)
    if column.nil?
      Rails.logger.warn("Unable to make column hash by name: column with name '#{name}' not found.")
    end
    make_column_hash(column, params)
  end

  # Get a column by name from a list of columns
  def get_column_by_name(col_name, all)
    all.find { |column| column.name.to_s == col_name || column.name.to_s + "_id" == col_name }
  end

  # This method is used to group the results of a query by the group_by column
  def grouped_friday_list(entries, query, &block)
    ancestors = []

    grouped_query_results(entries, query) do |entry, group_name, group_count, group_totals|
      # Manage the ancestors list
      while ancestors.any? && entry.respond_to?(:is_descendant_of?) && !entry.is_descendant_of?(ancestors.last)
        ancestors.pop
      end

      # Yield the entry and group information to the block
      yield entry, ancestors.size, group_name, group_count, group_totals

      # Add entry to ancestors unless it is a leaf node
      if !entry.respond_to?(:leaf?) || !entry.leaf?
        ancestors << entry
      end
    end
  end

  # makes a hash of the entry for the response
  # ensuring that the hash has all of the columns
  # that are in the query
  def make_entry_hash(entry, columns, user)
    entry_hash = {}

    # Iterate over each key in the columns hash (e.g., :inline, :block, :totalable)
    columns.each do |group_name, group_columns|
      # group_columns is an array of hashes representing individual columns
      group_columns.each do |column|
        # Extract the key from each column hash and convert it to a string
        col_key = column[:key].to_s
        # Assuming entry has a method corresponding to `col_key`, call it.
        entry_hash[col_key] = if entry.respond_to?(method = "value_for_#{col_key.tr(".", "_")}_field_hash")
          make_entry_hash_value(entry.send(method), user)
        # If the entry does not respond to the method, check if we can call a method with a different name
        elsif entry.respond_to?(col_key)
          # specific statement
          make_entry_hash_value(entry.send(col_key), user)
        else
          # If the entry does not respond to the method, set the value to nil
          Rails.logger.warn("Unable to make entry hash: entry does not respond to method '#{col_key}' or '#{method}'")
          nil
        end
      end
    end

    entry_hash
  end

  def make_entry_hash_value(value, user)
    hash = {
      type: value.class.to_s,
      display: value.to_s,
      value: value
    }

    if value.is_a?(ActiveRecord::Base)
      resource_url = get_resource_url(value, user)
      hash[:url] = resource_url if resource_url
    end
    hash
  end

  def get_resource_url(record, user)
    # Determine the correct permission name based on the type of record
    permission = get_permission_name(record)

    # Check if the user is allowed to access the record within its context
    if permission && user.allowed_to?(permission, record.project, global: true)
      polymorphic_url(record)
    end
  rescue
    nil
  end

  def get_permission_name(record)
    case record
    when Issue
      :view_issues
    when Project
      :view_project
    when Document
      :view_documents
    when TimeEntry
      :view_time_entries
    when News
      :view_news
    end
  end

  def make_column_value(current, local_model)
    ret = current
    if ret.start_with?("#{local_model}.")
      ret = ret.sub("#{local_model}.", "")
    end
    "entry.#{ret}"
  end

  def make_entry_gantt_hash(entry, user)
    status = entry.respond_to?(:status) ? entry[:status] : nil
    tracker = entry.respond_to?(:tracker) ? entry.tracker : nil
    related_to = entry.respond_to?(:relations_to) ? entry.relations_to : []
    dependency = related_to&.reject { |relation|
      relation.relation_type == IssueRelation::TYPE_RELATES || relation.relation_type == IssueRelation::TYPE_COPIED_TO
    }&.map { |relation|
      make_entry_gantt_entry_dependency_hash(entry, relation, user)
    }
    color = if status.nil?
      "#00854d"
    elsif status[:background_color].blank?
      "#00854d"
    else
      status[:background_color]
    end
    completed = entry.respond_to?(:done_ratio) ? entry[:done_ratio] / 100 : 0
    tracker_name = tracker.nil? ? l(:label_unknown) : tracker[:name]
    entry_name = if entry.respond_to?(:subject)
      entry[:subject]
    elsif entry.respond_to?(:name)
      entry[:name]
    else
      l(:label_unknown)
    end
    ends_at = entry.respond_to?(:end_timestamp) ? entry.end_timestamp : 0
    labelrank = entry.respond_to?(:calculated_priority) ? 10 - entry[:calculated_priority] : 0
    starts_at = entry.respond_to?(:start_timestamp) ? entry.start_timestamp : 0
    assigned_to = entry.respond_to?(:assigned_to) ? entry.assigned_to : nil
    entry_gantt_hash = {
      color: color,
      completed: {
        amount: completed
      },
      custom: {
        id: entry.id,
        model: entry.class.name.to_s.underscore.downcase,
        assignee: assigned_to.nil? ? nil : assigned_to[:name],
        route: {
          name: "#{entry.class.name.to_s.underscore.downcase.pluralize}-id",
          params: {
            id: entry.id
          }
        }
      },
      dependency: dependency,
      description: "#{tracker_name} ##{entry[:id]}: #{entry_name}",
      end: ends_at,
      id: "entry-#{entry.id}",
      labelrank: labelrank,
      name: "#{tracker_name} ##{entry[:id]}: #{entry_name}",
      start: starts_at
    }
    if entry.respond_to?(:parent_id) && entry[:parent_id].present?
      entry_gantt_hash[:parent] = "entry-#{entry[:parent_id]}"
    end
    entry_gantt_hash
  end

  def make_entry_gantt_entry_dependency_hash(entry, dependent, user)
    relation_type = dependent.relation_type

    case relation_type
    when IssueRelation::TYPE_DUPLICATES
      dash_style = "ShortDot"
      line_color = "#aaaaaa"
      line_width = 1
      radius = 5
      start_marker = {
        symbol: "circle",
        radius: 4,
        fillColor: "#888888",
        lineWidth: 1,
        lineColor: "#555555"
      }
      end_marker = {
        symbol: "circle",
        radius: 4,
        fillColor: "#888888",
        lineWidth: 1,
        lineColor: "#555555"
      }
      type = "simpleConnect"

    when IssueRelation::TYPE_BLOCKS
      dash_style = "Dash"
      line_color = "#ff3333"
      line_width = 2
      radius = 6
      start_marker = {
        symbol: "square",
        radius: 5,
        fillColor: "#ff0000",
        lineWidth: 2,
        lineColor: "#cc0000"
      }
      end_marker = {
        symbol: "square",
        radius: 5,
        fillColor: "#ff0000",
        lineWidth: 2,
        lineColor: "#cc0000"
      }
      type = "fastAvoid"

    when IssueRelation::TYPE_PRECEDES
      dash_style = "LongDashDot"
      line_color = "#33cc33"
      line_width = 2
      radius = 7
      start_marker = {
        symbol: "triangle",
        radius: 6,
        fillColor: "#00ff00",
        lineWidth: 2,
        lineColor: "#008800"
      }
      end_marker = {
        symbol: "triangle",
        radius: 6,
        fillColor: "#00ff00",
        lineWidth: 2,
        lineColor: "#008800"
      }
      type = "straight"

    else
      dash_style = "Solid"
      line_color = "#3333ff"
      line_width = 1
      radius = 4
      start_marker = {
        symbol: "diamond",
        radius: 4,
        fillColor: "#0000ff",
        lineWidth: 1,
        lineColor: "#000088"
      }
      end_marker = {
        symbol: "diamond",
        radius: 4,
        fillColor: "#0000ff",
        lineWidth: 1,
        lineColor: "#000088"
      }
      type = "simpleConnect"
    end

    {
      dashStyle: dash_style,
      lineColor: line_color,
      lineWidth: line_width,
      radius: radius,
      startMarker: start_marker,
      endMarker: end_marker,
      to: "entry-#{dependent[:issue_from_id]}",
      type: type
    }
  end
end

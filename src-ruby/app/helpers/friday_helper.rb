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
      totals: query.totals
    }
    query_data = {
      valid: query.valid?,
      new_record: query.new_record?,
      id: query.id,
      name: query.name,
      type: query.type,
      columns: {
        current: {
          inline: query.inline_columns.map { |column| make_column_hash(column, params) },
          block: query.block_columns.map { |column| make_column_hash(column, params) },
          totalable: query.totalable_columns.map { |column| make_column_hash(column, params) },
          groupable: query.group_by.nil? ? [] : [make_column_hash_by_name(query.group_by, query.columns, params)],
          sort: query.sort_criteria.map { |sort_entry| make_column_sort_hash(sort_entry[0], sort_entry[1], query.columns, params) }
        },
        available: {
          all: query.columns.map { |column| make_column_hash(column, params) },
          inline: query.available_inline_columns.map { |column| make_column_hash(column, params) },
          block: query.available_block_columns.map { |column| make_column_hash(column, params) },
          totalable: query.available_totalable_columns.map { |column| make_column_hash(column, params) },
          groupable: query.groupable_columns.map { |column| make_column_hash(column, params) },
          sortable: query.available_columns.select(&:sortable?).map { |column| make_column_hash(column, params) }
        }
      },
      filters: {
        current: query.filters,
        available: query.available_filters
      },
      display: {
        current: query.options.include?(:display_type) ? query.options[:display_type].to_s : "list",
        available: query.available_display_types
      },
      options: query.options,
      project: query.project_id.nil? ? nil : Project.find(query.project_id)
    }
    permissions = {
      create: query.new_record? && user.allowed_to?(:save_queries, nil, global: true),
      edit: query.editable_by?(user)
    }

    if query.valid?
      payload[:items_length] = scope.count
      payload[:items_per_page] = per_page_option
      payload[:page] = params[:page].nil? ? 1 : params[:page].to_i
      payload[:pages] = Redmine::Pagination::Paginator.new payload[:items_length], payload[:items_per_page], params[:page]
      raw = if @query.display_type == "list"
        scope.offset(payload[:pages].offset).limit(payload[:items_per_page]).to_a
      else
        scope.to_a
      end
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
    end

    ret
  end

  # Make a standardized hash of the column for the response
  def make_column_hash(column, params)
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
    base_hash[:sort] = direction
    base_hash
  end

  # Make a standardized hash of the column for the response, knowing only the name of the column
  # and the list of all columns
  def make_column_hash_by_name(name, all, params)
    column = get_column_by_name(name, all)
    make_column_hash(column, params)
  end

  # Get a column by name from a list of columns
  def get_column_by_name(col_name, all)
    all.find { |column| column.name.to_s == col_name }
  end

  # This method is used to group the results of a query by the group_by column
  def grouped_friday_list(entries, query, &block)
    ancestors = []
    grouped_query_results(entries, query) do |entry, group_name, group_count, group_totals|
      ancestors.pop while ancestors.any? && entry.respond_to?(:is_descendant_of?) && entry.is_descendant_of?(ancestors.last)
      yield entry, ancestors.size, group_name, group_count, group_totals
      ancestors << entry unless entry.respond_to?(:leaf?) && entry.leaf?
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
        if entry.respond_to?(col_key)
          entry_hash[col_key] = make_entry_hash_value(entry.send(col_key), user)
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
    if ret.start_with?(local_model)
      ret = ret.sub("#{local_model}.", "")
    end
    "entry.#{ret}"
  end
end

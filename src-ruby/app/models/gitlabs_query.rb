class GitlabsQuery < Query
  self.queried_class = GitlabInstance

  self.available_columns = [
    QueryColumn.new(:id, sortable: "#{GitlabInstance.table_name}.id", default_order: "desc", caption: "#", frozen: true),
    QueryManyToManyColumn.new(
      GitlabInstance.table_name, "id", Project.table_name, "id", "name", ProjectGitlab.table_name, "gitlab_id", "project_id", caption: l(:field_project_gitlab), sortable: false, groupable: false
    ),
    QueryColumn.new(:name, sortable: "#{GitlabInstance.table_name}.name"),
    QueryColumn.new(:url, sortable: "#{GitlabInstance.table_name}.url"),
    QueryColumn.new(:active, sortable: "#{GitlabInstance.table_name}.active")
  ]

  def initialize(attributes = nil, *args)
    super(attributes)
  end

  def initialize_available_filters
    add_available_filter "id", type: :list, name: l(:field_gitlabs), values: lambda { gitlab_values }
    add_available_filter "name", type: :text
    add_available_filter "url", type: :text
    add_available_filter "active", type: :list, values: [[l(:general_text_yes), "1"], [l(:general_text_no), "0"]]
    add_available_filter "project_ids", type: :list, name: l(:field_project_ids), values: lambda { project_values }
    add_available_filter "gitlab_project_id", type: :list, name: l(:field_gitlab_projects), values: lambda { gitlab_project_values }
  end

  def available_columns
    return @available_columns if @available_columns

    @available_columns = self.class.available_columns.dup
    @available_columns
  end

  def default_columns_names
    @default_columns_names ||= [:id, :name, :url, :active]
  end

  def default_sort_criteria
    [["id", "desc"]]
  end

  def base_scope
    GitlabInstance.where(statement)
  end

  def results_scope(options = {})
    order_option = [group_by_sort_order, options[:order] || sort_clause].flatten.reject(&:blank?)

    base_scope
      .order(order_option)
      .joins(joins_for_order_statement(order_option.join(",")))
  end

  def joins_for_order_statement(order_options)
    joins = [super]

    joins.any? ? joins.join(" ") : nil
  end

  def gitlab_values
    GitlabInstance.all.collect { |g| [g.name, g.id.to_s] }
  end

  def project_values
    Project.all.collect { |s| [s.name, s.id.to_s] }
  end

  def gitlab_project_values
    GitlabProject.all.collect { |gp| [gp.name, gp.id.to_s] }
  end

  # Add this method to handle the SQL generation for the project_ids filter
  def sql_for_project_ids_field(field, operator, value)
    current_project = nil
    if value.include?("curr") || value.include?("prev") || value.include?("next")
      current_project = Sprint.where("start_date <= ? AND end_date >= ?", Date.current, Date.current).first
    end

    case operator
    when "="
      conditions = []

      unless value.empty?
        # Condition for issues associated with specified projects
        project_ids = value.map(&:to_i).join(",")
        conditions << "#{Project.table_name}.id IN (SELECT project_id FROM project_gitlabs WHERE project_id IN (#{project_ids}))"
      end

      condition = if conditions.any?
        # Combine conditions with OR
        "(#{conditions.join(" OR ")})"
      else
        # If no values are selected, return a condition that matches nothing
        "1=0"
      end
    when "!"
      conditions = []

      if value.include?("0")
        # Remove "0" from the values
        value -= ["0"]
        # Condition for issues with any project
        conditions << "#{Project.table_name}.id NOT IN (SELECT project_id FROM issue_projects)"
      end

      # Handle current project
      if value.include?("curr") && current_project
        value -= ["curr"]
        conditions << "#{Project.table_name}.id NOT IN (SELECT project_id FROM project_gitlabs WHERE project_id = #{current_project.id})"
      end

      # Handle previous project (directly before current project)
      if value.include?("prev") && current_project
        value -= ["prev"]
        previous_project = Sprint.where("end_date < ?", current_project.start_date).order("end_date DESC").first
        conditions << "#{Project.table_name}.id NOT IN (SELECT project_id FROM project_gitlabs WHERE project_id = #{previous_project.id})" if previous_project
      end

      # Handle next project (directly after current project)
      if value.include?("next") && current_project
        value -= ["next"]
        next_project = Sprint.where("start_date > ?", current_project.end_date).order("start_date ASC").first
        conditions << "#{Project.table_name}.id NOT IN (SELECT project_id FROM project_gitlabs WHERE project_id = #{next_project.id})" if next_project
      end

      unless value.empty?
        # Condition for issues not associated with specified projects
        project_ids = value.map(&:to_i).join(",")
        conditions << "#{Project.table_name}.id NOT IN (SELECT project_id FROM project_gitlabs WHERE project_id IN (#{project_ids}))"
      end

      condition = if conditions.any?
        # Combine conditions with AND
        "(#{conditions.join(" AND ")})"
      else
        # If no values are selected, return a condition that matches everything
        "1=1"
      end
    else
      # Should not reach here with 'list' filter type
      condition = "1=0"
    end

    condition
  end
end

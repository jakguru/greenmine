class GitlabsQuery < Query
  self.queried_class = GitlabInstance

  self.available_columns = [
    QueryColumn.new(:id, sortable: "#{GitlabInstance.table_name}.id", default_order: "desc", caption: "#", frozen: true),
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

  def gitlab_project_values
    GitlabProject.all.collect { |gp| [gp.name, gp.id.to_s] }
  end
end

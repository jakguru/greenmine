class GithubRepositoriesQuery < Query
  self.queried_class = GithubRepository

  self.available_columns = [
    QueryColumn.new(:repository_id, sortable: "#{GithubRepository.table_name}.repository_id", default_order: "desc", caption: "#", frozen: true),
    QueryColumn.new(:name, sortable: "#{GithubRepository.table_name}.name"),
    QueryColumn.new(:name_with_namespace, sortable: "#{GithubRepository.table_name}.name_with_namespace"),
    QueryColumn.new(:path, sortable: "#{GithubRepository.table_name}.path"),
    QueryColumn.new(:path_with_namespace, sortable: "#{GithubRepository.table_name}.path_with_namespace"),
    QueryColumn.new(:github_instance, sortable: "#{GithubInstance.table_name}.id"),
    QueryColumn.new(:web_url),
    QueryColumn.new(:git_http_url),
    QueryColumn.new(:git_ssh_url)
  ]

  def initialize(attributes = nil, *args)
    super(attributes)
  end

  def initialize_available_filters
    add_available_filter "id", type: :list, name: l(:field_github_repositories), values: lambda { github_repository_values }
    add_available_filter "name", type: :text
    add_available_filter "name_with_namespace", type: :text
    add_available_filter "path", type: :text
    add_available_filter "path_with_namespace", type: :text
    add_available_filter "github_id", type: :list, name: l(:field_githubs), values: lambda { github_values }
    add_available_filter "repository_id", type: :number
  end

  def available_columns
    return @available_columns if @available_columns

    @available_columns = self.class.available_columns.dup
    @available_columns
  end

  def default_columns_names
    @default_columns_names ||= [:repository_id, :github_instance, :name_with_namespace, :path_with_namespace]
  end

  def default_sort_criteria
    [["repository_id", "desc"]]
  end

  def base_scope
    GithubRepository.preload(:github_instance).where(statement)
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

  def github_repository_values
    GithubRepository.all.collect { |gp| [gp.name, gp.id.to_s] }
  end

  def github_values
    GithubInstance.all.collect { |g| [g.name, g.id.to_s] }
  end
end

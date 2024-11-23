class RoleQuery < Query
  self.queried_class = Role

  self.available_columns = [
    QueryColumn.new(:id, sortable: "#{Role.table_name}.id",
      default_order: "desc", caption: "#", frozen: true),
    QueryColumn.new(:name, sortable: "#{Role.table_name}.name"),
    QueryColumn.new(:position, sortable: "#{Role.table_name}.position")
  ]

  def initialize(attributes = nil, *args)
    super(attributes)
  end

  def initialize_available_filters
    add_available_filter "id",
      type: :list,
      name: l(:field_role),
      values: lambda { role_values }
    add_available_filter "name", type: :text
  end

  def available_columns
    return @available_columns if @available_columns

    @available_columns = self.class.available_columns.dup
    @available_columns
  end

  def default_columns_names
    @default_columns_names ||= [:id, :name]
  end

  def default_sort_criteria
    [["position", "asc"]]
  end

  def base_scope
    Role.sorted.where(statement)
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

  def role_values
    Role.sorted.map { |cf| [cf.name, cf.id.to_s] }
  end
end

class GroupQuery < Query
  self.queried_class = Group

  self.available_columns = [
    QueryColumn.new(:avatar),
    QueryColumn.new(:name, sortable: "#{Group.table_name}.lastname")
  ]

  def initialize(attributes = nil, *args)
    super(attributes)
  end

  def initialize_available_filters
    add_available_filter "lastname", type: :text, label: :field_name
  end

  def available_columns
    return @available_columns if @available_columns

    @available_columns = self.class.available_columns.dup
    @available_columns
  end

  def default_columns_names
    @default_columns_names ||= [:avatar, :name]
  end

  def default_sort_criteria
    [["position", "asc"]]
  end

  def base_scope
    Group.sorted.where(statement)
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
end

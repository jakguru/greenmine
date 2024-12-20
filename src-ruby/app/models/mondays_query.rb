class MondaysQuery < Query
  self.queried_class = MondayInstance

  self.available_columns = [
    QueryColumn.new(:id, sortable: "#{MondayInstance.table_name}.id", default_order: "desc", caption: "#", frozen: true),
    QueryColumn.new(:name, sortable: "#{MondayInstance.table_name}.name"),
    QueryColumn.new(:url, sortable: "#{MondayInstance.table_name}.url"),
    QueryColumn.new(:active, sortable: "#{MondayInstance.table_name}.active")
  ]

  def initialize(attributes = nil, *args)
    super(attributes)
  end

  def initialize_available_filters
    add_available_filter "id", type: :list, name: l(:field_mondays), values: lambda { monday_values }
    add_available_filter "name", type: :text
    add_available_filter "active", type: :list, values: [[l(:general_text_yes), "1"], [l(:general_text_no), "0"]]
    add_available_filter "monday_board_id", type: :list, name: l(:field_monday_boards), values: lambda { monday_board_values }
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
    MondayInstance.where(statement)
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

  def monday_values
    MondayInstance.all.collect { |g| [g.name, g.id.to_s] }
  end

  def monday_board_values
    MondayBoard.all.collect { |gp| [gp.name, gp.id.to_s] }
  end
end

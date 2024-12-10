class MondayBoardsQuery < Query
  self.queried_class = MondayBoard

  self.available_columns = [
    QueryColumn.new(:project_id, sortable: "#{MondayBoard.table_name}.project_id", default_order: "desc"),
    QueryColumn.new(:monday_instance, sortable: "#{MondayInstance.table_name}.id"),
    QueryColumn.new(:monday_board_id, sortable: "#{MondayBoard.table_name}.monday_board_id", caption: "#", frozen: true),
    QueryColumn.new(:name),
    QueryColumn.new(:description, inline: false),
    QueryColumn.new(:item_terminology),
    QueryColumn.new(:state),
    QueryColumn.new(:url)
  ]

  def initialize(attributes = nil, *args)
    super(attributes)
  end

  def initialize_available_filters
    add_available_filter "id", type: :list, name: l(:field_monday_projects), values: lambda { monday_project_values }
    add_available_filter "monday_id", type: :list, name: l(:field_mondays), values: lambda { monday_values }
    add_available_filter "project_id", type: :number
    add_available_filter "monday_board_id", type: :string
  end

  def available_columns
    return @available_columns if @available_columns

    @available_columns = self.class.available_columns.dup
    @available_columns
  end

  def default_columns_names
    @default_columns_names ||= [:monday_board_id, :monday_instance, :name, :url]
  end

  def default_sort_criteria
    [["monday_board_id", "desc"]]
  end

  def base_scope
    MondayBoard.preload(:monday_instance).where(statement)
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

  def monday_project_values
    MondayBoard.all.collect { |gp| [gp.name, gp.id.to_s] }
  end

  def monday_values
    MondayInstance.all.collect { |g| [g.name, g.id.to_s] }
  end
end

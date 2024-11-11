class SprintsQuery < Query
  self.queried_class = Sprint

  self.available_columns = [
    QueryColumn.new(:id, sortable: "#{Sprint.table_name}.id",
      default_order: "desc", caption: "#", frozen: true),
    QueryColumn.new(:name, sortable: "#{Sprint.table_name}.name"),
    QueryColumn.new(:state),
    QueryColumn.new(:start_date, sortable: "#{Sprint.table_name}.start_date"),
    QueryColumn.new(:end_date, sortable: "#{Sprint.table_name}.end_date"),
    QueryColumn.new(:total_estimated_work),
    QueryColumn.new(:total_time_logged),
    QueryColumn.new(:progress)
  ]

  def initialize(attributes = nil, *args)
    super(attributes)
  end

  def initialize_available_filters
    add_available_filter "id",
      type: :list,
      name: l(:field_sprints),
      values: lambda { sprint_values }
    add_available_filter "name", type: :text
    add_available_filter "start_date", type: :date
    add_available_filter "end_date", type: :date
    add_available_filter "issue_ids",
      type: :list_optional,
      name: l(:field_issues),
      values: lambda { issue_values }
  end

  def available_columns
    return @available_columns if @available_columns

    @available_columns = self.class.available_columns.dup
    @available_columns
  end

  def default_columns_names
    @default_columns_names ||= [:id, :name, :state, :start_date, :end_date, :total_estimated_work, :total_time_logged, :progress]
  end

  def default_sort_criteria
    [["end_date", "desc"]]
  end

  def base_scope
    Sprint.where(statement)
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

  def issue_values
    Issue.visible.map { |s| ["#{s.tracker.name} ##{s.id}: #{s.subject}", s.id.to_s] }
  end

  def sprint_values
    Sprint.all.collect { |s| [s.name, s.id.to_s] }
  end
end

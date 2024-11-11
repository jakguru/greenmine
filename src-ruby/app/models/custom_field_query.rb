class CustomFieldQuery < Query
  self.queried_class = CustomField

  self.available_columns = [
    QueryColumn.new(:id, sortable: "#{CustomField.table_name}.id",
      default_order: "desc", caption: "#", frozen: true),
    QueryColumn.new(:type, sortable: "#{CustomField.table_name}.type", groupable: "#{CustomField.table_name}.type", caption: l(:field_related_model)),
    QueryColumn.new(:name, sortable: "#{CustomField.table_name}.name"),
    QueryColumn.new(:description, inline: false),
    QueryColumn.new(:field_format, sortable: "#{CustomField.table_name}.field_format", groupable: "#{CustomField.table_name}.field_format"),
    QueryColumn.new(:is_required, sortable: "#{CustomField.table_name}.is_required", groupable: "#{CustomField.table_name}.is_required"),
    QueryColumn.new(:position, sortable: "#{CustomField.table_name}.position")
  ]

  def initialize(attributes = nil, *args)
    super(attributes)
  end

  def initialize_available_filters
    add_available_filter "id",
      type: :list,
      name: l(:field_custom_field),
      values: lambda { custom_field_values }
    add_available_filter "name", type: :text
    add_available_filter "type",
      type: :list,
      name: l(:field_related_model),
      values: lambda { type_values }
  end

  def available_columns
    return @available_columns if @available_columns

    @available_columns = self.class.available_columns.dup
    @available_columns
  end

  def default_columns_names
    @default_columns_names ||= [:id, :type, :name, :field_format, :is_required, :position]
  end

  def default_sort_criteria
    [["position", "asc"]]
  end

  def base_scope
    CustomField.where(statement)
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

  def custom_field_values
    CustomField.all.map { |cf| ["#{cf.type}: #{cf.name}", cf.id.to_s] }
  end

  def type_values
    [
      ["Document Category", "DocumentCategoryCustomField"],
      ["Document", "DocumentCustomField"],
      ["Group", "GroupCustomField"],
      ["Issue", "IssueCustomField"],
      ["Issue Urgency", "IssuePriorityCustomField"],
      ["Issue Impact", "IssueImpactCustomField"],
      ["Project", "ProjectCustomField"],
      ["Time Entry Activity", "TimeEntryActivityCustomField"],
      ["Time Entry", "TimeEntryCustomField"],
      ["User", "UserCustomField"],
      ["Version", "VersionCustomField"]
    ]
  end
end

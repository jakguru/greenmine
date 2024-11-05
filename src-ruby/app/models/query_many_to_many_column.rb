require "query"

class QueryManyToManyColumn < QueryColumn
  def initialize(local_table, local_key, foreign_table, foreign_key, foreign_attribute, pivot_table, pivot_local_key, pivot_foreign_key, options = {})
    @local_table = local_table
    @local_key = local_key
    @foreign_table = foreign_table
    @foreign_key = foreign_key
    @foreign_attribute = foreign_attribute
    @pivot_table = pivot_table
    @pivot_local_key = pivot_local_key
    @pivot_foreign_key = pivot_foreign_key

    @no_assoc_value = options[:no_assoc_value]
    @value_formatter = options[:value_formatter]
    name_with_assoc = :"#{pivot_table}.#{foreign_attribute}"
    super(name_with_assoc, options)
  end

  def value_object(object)
    assoc_collection = object.send(@foreign_table)
    return [@no_assoc_value] if assoc_collection.blank? && @no_assoc_value

    assoc_collection.select(&:visible?).map { |assoc| assoc }.uniq
  end

  def css_classes
    @css_classes ||= "#{@foreign_table}-#{@foreign_attribute}"
  end

  def group_value(object)
    assoc_collection = object.send(@foreign_table)
    return [@no_assoc_value] if assoc_collection.blank? && @no_assoc_value

    assoc_collection.select(&:visible?).map { |assoc| assoc }.uniq
  end

  def group_by_statement
    "#{@foreign_table}.#{@foreign_key}"
  end

  def group_by_selection
    "#{@foreign_table}_#{@foreign_key}"
  end

  attr_reader :local_table

  attr_reader :local_key

  attr_reader :foreign_table

  attr_reader :foreign_key

  attr_reader :foreign_attribute

  attr_reader :pivot_table

  attr_reader :pivot_local_key

  attr_reader :pivot_foreign_key
end

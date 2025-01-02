require "query"

class IssueQuerySprintsColumn < QueryColumn
  def initialize
    super(:sprints, {
      sortable: true,
      groupable: true,
      totalable: false,
      default_order: "desc",
      inline: true,
      caption: l(:field_sprints),
      frozen: nil
    })
  end

  def value_object(object)
    get_collection_from_object(object)
  end

  def group_value(object)
    get_collection_from_object(object)
  end

  def group_by_statement
    "issue_sprints.sprint_id"
  end

  def value(object)
    get_collection_from_object(object).map(&:name).join(", ")
  end

  def css_classes
    "sprints"
  end

  private

  def get_collection_from_object(object)
    collection = object.send(:sprints)
    return [Sprint.backlog] if collection.empty?
    collection.select(&:visible?).map { |sprint| sprint }.uniq.sort_by(&:start_date).map { |sprint| {id: sprint[:id], name: sprint[:name], startDate: sprint[:start_date], endDate: sprint[:end_date]} }
  end
end

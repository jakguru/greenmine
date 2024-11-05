require "query"

class IssueQueryTimeTrackingColumn < QueryColumn
  def initialize
    super(:time_tracking, caption: l(:field_time_tracking), sortable: false, groupable: false)
  end

  def content(issue)
    content_tag(:div, "", class: "time-tracking-button-wrapper", for: issue.id.to_json)
  end
end

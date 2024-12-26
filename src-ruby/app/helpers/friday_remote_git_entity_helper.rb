module FridayRemoteGitEntityHelper
  extend ActiveSupport::Concern

  # Entry point for scanning multiple text fields and creating relationships
  def scan_for_issue_references(*text_fields)
    text_fields.compact.flat_map { |text| scan_text_for_issue_ids(text) }.uniq
  end

  private

  # General method to scan text for issue references (#<issue_id>)
  def scan_text_for_issue_ids(text)
    return [] if text.blank?

    issue_ids = text.scan(/#(\d+)/).flatten.map(&:to_i)
    issue_ids.uniq.filter_map { |id| find_referenced_issue_by_id(id) }
  end

  # Method to find an issue by its ID
  def find_referenced_issue_by_id(issue_id)
    Issue.find_by(id: issue_id)
  end
end

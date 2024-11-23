class StripStartAndDueDatesFromBacklogJob
  include Sidekiq::Job

  def perform(*args)
    enabled = Setting["plugin_friday"]["issue_dates_clear_on_backlog"]
    if enabled == "1"
      unstarted_issue_status_ids = Setting["plugin_friday"]["unstarted_issue_statuses"]
      closed_issue_status_ids = IssueStatus.sorted.where(is_closed: true).pluck(:id)
      backlog = Sprint.backlog
      issues_to_clean = backlog.issues
        .where(closed_on: nil).where.not(start_date: nil)
        .or(backlog.issues.where(closed_on: nil).where.not(due_date: nil))
        .or(backlog.issues.where(closed_on: nil).where.not(start_date: ""))
        .or(backlog.issues.where(closed_on: nil).where.not(due_date: ""))
      if issues_to_clean.any?
        issues_to_clean.each do |issue|
          dirty = false
          if issue.start_date.present? && unstarted_issue_status_ids.include?(issue.status_id.to_s)
            issue.start_date = nil
            dirty = true
          end
          if issue.due_date.present? && !closed_issue_status_ids.include?(issue.status_id)
            issue.due_date = nil
            dirty = true
          end
          if dirty
            issue.save
          end
        end
      end
    end
    # do something
  end
end

MONDAY_UPDATABLE_KLASSES = [
  "IssueStatus",
  "Tracker",
  "IssuePriority",
  "IssueImpact"
]

class ProcessModelUpdatesJob
  include Sidekiq::Job

  def perform(klass, id, action, model = nil)
    # TODO: This is the foundational place to process model updates
    # From here we will be able to send updates to external services,
    # and also to the frontend via ActionCable
    hash = {klass: klass, id: id, action: action, model: model}
    Rails.logger.info "Processing model update: #{hash}"
    push_updates_for_monday_columns(klass)
  end

  def push_updates_for_monday_columns(klass)
    if MONDAY_UPDATABLE_KLASSES.include?(klass)
      InstallMondayFieldConfigurationsForAllBoardsJob.perform_async
    end
  end
end

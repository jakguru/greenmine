MONDAY_UPDATABLE_KLASSES = [
  "IssueStatus",
  "Tracker",
  "IssuePriority",
  "IssueImpact"
]

class ProcessModelUpdatesJob
  include Sidekiq::Job

  def perform(klass, id, action, model = nil, prev = nil)
    # TODO: This is the foundational place to process model updates
    # From here we will be able to send updates to external services,
    # and also to the frontend via ActionCable
    changed_properties = build_changed_properties(action, model, prev)

    hash = {
      klass: klass,
      id: id,
      action: action,
      model: model,
      previous: prev,
      changes: changed_properties
    }
    Rails.logger.info "Processing model update: #{hash}"
    push_updates_for_monday_columns(klass)
  end

  def push_updates_for_monday_columns(klass)
    if MONDAY_UPDATABLE_KLASSES.include?(klass)
      InstallMondayFieldConfigurationsForAllBoardsJob.perform_async
    end
  end

  private

  def build_changed_properties(action, model, prev)
    model_data = model.present? ? JSON.parse(model) : {}
    prev_data = prev.present? ? JSON.parse(prev) : {}

    case action
    when "created"
      model_data.transform_values { |value| {from: nil, to: value} }
    when "destroyed"
      prev_data.transform_values { |value| {from: value, to: nil} }
    else
      prev_data.keys.union(model_data.keys).each_with_object({}) do |key, changes|
        from = prev_data[key]
        to = model_data[key]
        changes[key] = {from: from, to: to} if from != to
      end
    end
  end
end

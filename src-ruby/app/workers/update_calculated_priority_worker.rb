class UpdateCalculatedPriorityWorker
  include Sidekiq::Worker

  def perform
    updated = []
    # Fetch all issues in descending order
    Issue.order(created_on: :desc).find_each do |issue|
      # Run the update_calculated_priority method
      issue.update_calculated_priority
      # Save the issue if changes were made
      if issue.changed?
        issue.save
        updated << issue.id
      end
    end
    ActionCable.server.broadcast("rtu_issues", {updated: updated})
  end
end

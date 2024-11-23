class ScheduledJob < ActiveRecord::Base
  self.table_name = "friday_scheduled_jobs"
  validates :name, presence: true, uniqueness: true

  # Get or create a tracker for a specific scheduled job
  def self.for_task(task_name)
    find_or_create_by(name: task_name)
  end
end

module FridayPlugin
  module DailyScheduledJobRunner
    TASK_NAME = "tasks_every_day"

    def self.run_if_needed
      tracker = ScheduledJob.for_task(TASK_NAME)

      # Check if the task needs to run and ensure it hasn't run in parallel
      if tracker.last_run_at.nil? || tracker.last_run_at < 1.day.ago
        # Use a lock to prevent multiple processes from running this task
        if tracker.update(last_run_at: Time.current)
          run_periodic_task
        end
      end
    end

    def self.run_periodic_task
      # Your periodic task logic here
    rescue => e
      Rails.logger.error("Error while running Friday plugin's periodic task: #{e.message}")
    end
  end
end

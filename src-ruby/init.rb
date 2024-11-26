plugin_lib_dir = File.join(File.dirname(__FILE__), "lib", "friday_plugin")

Rails.autoloaders.main.push_dir plugin_lib_dir

Rails.configuration.to_prepare do
  require_dependency "friday_plugin/news_patch"
end

Redmine::Plugin.register :friday do
  name "Friday"
  author "Jak Guru"
  description "A Redmine plugin to transform Redmine into a modern UX/UI Experience"
  version "1.0.0"
  requires_redmine version_or_higher: "5.1"

  settings partial: "settings/friday",
    default: {
      "users_allowed_to_manage_sprints" => [],
      "groups_allowed_to_manage_sprints" => [],
      "issue_dates_clear_on_backlog" => "0",
      "unstarted_issue_statuses" => [],
      "repository_base_path" => "/var/redmine/repos",
      "monday_access_token" => "",
      "monday_board_id" => "",
      "monday_group_id" => "topics",
      "monday_enabled" => "0",
      "gitlab_api_base_url" => "https://gitlab.com",
      "gitlab_api_token" => "",
      "gitlab_api_enabled" => "0",
      "sentry_api_base_url" => "",
      "sentry_api_token" => "",
      "sentry_api_organization" => "",
      "sentry_api_enabled" => "0",
      "google_translate_api_key" => "",
      "google_translate_enabled" => "0",
      "chatgpt_api_key" => "",
      "chatgpt_org_id" => "",
      "chatgpt_project_id" => "",
      "chatgpt_enabled" => "0"
    }

  permission :assign_to_sprint, require: :member
  permission :unassign_from_sprint, require: :member
end

if ENV["REDIS_URL"] && !(defined?(Rails::Console) || File.split($0).last == "rake")
  x = Sidekiq.configure_embed do |config|
    config.queues = %w[critical default low]
    config.concurrency = 2
  end
  x.run
  Rails.logger.info "Sidekiq started"
end

Rails.application.configure do
  config.action_cable.mount_path = "/realtime"
end

# Rails.application.config.after_initialize do
#   Rails.application.executor.wrap do
#     Thread.new do
#       ActiveSupport.on_load(:active_record) do
#         loop do
#           # Run the scheduled job check
#           FridayPlugin::ScheduledJobRunner.run_if_needed

#           # Sleep for 1 minute before checking again
#           sleep 60
#         rescue => e
#           Rails.logger.error("Error in Friday Scheduled Job Polling: #{e.message}")
#           sleep 1
#         end
#       end
#     end
#   end
# end

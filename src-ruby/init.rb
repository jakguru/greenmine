plugin_lib_dir = File.join(File.dirname(__FILE__), "lib", "friday_plugin")

def command_available?(command)
  system("command -v #{command} > /dev/null 2>&1")
end

Rails.autoloaders.main.push_dir plugin_lib_dir

Rails.configuration.to_prepare do
  require_dependency "friday_plugin/news_patch"
  require_dependency "friday_plugin/active_record_hooks"
  require_dependency "friday_plugin/redmine_access_control_patch"

  # Load RemoteGit models
  require_dependency "remote_git/commit"
  require_dependency "remote_git/merge_request"
  require_dependency "remote_git/pipeline"
  require_dependency "remote_git/release"
  require_dependency "remote_git/tag"
end

ActiveSupport.on_load(:active_record) do
  include FridayPlugin::ActiveRecordHooks
end

Redmine::Activity.map do |activity|
  activity.register :commits, default: true, class_name: "RemoteGit::Commit"
  activity.register :merge_requests_opened, default: true, class_name: "RemoteGit::MergeRequest"
  activity.register :merge_requests_closed, default: true, class_name: "RemoteGit::MergeRequest"
  activity.register :pipelines_started, default: true, class_name: "RemoteGit::Pipeline"
  activity.register :pipelines_ended, default: true, class_name: "RemoteGit::Pipeline"
  activity.register :releases, default: true, class_name: "RemoteGit::Release"
  activity.register :tags, default: true, class_name: "RemoteGit::Tag"
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
  permission :view_associated_gitlab_projects, public: true, read: true
  permission :manage_associated_gitlab_projects, {projects: :settings}, require: :member
  permission :view_associated_github_repositories, public: true, read: true
  permission :manage_associated_github_repositories, {projects: :settings}, require: :member
  permission :get_chart_for_issues_by_status, {projects: :get_chart_for_issues_by_status}, require: :member
  permission :get_chart_for_issues_by_tracker, {projects: :get_chart_for_issues_by_tracker}, require: :member
  permission :get_chart_for_activity_summary, {projects: :get_chart_for_activity_summary}, require: :member
  permission :get_chart_for_time_summary, {projects: :get_chart_for_time_summary}, require: :member
  permission :view_associated_monday_board, public: true, read: true
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

Rails.application.config.after_initialize do
  # ActiveRecord::Base.logger = Logger.new(STDOUT)
  if ENV["REDMINE_ENABLE_CRONS"].present?
    if command_available?("curl")
      Rails.logger.info "Starting Schedule Job Polling"
      Thread.new do
        loop do
          system("curl -s -X GET http://localhost:3000/crons/poll > /dev/null 2>&1")
          sleep 60
        rescue => e
          Rails.logger.error("Error in Friday Scheduled Job Polling: #{e.message}")
          sleep 1
        end
      end
    else
      Rails.logger.info "Cannot Start Schedule Job Polling"
    end
  end
end

Redmine::MenuManager.map :project_menu do |menu|
  new_object_item = menu.find(:new_object)
  if new_object_item&.children.present?
    new_object_item.children.delete_if { |child| child.name == :new_issue_category }
  end

  menu.delete :boards
  menu.delete :repository

  menu.delete :roadmap
  menu.push :releases,
    {controller: "versions", action: "index"},
    param: :project_id,
    after: :activity,
    if: proc { |project| project&.module_enabled?("issue_tracking") }
end

Rails.application.config.after_initialize do
  Redmine::AccessControl.permissions.delete_if { |p| p.project_module == :boards }
  Redmine::AccessControl.permissions.delete_if { |p| p.project_module == :repository }
end

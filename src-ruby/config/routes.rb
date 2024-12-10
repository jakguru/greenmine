# config/routes.rb

require "sidekiq/web"
require_relative "../lib/friday_plugin/sidekiq_auth"

Sidekiq::Web.use FridayPlugin::SidekiqAuth

RedmineApp::Application.routes.draw do
  match "nht/docker/health", controller: "docker", action: "answer_health_check", via: [:get, :post]
  get "ui/data/app", to: "ui#get_app_data"
  get "ui/data/project-by-id/:id", to: "ui#get_project_link_info_by_id"
  get "ui/actions/issues", to: "ui#get_actions_for_issues"
  get "crons/poll", to: "crons#poll"
  get "admin/integrations", to: "admin#integrations"
  get "users/:id/avatar", to: "ui#get_user_avatar"
  get "groups/:id/avatar", to: "ui#get_group_avatar"
  get "manifest.webmanifest", to: "ui#manifest_dot_webmanifest"
  get "browserconfig.xml", to: "ui#browserconfig_dot_xml"
  get "yandex-browser-manifest.json", to: "ui#yandex_browser_manifest_dot_json"
  mount Sidekiq::Web => "admin/sidekiq"

  # Time Tracking
  resources :issues do
    member do
      get "time-tracking/statuses", to: "issue_time_tracking_starts#get_available_statuses_for_issue_for_user"
    end

    resources :issue_time_tracking_starts, only: [:create] do
      collection do
        get "", to: "issue_time_tracking_starts#get" # This maps GET to the 'get' action
        post "stop"
      end
    end
  end

  get "time-tracking/activities", to: "issue_time_tracking_starts#get_activities"

  # Sprints
  resources :sprints, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  resources :sprints do
    member do
      post "assign", to: "sprints#assign_to_sprint"
    end
  end
  # put "issues/:id/sprints", to: "issue_sprints#update"
  get "sprints/:id/burndown", to: "sprints#show_burndown"
  post "sprints/backlog/assign/", to: "sprints#assign_to_backlog"

  # Custom Fields
  resources :custom_fields do
    member do
      post "manage-enumerations", to: "custom_fields#create_enumeration"
      put "manage-enumerations/:enumeration_id", to: "custom_fields#update_enumeration"
      delete "manage-enumerations/:enumeration_id", to: "custom_fields#destroy_enumeration"
    end
  end

  namespace :admin do
    namespace :integrations do
      # Gitlab Integration
      resources :gitlab, controller: "gitlab", only: [:index, :show, :new, :edit, :create, :update, :destroy]
      resources :gitlab do
        member do
          post "projects", to: "gitlab#enqueue_fetch_projects"
          get "projects/:project_id", to: "gitlab#show_project"
          put "projects/:project_id", to: "gitlab#update_project_gitlab_project_association"
          post "projects/:project_id/actions", to: "gitlab#handle_project_action"
          post "projects/:project_id/actions/:action_to_perform", to: "gitlab#handle_project_action"
          post "users", to: "gitlab#enqueue_fetch_users"
          put "users", to: "gitlab#update_user_gitlab_user_association"
        end
      end

      # Monday Integration
      resources :monday, controller: "monday", only: [:index, :show, :new, :edit, :create, :update, :destroy]
      resources :monday do
        member do
          post "boards", to: "monday#enqueue_fetch_boards"
          get "boards/:monday_board_id", to: "monday#show_board"
          put "boards/:monday_board_id", to: "monday#update_board"
          post "boards/:monday_board_id/actions", to: "monday#handle_board_action"
          post "boards/:monday_board_id/actions/:action_to_perform", to: "monday#handle_board_action"
          post "users", to: "monday#enqueue_fetch_users"
          put "users", to: "monday#update_user_monday_user_association"
        end
      end

      # Github Integration
      resources :github, controller: "github", only: [:index, :show, :new, :edit, :create, :update, :destroy]
      resources :gitlab do
        member do
          post "repositories", to: "gitlab#enqueue_fetch_repositories"
          get "repositories/:repository_id", to: "gitlab#show_repository"
          put "repositories/:repository_id", to: "gitlab#update_repository_gitlab_repository_association"
          post "repositories/:repository_id/actions", to: "gitlab#handle_repository_action"
          post "repositories/:repository_id/actions/:action_to_perform", to: "gitlab#handle_repository_action"
          post "users", to: "gitlab#enqueue_fetch_users"
          put "users", to: "gitlab#update_user_gitlab_user_association"
        end
      end
    end
  end

  # Webhooks
  namespace :webhooks do
    match "gitlab", to: "gitlab#handle", via: [:get, :post, :put, :patch, :delete, :head]
    match "monday", to: "monday#handle", via: [:get, :post, :put, :patch, :delete, :head]
  end

  # Projects
  resources :projects do
    member do
      post "charts/issues-summary-by-status", to: "projects#get_chart_for_issues_by_status"
      post "charts/issues-summary-by-tracker", to: "projects#get_chart_for_issues_by_tracker"
      post "charts/activity-summary", to: "projects#get_chart_for_activity_summary"
      post "charts/time-summary", to: "projects#get_chart_for_time_summary"
    end
  end
end

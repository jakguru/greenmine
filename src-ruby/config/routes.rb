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
          post "users", to: "gitlab#enqueue_fetch_users"
          put "users", to: "gitlab#update_user_gitlab_user_association"
        end
      end
    end
  end

  # Webhooks
  namespace :webhooks do
    match "gitlab", to: "gitlab#handle", via: [:get, :post, :put, :patch, :delete, :head]
  end
end

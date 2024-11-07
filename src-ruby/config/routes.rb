require "sidekiq/web"
require_relative "../lib/friday_plugin/sidekiq_auth"

Sidekiq::Web.use FridayPlugin::SidekiqAuth

RedmineApp::Application.routes.draw do
  match "nht/docker/health", controller: "docker", action: "answer_health_check", via: [:get, :post]
  get "ui/data/app", to: "ui#get_app_data"
  get "ui/data/project-by-id/:id", to: "ui#get_project_link_info_by_id"
  # get "admin/sidekiq", to: "sidekiq#stats"
  mount Sidekiq::Web => "admin/sidekiq"
  # Time Tracking
  resources :issues do
    resources :issue_time_tracking_starts, only: [:create] do
      collection do
        get "" => "issue_time_tracking_starts#get" # This maps GET to the 'get' action
        post "stop"
      end
    end
  end
  get "nht/time-tracking/activities", to: "issue_time_tracking_starts#get_activities"
  # Sprints
  resources :sprints, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  # put "issues/:id/sprints", to: "issue_sprints#update"
  get "sprints/:id/burndown", to: "sprints#show_burndown"
end

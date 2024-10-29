require "sidekiq/web"
RedmineApp::Application.routes.draw do
  get "ui/data/app", to: "ui#get_app_data"
  get "ui/data/project-by-id/:id", to: "ui#get_project_link_info_by_id"
  get "admin/sidekiq", to: "sidekiq#stats"
end

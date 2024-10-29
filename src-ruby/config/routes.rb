require "sidekiq/web"
RedmineApp::Application.routes.draw do
  if ENV["REDIS_URL"] && !(defined?(Rails::Console) || File.split($0).last == "rake")
    mount Sidekiq::Web => "/sidekiq", :constraints => FridayPlugin::AdminConstraint.new
  end

  get "ui/data/app", to: "ui#get_app_data"
  get "ui/data/project-by-id/:id", to: "ui#get_project_link_info_by_id"
end

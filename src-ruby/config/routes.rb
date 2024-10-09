RedmineApp::Application.routes.draw do
    get 'ui/data/app', :to => 'ui#get_app_data'
end
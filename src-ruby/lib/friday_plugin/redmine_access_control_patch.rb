module FridayPlugin
  module RedmineAccessControlPatch
    def available_project_modules
      super - %w[boards repository]
    end
  end
end

Redmine::AccessControl.singleton_class.prepend(FridayPlugin::RedmineAccessControlPatch)

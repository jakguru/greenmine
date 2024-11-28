require_dependency "project"

module FridayPlugin
  module ProjectPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        has_many :project_gitlabs, dependent: :destroy
        safe_attributes "avatar"
        safe_attributes "banner"
      end
    end

    module InstanceMethods
    end
  end
end

Project.send(:include, FridayPlugin::ProjectPatch) unless Project.included_modules.include?(FridayPlugin::ProjectPatch)

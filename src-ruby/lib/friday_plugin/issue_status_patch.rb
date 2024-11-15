require_dependency "issue_status"

module FridayPlugin
  module IssueStatusPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        safe_attributes "icon"
        safe_attributes "text_color"
        safe_attributes "background_color"
      end
    end

    module InstanceMethods
    end
  end
end

IssueStatus.send(:include, FridayPlugin::IssueStatusPatch) unless IssueStatus.included_modules.include?(FridayPlugin::IssueStatusPatch)

require_dependency "group"

module FridayPlugin
  module GroupPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        safe_attributes "avatar"
      end
    end

    module InstanceMethods
    end
  end
end

Group.send(:include, FridayPlugin::GroupPatch) unless Group.included_modules.include?(FridayPlugin::GroupPatch)

require_dependency "role"

module FridayPlugin
  module RolePatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        safe_attributes "is_external"
      end
    end

    module InstanceMethods
      
    end
  end
end

Role.send(:include, FridayPlugin::RolePatch) unless Role.included_modules.include?(FridayPlugin::RolePatch)

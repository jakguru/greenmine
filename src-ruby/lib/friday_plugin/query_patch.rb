require_dependency "issue_query"

module FridayPlugin
  module QueryPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        # here
      end
    end

    module InstanceMethods
      # no op
    end
  end
end

Query.send(:include, FridayPlugin::QueryPatch) unless Query.included_modules.include?(FridayPlugin::QueryPatch)

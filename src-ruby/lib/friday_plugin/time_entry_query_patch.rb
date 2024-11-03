require_dependency "time_entry_query"

module FridayPlugin
  module TimeEntryQueryPatch
    def self.included(base)
      base.class_eval do
        def default_totalable_names
          raw = Setting.time_entry_list_defaults.symbolize_keys[:totalable_names]
          raw.nil? ? [] : raw.map(&:to_sym)
        end
      end
    end

    module InstanceMethods
    end
  end
end

TimeEntryQuery.send(:include, FridayPlugin::TimeEntryQueryPatch) unless TimeEntryQuery.included_modules.include?(FridayPlugin::TimeEntryQueryPatch)

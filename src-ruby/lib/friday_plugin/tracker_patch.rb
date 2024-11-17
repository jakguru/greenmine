require_dependency "tracker"

module FridayPlugin
  module TrackerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        safe_attributes "icon"
        safe_attributes "color"
        const_set(:CORE_FIELDS, (Tracker::CORE_FIELDS + ["impact_id", "sprints"]).freeze)
      end
    end

    module InstanceMethods
    end
  end
end

Tracker.send(:include, FridayPlugin::TrackerPatch) unless Tracker.included_modules.include?(FridayPlugin::TrackerPatch)

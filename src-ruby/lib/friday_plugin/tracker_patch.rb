require_dependency "tracker"

module FridayPlugin
  module TrackerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        safe_attributes "icon"
        safe_attributes "color"
        safe_attributes "nodes_json"
        safe_attributes "edges_json"
        safe_attributes "new_issue_statuses_json"
        const_set(:CORE_FIELDS, (Tracker::CORE_FIELDS + ["impact_id", "sprints"]).freeze)

        def workflow_nodes
          nodes_json.nil? ? [] : JSON.parse(nodes_json)
        end

        def workflow_edges
          edges_json.nil? ? [] : JSON.parse(edges_json)
        end

        def workflow_new_issue_statuses
          new_issue_statuses_json.nil? ? {} : JSON.parse(new_issue_statuses_json)
        end
      end
    end

    module InstanceMethods
    end
  end
end

Tracker.send(:include, FridayPlugin::TrackerPatch) unless Tracker.included_modules.include?(FridayPlugin::TrackerPatch)

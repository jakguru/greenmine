require_dependency "issue"

module FridayPlugin
  module IssuePatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        belongs_to :impact, class_name: "IssueImpact"

        safe_attributes "impact_id"

        before_save :update_calculated_priority
      end
    end

    module InstanceMethods
      def calculated_priority
        # Return the value from the database column
        self[:calculated_priority]
      end

      private

      def update_calculated_priority
        impact_position = impact&.position || 0
        priority_position = priority&.position || 0
        impact_count = IssueImpact.count.nonzero? || 1
        priority_count = IssuePriority.count.nonzero? || 1
        average_position = (impact_position.to_f / impact_count + priority_position.to_f / priority_count) / 2
        self.calculated_priority = (10 * (1 - average_position)).round.clamp(1, 10)
      end
    end
  end
end

Issue.send(:include, FridayPlugin::IssuePatch) unless Issue.included_modules.include?(FridayPlugin::IssuePatch)

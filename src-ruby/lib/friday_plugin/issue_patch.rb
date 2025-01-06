require_dependency "issue"

module FridayPlugin
  module IssuePatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        belongs_to :impact, class_name: "IssueImpact"
        has_many :issue_sprints, dependent: :destroy
        has_many :sprints, through: :issue_sprints

        # Remote Git Entity Associations
        has_many :remote_git_associations, dependent: :destroy
        has_many :remote_git_branches, through: :remote_git_associations, source: :associable, source_type: "RemoteGit::Branch"
        has_many :remote_git_commits, through: :remote_git_associations, source: :associable, source_type: "RemoteGit::Commit"
        has_many :remote_git_merge_requests, through: :remote_git_associations, source: :associable, source_type: "RemoteGit::MergeRequest"
        has_many :remote_git_pipelines, through: :remote_git_associations, source: :associable, source_type: "RemoteGit::Pipeline"
        has_many :remote_git_releases, through: :remote_git_associations, source: :associable, source_type: "RemoteGit::Release"
        has_many :remote_git_tags, through: :remote_git_associations, source: :associable, source_type: "RemoteGit::Tag"

        safe_attributes "impact_id"
        safe_attributes "sprints"
        safe_attributes "time_tracking"

        before_save :update_calculated_priority
        after_save :push_realtime_update
      end
    end

    module InstanceMethods
      def calculated_priority
        # Return the value from the database column
        self[:calculated_priority]
      end

      def time_tracking
        ""
      end

      def sprints
        issue_sprints.map(&:sprint)
      end

      def value_for_sprints_field_hash
        collection = send(:sprints)
        if !collection.is_a?(Array) || collection.empty?
          return [
            {id: nil, name: Sprint.backlog.name, startDate: Sprint.backlog[:start_date], endDate: Sprint.backlog[:end_date]}
          ]
        end
        collection.select(&:visible?).map { |sprint| sprint }.uniq.sort_by(&:start_date).map { |sprint| {id: sprint[:id], name: sprint[:name], startDate: sprint[:start_date], endDate: sprint[:end_date]} }
      end

      def value_for_issue_sprints_name_field_hash
        value_for_sprints_field_hash
      end

      def update_calculated_priority
        impact_position = impact&.position || 0
        priority_position = priority&.position || 0
        impact_count = IssueImpact.count.nonzero? || 1
        priority_count = IssuePriority.count.nonzero? || 1
        average_position = (impact_position.to_f / impact_count + priority_position.to_f / priority_count) / 2
        self.calculated_priority = (10 * (1 - average_position)).round.clamp(1, 10)
      end

      def push_realtime_update
        FridayPlugin::IssuesChannel.broadcast_to(self, self)
      end

      def start_timestamp
        start_timestamp_date = start_date
        start_timestamp_date ||= sprints.map(&:start_date).compact.min
        start_timestamp_date ||= created_on

        # Restrain date only if sprints are present
        if sprints.any?
          start_timestamp_date = restrain_date_to_sprints(start_timestamp_date)
        end

        start_timestamp_date.beginning_of_day.to_time.to_i * 1000
      end

      def end_timestamp
        end_timestamp_date = closed_on || due_date
        end_timestamp_date ||= if start_date && estimated_hours.present?
          start_date + hours_to_days(estimated_hours).days
        else
          sprints.map(&:end_date).compact.max
        end
        end_timestamp_date ||= Date.current

        # Restrain date only if sprints are present
        if sprints.any?
          end_timestamp_date = restrain_date_to_sprints(end_timestamp_date)
        end

        end_timestamp_date.end_of_day.to_time.to_i * 1000
      end

      def hours_to_days(hours)
        (hours / 8).round(0)
      end

      def restrain_date_to_sprints(date)
        min_possible_date = sprints.map(&:start_date).compact.min
        max_possible_date = sprints.map(&:end_date).compact.max

        # Only clamp if both min and max dates are present
        if min_possible_date && max_possible_date
          date.clamp(min_possible_date, max_possible_date)
        else
          date
        end
      end
    end
  end
end

Issue.send(:include, FridayPlugin::IssuePatch) unless Issue.included_modules.include?(FridayPlugin::IssuePatch)

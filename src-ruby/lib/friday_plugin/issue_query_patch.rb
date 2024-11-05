require_dependency "issue_query"

module FridayPlugin
  module IssueQueryPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method :redmine_base_initialize_available_filters, :initialize_available_filters
        alias_method :redmine_base_statement, :statement

        def initialize_available_filters
          # Call the original method to ensure all default filters are loaded
          redmine_base_initialize_available_filters

          add_available_filter(
            "impact_id",
            type: :list_with_history, values: IssueImpact.all.collect { |s| [s.name, s.id.to_s] }
          )

          add_available_filter(
            "calculated_priority",
            type: :list,
            name: l(:field_calculated_priority),
            values: (1..10).to_a.map { |i| [(i * 10).to_s, (i * 10).to_s] }
          )

          add_available_filter "monday_item_id",
            type: :search,
            name: l(:field_monday_item_id)

          add_available_filter "sprint_ids",
            type: :list,
            name: l(:field_sprints),
            values: lambda { sprint_values }
        end

        add_available_column(QueryColumn.new(:impact, sortable: "#{IssueImpact.table_name}.position",
          default_order: "desc", groupable: true))

        add_available_column(QueryManyToManyColumn.new(
          Issue.table_name,
          "id",
          Sprint.table_name,
          "id",
          "name",
          :issue_sprints,
          :issue_id,
          :sprint_id,
          caption: l(:field_sprints),
          sortable: false,
          groupable: true,
          no_assoc_value: Sprint.backlog,
          value_formatter: lambda { |sprint|
            if sprint.is_a?(Array)
              Rails.logger.info("#{sprint} is an array")
              sprint.map do |s|
                s.to_s
              end.join(", ").html_safe
            elsif sprint.is_a?(Sprint)
              sprint.to_s
            else
              Rails.logger.info("#{sprint} is neither an array nor a Sprint")
              sprint.to_s
            end
          }
        ))

        add_available_column(IssueQueryTimeTrackingColumn.new)
      end
    end

    module InstanceMethods
      public

      def sprint_values
        Sprint.all.collect { |s| [s.name, s.id.to_s] } << [l(:label_backlog), "0"]
      end

      # Add this method to handle the SQL generation for the sprint_ids filter
      def sql_for_sprint_ids_field(field, operator, value)
        case operator
        when "="
          conditions = []

          if value.include?("0")
            # Remove "0" from the values
            value -= ["0"]
            # Condition for backlog issues
            conditions << "#{Issue.table_name}.id NOT IN (SELECT issue_id FROM issue_sprints)"
          end

          unless value.empty?
            # Condition for issues associated with specified sprints
            sprint_ids = value.map(&:to_i).join(",")
            conditions << "#{Issue.table_name}.id IN (SELECT issue_id FROM issue_sprints WHERE sprint_id IN (#{sprint_ids}))"
          end

          condition = if conditions.any?
            # Combine conditions with OR
            "(#{conditions.join(" OR ")})"
          else
            # If no values are selected, return a condition that matches nothing
            "1=0"
          end
        when "!"
          conditions = []

          if value.include?("0")
            # Remove "0" from the values
            value -= ["0"]
            # Condition for issues with any sprint
            conditions << "#{Issue.table_name}.id IN (SELECT issue_id FROM issue_sprints)"
          end

          unless value.empty?
            # Condition for issues not associated with specified sprints
            sprint_ids = value.map(&:to_i).join(",")
            conditions << "#{Issue.table_name}.id NOT IN (SELECT issue_id FROM issue_sprints WHERE sprint_id IN (#{sprint_ids}))"
          end

          condition = if conditions.any?
            # Combine conditions with AND
            "(#{conditions.join(" AND ")})"
          else
            # If no values are selected, return a condition that matches everything
            "1=1"
          end
        else
          # Should not reach here with 'list' filter type
          condition = "1=0"
        end

        condition
      end
    end
  end
end

IssueQuery.send(:include, FridayPlugin::IssueQueryPatch) unless IssueQuery.included_modules.include?(FridayPlugin::IssueQueryPatch)

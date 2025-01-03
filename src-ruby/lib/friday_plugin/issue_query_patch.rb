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

        def base_scope
          Issue.visible
            .joins(:status, :project)
            .left_joins(:issue_sprints)
            .where(statement)
        end

        def issues(options = {})
          order_option = [group_by_sort_order, options[:order] || sort_clause].flatten.reject(&:blank?)
          # The default order of IssueQuery is issues.id DESC(by IssueQuery#default_sort_criteria)
          unless ["#{Issue.table_name}.id ASC", "#{Issue.table_name}.id DESC"].any? { |i| order_option.include?(i) }
            order_option << "#{Issue.table_name}.id DESC"
          end

          scope = base_scope
            .preload(:priority, :sprints, :issue_sprints)
            .includes(([:status, :project] + (options[:include] || [])).uniq)
            .where(options[:conditions])
            .order(order_option)
            .joins(joins_for_order_statement(order_option.join(",")))
            .limit(options[:limit])
            .offset(options[:offset])

          scope =
            scope.preload(
              [:tracker, :author, :assigned_to, :fixed_version,
                :category, :attachments] & columns.map(&:name)
            )
          if has_custom_field_column?
            scope = scope.preload(:custom_values)
          end

          issues = scope.to_a

          if has_column?(:spent_hours)
            Issue.load_visible_spent_hours(issues)
          end
          if has_column?(:total_spent_hours)
            Issue.load_visible_total_spent_hours(issues)
          end
          if has_column?(:last_updated_by)
            Issue.load_visible_last_updated_by(issues)
          end
          if has_column?(:relations)
            Issue.load_visible_relations(issues)
          end
          if has_column?(:last_notes)
            Issue.load_visible_last_notes(issues)
          end
          issues
        rescue ::ActiveRecord::StatementInvalid => e
          raise StatementInvalid.new(e.message)
        end

        add_available_column(QueryColumn.new(:impact, sortable: "#{IssueImpact.table_name}.position",
          default_order: "desc", groupable: true))

        add_available_column(QueryColumn.new(:calculated_priority, sortable: "#{Issue.table_name}.calculated_priority",
          default_order: "desc", groupable: true))

        add_available_column(IssueQueryTimeTrackingColumn.new)
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
              sprint[:name]
            else
              Rails.logger.info("#{sprint} is neither an array nor a Sprint")
              sprint[:name]
            end
          }
        ))
        # add_available_column(IssueQuerySprintsColumn.new)
      end
    end

    module InstanceMethods
      public

      def sprint_values
        Sprint.all.collect { |s| [s.name, s.id.to_s] } << [l(:label_backlog), "0"] << [l(:label_previous), "prev"] << [l(:label_current), "curr"] << [l(:label_next), "next"]
      end

      # Add this method to handle the SQL generation for the sprint_ids filter
      def sql_for_sprint_ids_field(field, operator, value)
        current_sprint = nil
        if value.include?("curr") || value.include?("prev") || value.include?("next")
          current_sprint = Sprint.where("start_date <= ? AND end_date >= ?", Date.current, Date.current).first
        end

        case operator
        when "="
          conditions = []

          if value.include?("0")
            # Remove "0" from the values
            value -= ["0"]
            # Condition for backlog issues
            conditions << "#{Issue.table_name}.id NOT IN (SELECT issue_id FROM issue_sprints)"
          end

          # Handle current sprint
          if value.include?("curr") && current_sprint
            value -= ["curr"]
            conditions << "#{Issue.table_name}.id IN (SELECT issue_id FROM issue_sprints WHERE sprint_id = #{current_sprint.id})"
          end

          # Handle previous sprint (directly before current sprint)
          if value.include?("prev") && current_sprint
            value -= ["prev"]
            previous_sprint = Sprint.where("end_date < ?", current_sprint.start_date).order("end_date DESC").first
            conditions << "#{Issue.table_name}.id IN (SELECT issue_id FROM issue_sprints WHERE sprint_id = #{previous_sprint.id})" if previous_sprint
          end

          # Handle next sprint (directly after current sprint)
          if value.include?("next") && current_sprint
            value -= ["next"]
            next_sprint = Sprint.where("start_date > ?", current_sprint.end_date).order("start_date ASC").first
            conditions << "#{Issue.table_name}.id IN (SELECT issue_id FROM issue_sprints WHERE sprint_id = #{next_sprint.id})" if next_sprint
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

          # Handle current sprint
          if value.include?("curr") && current_sprint
            value -= ["curr"]
            conditions << "#{Issue.table_name}.id NOT IN (SELECT issue_id FROM issue_sprints WHERE sprint_id = #{current_sprint.id})"
          end

          # Handle previous sprint (directly before current sprint)
          if value.include?("prev") && current_sprint
            value -= ["prev"]
            previous_sprint = Sprint.where("end_date < ?", current_sprint.start_date).order("end_date DESC").first
            conditions << "#{Issue.table_name}.id NOT IN (SELECT issue_id FROM issue_sprints WHERE sprint_id = #{previous_sprint.id})" if previous_sprint
          end

          # Handle next sprint (directly after current sprint)
          if value.include?("next") && current_sprint
            value -= ["next"]
            next_sprint = Sprint.where("start_date > ?", current_sprint.end_date).order("start_date ASC").first
            conditions << "#{Issue.table_name}.id NOT IN (SELECT issue_id FROM issue_sprints WHERE sprint_id = #{next_sprint.id})" if next_sprint
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

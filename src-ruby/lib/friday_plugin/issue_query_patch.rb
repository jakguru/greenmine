require_dependency "issue_query"

module FridayPlugin
  module IssueQueryPatch
    def self.included(base)
      base.class_eval do
        alias_method :redmine_base_initialize_available_filters, :initialize_available_filters

        def initialize_available_filters
          # Call the original method to ensure all default filters are loaded
          redmine_base_initialize_available_filters

          add_available_filter(
            "impact_id",
            type: :list_with_history, values: IssueImpact.all.collect { |s| [s.name, s.id.to_s] }
          )

          add_available_filter(
            "calculated_priority",
            type: :integer,
            name: l(:field_calculated_priority),
            min: 1,
            max: 10
          )
        end

        add_available_column(QueryColumn.new(:impact, sortable: "#{IssueImpact.table_name}.position",
          default_order: "desc", groupable: true))

        add_available_column(QueryColumn.new(:calculated_priority, caption: :field_calculated_priority,
          sortable: "#{Issue.table_name}.calculated_priority", groupable: true))
      end
    end

    module InstanceMethods
    end
  end
end

IssueQuery.send(:include, FridayPlugin::IssueQueryPatch) unless IssueQuery.included_modules.include?(FridayPlugin::IssueQueryPatch)

module FridayPlugin
  module QueriesHelperPatch
    def self.included(base)
      base.class_eval do
        alias_method :redmine_base_grouped_query_results, :grouped_query_results

        def grouped_query_results(items, query, &block)
          result_count_by_group = query.result_count_by_group
          previous_group, first = nil, true
          totals_by_group = query.totalable_columns.each_with_object({}) do |column, h|
            h[column] = query.total_by_group_for(column)
          end

          # Cache to store group details for reuse
          group_cache = {}

          items.each do |item|
            if query.group_by_column.nil?
              yield item, nil, nil, nil
              next
            end
            group = query.group_by_column.group_value(item)

            # Ensure group is always an array for uniform processing
            groups = group.is_a?(Array) ? group : [group]

            groups.each do |individual_group|
              group_name = group_count = group_totals = nil

              if query.grouped?
                if first || individual_group != previous_group
                  # Handle a new group
                  group_name = if individual_group.blank? && individual_group != false
                    "(#{l(:label_blank_value)})"
                  else
                    format_object(individual_group, false).to_s
                  end
                  group_name ||= ""

                  group_count = result_count_by_group ? result_count_by_group[individual_group] : nil
                  group_totals = totals_by_group.map { |column, t| total_tag(column, t[individual_group] || 0) }

                  # Store in cache for reuse
                  group_cache[individual_group] = {
                    group_name: group_name,
                    group_count: group_count,
                    group_totals: group_totals
                  }

                  # Set previous group
                  previous_group = individual_group
                else
                  # Retrieve cached group details for subsequent items in the same group
                  cached_group = group_cache[individual_group]
                  group_name = cached_group[:group_name]
                  group_count = cached_group[:group_count]
                  group_totals = cached_group[:group_totals]
                end
              end

              # Ensure group_name is always set for grouped items
              group_name ||= previous_group.to_s

              # Yield the item and the group details for each individual group
              yield item, group_name, group_count, group_totals

              # Update first flag after the first iteration
              first = false
            end
          end
        end

        def total_tag(column, value)
          if [:hours, :spent_hours, :total_spent_hours, :estimated_hours, :total_estimated_hours].include? column.name
            format_hours(value)
          else
            format_object(value)
          end
        end
      end
    end
  end
end

QueriesHelper.send(:include, FridayPlugin::QueriesHelperPatch) unless QueriesHelper.included_modules.include?(FridayPlugin::QueriesHelperPatch)

require_dependency "issue_query"

module FridayPlugin
  module ProjectQueryPatch
    def self.included(base)
      base.class_eval do
        def joins_for_order_statement(order_options)
          joins = []

          if order_options
            order_options.scan(/cf_\d+/).uniq.each do |name|
              column = available_columns.detect { |c| c.name.to_s == name }
              join = column && column.custom_field.join_for_order_statement
              if join
                joins << join
              end
            end
          end

          joins.any? ? joins.join(" ") : nil
        end
      end
    end

    module InstanceMethods
    end
  end
end

ProjectQuery.send(:include, FridayPlugin::ProjectQueryPatch) unless ProjectQuery.included_modules.include?(FridayPlugin::ProjectQueryPatch)

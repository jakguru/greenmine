require_dependency "project_query"

module FridayPlugin
  module UserQueryPatch
    def self.included(base)
      base.class_eval do
        add_available_column(QueryColumn.new(:avatar))

        def default_columns_names
          @default_columns_names ||= [:avatar, :login, :firstname, :lastname, :mail, :admin, :created_on, :last_login_on]
        end
      end
    end

    module InstanceMethods
    end
  end
end

UserQuery.send(:include, FridayPlugin::UserQueryPatch) unless UserQuery.included_modules.include?(FridayPlugin::UserQueryPatch)

module FridayPlugin
  module TimelogControllerPatch
    def self.included(base)
      base.class_eval do
        base.send(:include, FridayHelper)
        alias_method :redmine_base_index, :index

        def index
          retrieve_time_entry_query
          scope = time_entry_scope
            .preload(issue: [:project, :tracker, :status, :assigned_to, :priority])
            .preload(:project, :user)
          if friday_request?
            render_query_response(@query, scope, TimeEntryQuery, @project, User.current, params, per_page_option)
          else
            redmine_base_index
          end
        end
      end
    end
  end
end

TimelogController.send(:include, FridayPlugin::TimelogControllerPatch) unless TimelogController.included_modules.include?(FridayPlugin::TimelogControllerPatch)

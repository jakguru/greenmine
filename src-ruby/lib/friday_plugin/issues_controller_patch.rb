module FridayPlugin
  module IssuesControllerPatch
    def self.included(base)
      base.class_eval do
        base.send(:include, FridayHelper)
        alias_method :redmine_base_index, :index

        def index
          use_session = false
          retrieve_default_query(use_session)
          retrieve_query(IssueQuery, use_session)
          if friday_request?
            if @project
              render_project_response({
                issues: query_response(@query, @query.base_scope, IssueQuery, @project, User.current, params, per_page_option)
              })
            else
              render_query_response(@query, @query.base_scope, IssueQuery, @project, User.current, params, per_page_option)
            end
          else
            redmine_base_index
          end
        end
      end
    end
  end
end

IssuesController.send(:include, FridayPlugin::IssuesControllerPatch) unless IssuesController.included_modules.include?(FridayPlugin::IssuesControllerPatch)

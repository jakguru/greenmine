module FridayPlugin
  module GanttsControllerPatch
    def self.included(base)
      base.class_eval do
        base.send(:include, FridayHelper)

        def show
          if friday_request?
            if @project
              render_project_response({
                gantt: gantt_response
              })
            else
              render json: gantt_response
            end
          else
            render_blank
          end
        end

        def gantt_response
          params[:display_type] = "gantt"
          use_session = false
          retrieve_default_query(use_session)
          retrieve_query(IssueQuery, use_session)
          @query.display_type = "gantt"
          query_response(@query, @query.base_scope, IssueQuery, @project, User.current, params, per_page_option)
        end

        def retrieve_default_query(use_session)
          return if params[:query_id].present?
          return if api_request?
          return if params[:set_filter]

          if params[:without_default].present?
            params[:set_filter] = 1
            return
          end
          if !params[:set_filter] && use_session && session[:issue_query]
            query_id, project_id = session[:issue_query].values_at(:id, :project_id)
            return if IssueQuery.where(id: query_id).exists? && project_id == @project&.id
          end
          if default_query = IssueQuery.default(project: @project)
            params[:query_id] = default_query.id
          end
        end
      end
    end
  end
end

GanttsController.send(:include, FridayPlugin::GanttsControllerPatch) unless GanttsController.included_modules.include?(FridayPlugin::GanttsControllerPatch)

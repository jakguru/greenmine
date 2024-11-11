module FridayPlugin
  module CustomFieldsControllerPatch
    def self.included(base)
      base.class_eval do
        base.send(:include, FridayHelper)
        alias_method :redmine_base_index, :index

        def index
          if friday_request?
            use_session = false
            retrieve_default_query(use_session)
            retrieve_query(CustomFieldQuery, use_session)
            render_query_response(@query, @query.base_scope, CustomFieldQuery, @project, User.current, params, per_page_option)
          else
            redmine_base_index
          end
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
            return if CustomFieldQuery.where(id: query_id).exists? && project_id == @project&.id
          end
          if default_query = CustomFieldQuery.default(project: @project)
            params[:query_id] = default_query.id
          end
        end
      end
    end
  end
end

CustomFieldsController.send(:include, FridayPlugin::CustomFieldsControllerPatch) unless CustomFieldsController.included_modules.include?(FridayPlugin::CustomFieldsControllerPatch)

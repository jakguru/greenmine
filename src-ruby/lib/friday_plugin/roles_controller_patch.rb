module FridayPlugin
  module RolesControllerPatch
    def self.included(base)
      base.class_eval do
        base.send(:include, FridayHelper)
        alias_method :redmine_base_index, :index
        alias_method :redmine_base_new, :new
        alias_method :redmine_base_create, :create
        alias_method :redmine_base_edit, :edit
        alias_method :redmine_base_update, :update
        alias_method :redmine_base_destroy, :destroy

        def index
          if friday_request?
            use_session = false
            retrieve_default_query(use_session)
            retrieve_query(RoleQuery, use_session)
            render_query_response(@query, @query.base_scope, RoleQuery, @project, User.current, params, per_page_option)
          else
            redmine_base_index
          end
        end

        def new
          if friday_request?
            render json: {
              formAuthenticityToken: form_authenticity_token,
              id: nil
            }
          else
            redmine_base_new
          end
        end

        def edit
          if friday_request?
            render json: {
              formAuthenticityToken: form_authenticity_token,
              id: @role.id
            }
          else
            redmine_base_edit
          end
        end

        def create
          if friday_request?
            render json: {}, status: 418
          else
            redmine_base_create
          end
        end

        def update
          if friday_request?
            render json: {}, status: 418
          else
            redmine_base_update
          end
        end

        def destroy
          if friday_request?
            if @role.builtin?
              render json: {errors: l(:error_can_not_delete_builtin_role)}, status: 403
            elsif @role.destroy
              render json: {}
            else
              render json: {errors: @role.errors.full_messages}, status: 400
            end
          else
            redmine_base_destroy
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
            return if RoleQuery.where(id: query_id).exists? && project_id == @project&.id
          end
          if (default_query = RoleQuery.default(project: @project))
            params[:query_id] = default_query.id
          end
        end
      end
    end
  end
end

RolesController.send(:include, FridayPlugin::RolesControllerPatch) unless RolesController.included_modules.include?(FridayPlugin::RolesControllerPatch)

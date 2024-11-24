module FridayPlugin
  module GroupsControllerPatch
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
            retrieve_query(GroupQuery, use_session)
            render_query_response(@query, @query.base_scope, GroupQuery, @project, User.current, params, per_page_option)
          else
            redmine_base_index
          end
        end

        def new
          if friday_request?
            @group = Group.new
            render_model_response
          else
            redmine_base_new
          end
        end

        def edit
          if friday_request?
            render_model_response
          else
            redmine_base_edit
          end
        end

        def create
          if friday_request?
            @group = Group.new
            @group.safe_attributes = params[:group]
            if @group.save
              enqueue_realtime_updates
              render json: {
                id: @group.id
              }, status: 201
            else
              render json: {errors: @group.errors.full_messages}, status: 422
            end
          else
            redmine_base_create
          end
        end

        def update
          if friday_request?
            @group.safe_attributes = params[:group]
            if @group.save
              enqueue_realtime_updates
              render json: {
                id: @group.id
              }, status: 201
            else
              render json: {errors: @group.errors.full_messages}, status: 422
            end
          else
            redmine_base_update
          end
        end

        def destroy
          if friday_request?
            if @group.builtin?
              render json: {errors: l(:error_can_not_delete_builtin_group)}, status: 403
            elsif @group.destroy
              enqueue_realtime_updates
              render json: {}
            else
              render json: {errors: @group.errors.full_messages}, status: 400
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
            return if GroupQuery.where(id: query_id).exists? && project_id == @project&.id
          end
          if (default_query = GroupQuery.default(project: @project))
            params[:query_id] = default_query.id
          end
        end

        def render_model_response
          render json: {
            formAuthenticityToken: form_authenticity_token,
            id: @group.new_record? ? nil : @group.id,
            model: @group.attributes.merge({}),
            values: {}
          }
        end

        def enqueue_realtime_updates
          ActionCable.server.broadcast("rtu_application", {updated: true})
          ActionCable.server.broadcast("rtu_groups", {updated: true})
        end
      end
    end
  end
end

GroupsController.send(:include, FridayPlugin::GroupsControllerPatch) unless GroupsController.included_modules.include?(FridayPlugin::GroupsControllerPatch)

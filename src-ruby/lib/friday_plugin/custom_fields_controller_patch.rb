module FridayPlugin
  module CustomFieldsControllerPatch
    def self.included(base)
      base.class_eval do
        base.send(:include, FridayHelper)
        base.send(:include, FridayCustomFieldHelper)
        alias_method :redmine_base_index, :index
        alias_method :redmine_base_new, :new
        alias_method :redmine_base_create, :create
        alias_method :redmine_base_edit, :edit
        alias_method :redmine_base_update, :update
        alias_method :redmine_base_destroy, :destroy
        alias_method :redmine_base_build_new_custom_field, :build_new_custom_field

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

        def new
          if friday_request?
            render json: {
              formAuthenticityToken: form_authenticity_token,
              id: nil,
              type: params[:type],
              types: custom_field_types.map { |k, v| {value: k.to_s, label: v} },
              formsByType: custom_field_type_forms,
              formsByFormat: custom_field_format_forms,
              formByTypeAndFormat: custom_field_type_field_format_forms
            }
          else
            redmine_base_new
          end
        end

        def create
          if friday_request?
            render json: {}
          else
            redmine_base_create
          end
        end

        def edit
          if friday_request?
            render json: {
              formAuthenticityToken: form_authenticity_token,
              id: @custom_field.id,
              type: @custom_field.type,
              types: custom_field_types.map { |k, v| {value: k.to_s, label: v} },
              formsByType: custom_field_type_forms,
              formsByFormat: custom_field_format_forms,
              formByTypeAndFormat: custom_field_type_field_format_forms
            }
          else
            redmine_base_edit
          end
        end

        def update
          if friday_request?
            render json: {}
          else
            redmine_base_update
          end
        end

        def destroy
          if friday_request?
            render json: {}
          else
            redmine_base_destroy
          end
        end

        def build_new_custom_field
          if friday_request?
            @custom_field = CustomField.new
            if params[:copy].present? && (@copy_from = CustomField.find_by(id: params[:copy]))
              @custom_field.copy_from(@copy_from)
            end
            @custom_field.safe_attributes = params[:custom_field]
          else
            redmine_base_build_new_custom_field
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

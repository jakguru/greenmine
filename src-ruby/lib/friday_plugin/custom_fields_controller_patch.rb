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
              formByTypeAndFormat: custom_field_type_field_format_forms,
              enumerations: []
            }
          else
            redmine_base_new
          end
        end

        def create
          if friday_request?
            @custom_field = CustomField.new
            @custom_field.type = params[:type]
            @custom_field.safe_attributes = params[:custom_field]
            if @custom_field.save
              render json: {
                id: @custom_field.id
              }, status: 201
            else
              render json: {errors: @custom_field.errors.full_messages}, status: 422
            end
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
              formByTypeAndFormat: custom_field_type_field_format_forms,
              enumerations: @custom_field.enumerations.collect { |v| {id: v.id, name: v.name, is_default: nil, position: v.position, active: v.active} }
            }
          else
            redmine_base_edit
          end
        end

        def update
          if friday_request?
            @custom_field.safe_attributes = params[:custom_field]
            if @custom_field.save
              render json: {
                id: @custom_field.id
              }, status: 201
            else
              render json: {errors: @custom_field.errors.full_messages}, status: 422
            end
          else
            redmine_base_update
          end
        end

        def destroy
          if friday_request?
            if @custom_field.destroy
              render json: {}
            else
              render json: {errors: @custom_field.errors.full_messages}, status: 400
            end
          else
            redmine_base_destroy
          end
        end

        def update_enumeration
          find_custom_field
          find_enumeration
          old_position = @value.position
          if @value.update(enumeration_params)
            enqueue_realtime_updates
            if old_position != @value.position
              @custom_field.enumerations.each do |enumeration|
                if enumeration.id != @value.id && enumeration.position >= @value.position && enumeration.position <= old_position
                  enumeration.update(position: enumeration.position + 1)
                elsif enumeration.id != @value.id && enumeration.position <= @value.position && enumeration.position >= old_position
                  enumeration.update(position: enumeration.position - 1)
                end
              end
            end
            render json: @value
          else
            render json: {errors: @value.errors.full_messages}, status: :unprocessable_entity
          end
        end

        def create_enumeration
          find_custom_field
          @value = @custom_field.enumerations.build
          @value.attributes = enumeration_params
          if @value.save
            enqueue_realtime_updates
            fix_custom_field_enumeration_positions
            render json: @value
          else
            render json: {errors: @value.errors.full_messages}, status: 400
          end
        end

        def destroy_enumeration
          find_custom_field
          find_enumeration
          if !@value.in_use?
            # No associated objects
            @value.destroy
            if @custom_field.default_value.to_s == @value.id.to_s
              @custom_field.update(default_value: nil)
            end
            enqueue_realtime_updates
            fix_custom_field_enumeration_positions
            render json: {}, status: 200
            return
          elsif params[:reassign_to_id].present? && (reassign_to = @value.class.find_by_id(params[:reassign_to_id].to_i))
            @value.destroy(reassign_to)
            enqueue_realtime_updates
            fix_custom_field_enumeration_positions
            render json: {}, status: 401
            return
          end
          @enumerations = @custom_field.enumerations - [@value]
          if @custom_field.default_value.to_s == @value.id.to_s
            @custom_field.update(default_value: nil)
          end
          fix_custom_field_enumeration_positions
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
          if (default_query = CustomFieldQuery.default(project: @project))
            params[:query_id] = default_query.id
          end
        end

        private

        def find_enumeration
          @value = @custom_field.enumerations.find(params[:enumeration_id])
        rescue ActiveRecord::RecordNotFound
          render_404
        end

        def enumeration_params
          params.require(:custom_field_enumeration).permit(:name, :active, :position)
        end

        def enqueue_realtime_updates
          ActionCable.server.broadcast("rtu_application", {updated: true})
          ActionCable.server.broadcast("rtu_enumerations", {updated: true})
        end

        def fix_custom_field_enumeration_positions
          @custom_field.enumerations.order(position: :asc).each_with_index do |enumeration, index|
            enumeration.update(position: index + 1)
          end
        end
      end
    end
  end
end

CustomFieldsController.send(:include, FridayPlugin::CustomFieldsControllerPatch) unless CustomFieldsController.included_modules.include?(FridayPlugin::CustomFieldsControllerPatch)

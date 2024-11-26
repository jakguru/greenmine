module FridayPlugin
  module UsersControllerPatch
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
            retrieve_query(UserQuery, use_session)
            render_query_response(@query, @query.base_scope, UserQuery, @project, User.current, params, per_page_option)
          else
            redmine_base_index
          end
        end

        def new
          if friday_request?
            @user = User.new
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
            @user = User.new
            @user.safe_attributes = params[:user]
            if params[:user][:avatar].present?
              @user.avatar = process_avatar(params[:user][:avatar])
            end
            users = User.where(id: params[:user][:users]).to_a
            @user.users = users
            if @user.save
              syncronize_user_memberships(@user, params[:user][:memberships])
              enqueue_realtime_updates
              render json: {
                id: @user.id
              }, status: 201
            else
              render json: {errors: @user.errors.full_messages}, status: 422
            end
          else
            redmine_base_create
          end
        end

        def update
          if friday_request?
            @user.safe_attributes = params[:user]
            if params[:user][:avatar].present?
              @user.avatar = process_avatar(params[:user][:avatar])
            end
            users = User.where(id: params[:user][:users]).to_a
            @user.users = users
            if @user.save
              syncronize_user_memberships(@user, params[:user][:memberships])
              enqueue_realtime_updates
              render json: {
                id: @user.id
              }, status: 201
            else
              render json: {errors: @user.errors.full_messages}, status: 422
            end
          else
            redmine_base_update
          end
        end

        def destroy
          if friday_request?
            if @user.builtin?
              render json: {errors: l(:error_can_not_delete_builtin_user)}, status: 403
            elsif @user.destroy
              enqueue_realtime_updates
              render json: {}
            else
              render json: {errors: @user.errors.full_messages}, status: 400
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
            return if UserQuery.where(id: query_id).exists? && project_id == @project&.id
          end
          if (default_query = UserQuery.default(project: @project))
            params[:query_id] = default_query.id
          end
        end

        def render_model_response
          @principal = @user.new_record? ? Principal.new : Principal.find(@user.id)
          render json: {
            formAuthenticityToken: form_authenticity_token,
            id: @user.new_record? ? nil : @user.id,
            model: @user.attributes.merge({
              name: @user.name,
              users: @user.users.collect(&:id),
              memberships: @principal.memberships.preload(:member_roles, :roles).sorted_by_project.collect { |membership|
                {
                  project: membership.project_id,
                  roles: membership.roles.sort.collect(&:id)
                }
              }
            }),
            values: {
              roles: Role.givable.collect { |role|
                {
                  value: role.id,
                  label: role.name
                }
              },
              projects: get_project_nested_items(Project.all),
              users: User.active.sorted.collect { |user|
                {
                  value: user.id,
                  label: user.name
                }
              }
            }
          }
        end

        def enqueue_realtime_updates
          ActionCable.server.broadcast("rtu_application", {updated: true})
          ActionCable.server.broadcast("rtu_users", {updated: true})
        end

        def get_project_nested_items(projects)
          result = []
          if projects.any?
            ancestors = []
            projects.sort_by(&:lft).each do |project|
              # Remove ancestors that are no longer part of the current project's hierarchy
              while ancestors.any? && !project.is_descendant_of?(ancestors.last)
                ancestors.pop
              end

              # Create label with '>' symbols to indicate depth level
              depth_indicator = ">" * ancestors.size
              label = "#{depth_indicator} #{project.name}".strip

              # Add the project to the result array as a hash with value and label
              result << {value: project.id, label: label}

              # Add the current project to ancestors stack
              ancestors << project
            end
          end
          result
        end

        def syncronize_user_memberships(user, memberships)
          principal = Principal.find(@user.id)
          existing_memberships = principal.memberships.preload(:member_roles, :roles).sorted_by_project
          # Remove existing memberships that are not in the new list
          existing_memberships.each do |existing_membership|
            if !memberships.any? { |membership| membership[:project] == existing_membership.project_id }
              existing_membership.destroy
            end
          end
          # Add new memberships that are not in the existing list
          # or update existing memberships with new roles
          memberships.each do |membership|
            if !existing_memberships.any? { |existing_membership| existing_membership.project_id == membership[:project] }
              Member.create_principal_memberships(principal, {
                project_ids: [membership[:project]],
                role_ids: membership[:roles]
              })
            else
              existing_membership = existing_memberships.find { |existing_membership| existing_membership.project_id == membership[:project] }
              existing_membership.role_ids = membership[:roles]
              existing_membership.save
            end
          end
        end

        def process_avatar(base64_image)
          # Decode the base64 image
          image_data = Base64.decode64(base64_image.sub(/^data:image\/\w+;base64,/, ""))

          # Create a Tempfile to store the image
          temp_image = Tempfile.new(["avatar", ".png"])
          temp_image.binmode
          temp_image.write(image_data)
          temp_image.rewind

          # Use MiniMagick to process the image
          image = MiniMagick::Image.new(temp_image.path)
          image.resize "200x200>"

          # Return the modified image as a base64 string
          output = Tempfile.new(["avatar_processed", ".png"])
          image.write(output.path)
          output.rewind
          base64_output = Base64.strict_encode64(output.read)

          # Clean up temp files
          temp_image.close
          temp_image.unlink
          output.close
          output.unlink

          # Return the base64 representation with the correct prefix
          "data:image/png;base64,#{base64_output}"
        end
      end
    end
  end
end

UsersController.send(:include, FridayPlugin::UsersControllerPatch) unless UsersController.included_modules.include?(FridayPlugin::UsersControllerPatch)

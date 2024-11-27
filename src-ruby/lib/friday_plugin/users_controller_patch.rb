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
            render html: "", layout: true
          end
        end

        def edit
          if friday_request?
            render_model_response
          else
            render html: "", layout: true
          end
        end

        def create
          if friday_request?
            @user = User.new(language: Setting.default_language,
              mail_notification: Setting.default_notification_option,
              admin: false)
            render_save_response
          else
            redmine_base_create
          end
        end

        def update
          if friday_request?
            render_save_response
          else
            redmine_base_update
          end
        end

        def destroy
          if friday_request?
            if @user.destroy
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
              groups: @user.groups.collect(&:id),
              memberships: @principal.memberships.preload(:member_roles, :roles).sorted_by_project.collect { |membership|
                {
                  project: membership.project_id,
                  roles: membership.roles.sort.collect(&:id)
                }
              },
              mails: @user.mails,
              hide_mail: @user.pref[:hide_mail],
              time_zone: @user.pref[:time_zone],
              no_self_notified: @user.pref[:no_self_notified],
              auto_watch_on: @user.pref[:auto_watch_on].reject(&:blank?),
              my_page_layout: @user.pref[:my_page_layout],
              my_page_settings: @user.pref[:my_page_settings],
              recently_used_project_ids: @user.pref[:recently_used_project_ids],
              gantt_zoom: @user.pref[:gantt_zoom],
              gantt_months: @user.pref[:gantt_months],
              notify_about_high_priority_issues: @user.pref[:notify_about_high_priority_issues],
              comments_sorting: @user.pref.comments_sorting,
              warn_on_leaving_unsaved: @user.pref[:warn_on_leaving_unsaved],
              textarea_font: @user.pref[:textarea_font],
              recently_used_projects: @user.pref[:recently_used_projects],
              history_default_tab: @user.pref[:history_default_tab],
              toolbar_language_options: @user.pref[:toolbar_language_options],
              default_issue_query: @user.pref[:default_issue_query],
              default_project_query: @user.pref[:default_project_query]
            }),
            values: {
              roles: Role.givable.collect { |role|
                {
                  value: role.id,
                  label: role.name
                }
              },
              projects: get_project_nested_items(Project.all),
              groups: Group.active.sorted.collect { |group|
                {
                  value: group.id,
                  label: group.name
                }
              },
              mailNotificationOptions: @user.valid_notification_options.collect { |v|
                {
                  value: v.first,
                  label: l(v.last)
                }
              },
              timezones: ActiveSupport::TimeZone.all.collect { |tz| {value: tz.name, label: tz.to_s} } << {value: "", label: l(:label_none)},
              languages: ::I18n.backend.available_locales.map { |locale| {value: locale.to_s, label: "languages.#{locale}"} }.sort_by(&:first),
              commmentsSortingOptions: [
                {value: "asc", label: l(:label_chronological_order)},
                {value: "desc", label: l(:label_reverse_chronological_order)}
              ],
              historyDefaultTabOptions: history_default_tab_options.collect { |v|
                {
                  value: v.last,
                  label: v.first
                }
              },
              defaultIssueQueryOptions: [{value: nil, label: l(:label_none)}] + issue_query_options(@user),
              defaultProjectQueryOptions: [{value: nil, label: l(:label_none)}] + project_query_options(@user),
              userStatusOptions: (@user.status == User::STATUS_REGISTERED) ? [
                {value: User::STATUS_ACTIVE, label: l(:label_active)},
                {value: User::STATUS_LOCKED, label: l(:label_locked)},
                {value: User::STATUS_REGISTERED, label: l(:label_registered)}
              ] : [
                {value: User::STATUS_ACTIVE, label: l(:label_active)},
                {value: User::STATUS_LOCKED, label: l(:label_locked)}
              ],
              passwordMinLength: Setting.send(:password_min_length),
              passwordRequiredCharClasses: Setting.send(:password_required_char_classes),
              emailDomainsAllowed: Setting.send(:email_domains_allowed),
              emailDomainsDenied: Setting.send(:email_domains_denied)
            }
          }
        end

        def render_save_response
          @user.safe_attributes = params[:user]
          @user.pref.safe_attributes = params[:user]
          if params[:user][:mails].present?
            @user.mail = params[:user][:mails].first
          end
          if params[:user].key?(:avatar)
            @user.avatar = params[:user][:avatar].present? ? process_avatar(params[:user][:avatar]) : nil
          end
          if params[:user].key?(:groups)
            @user.groups = if params[:user][:groups].empty?
              []
            else
              Group.where(id: params[:user][:groups])
            end
          end
          if @user.save && @user.pref.save
            Mailer.deliver_account_information(@user, params[:user][:password]) if params[:send_information] && params[:user][:password].present?
            if params[:user][:memberships].present?
              syncronize_user_memberships(@user, params[:user][:memberships])
            end
            if params[:user][:mails].present?
              syncronize_user_email_addresses(@user, params[:user][:mails])
            end
            enqueue_realtime_updates
            render json: {
              id: @user.id
            }, status: 201
          else
            render json: {errors: @user.errors.full_messages + @user.pref.errors.full_messages}, status: 422
          end
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

        def syncronize_user_email_addresses(user, list_of_final_addresses)
          existing = user.email_addresses
          existing_addresses = existing.map(&:address)
          to_add = list_of_final_addresses.reject { |email| existing_addresses.include?(email) }
          to_remove = existing.reject { |email| list_of_final_addresses.include?(email.address) }
          to_add.each do |email|
            address = EmailAddress.new(user: user, is_default: false, address: email)
            address.save
          end
          to_remove.each do |address|
            address&.destroy
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

        def issue_query_options(user)
          global_queries = IssueQuery.for_all_projects
          global_public_queries = global_queries.only_public
          global_user_queries = global_queries.where(user_id: user.id).where.not(id: global_public_queries.pluck(:id))
          grouped_options_for_select([global_public_queries, global_user_queries])
        end

        def project_query_options(user)
          global_queries = ProjectQuery
          global_public_queries = global_queries.only_public
          global_user_queries = global_queries.where(user_id: user.id).where.not(id: global_public_queries.ids)
          grouped_options_for_select([global_public_queries, global_user_queries])
        end

        def grouped_options_for_select(collections)
          array = []
          collections.each do |collection|
            collection.pluck(:name, :id).each do |item|
              array << {value: item[1], label: item[0]}
            end
          end
          array
        end
      end
    end
  end
end

UsersController.send(:include, FridayPlugin::UsersControllerPatch) unless UsersController.included_modules.include?(FridayPlugin::UsersControllerPatch)

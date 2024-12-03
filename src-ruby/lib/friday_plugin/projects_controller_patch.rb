module FridayPlugin
  module ProjectsControllerPatch
    def self.included(base)
      base.class_eval do
        base.send(:include, ProjectsHelper)
        base.send(:include, FridayHelper)
        alias_method :redmine_base_index, :index
        alias_method :redmine_base_new, :new
        alias_method :redmine_base_show, :show
        alias_method :redmine_base_settings, :settings
        alias_method :redmine_base_create, :create
        alias_method :redmine_base_update, :update

        def index
          retrieve_default_query
          retrieve_project_query
          scope = project_scope
          @query.options[:display_type] = "list"
          if friday_request?
            render_query_response(@query, scope, ProjectQuery, @project, User.current, params, per_page_option)
          else
            redmine_base_index
          end
        end

        def new
          if friday_request?
            @project = Project.new
            @project.safe_attributes = params[:project]
            render_project_response
          else
            redmine_base_new
          end
        end

        def show
          if friday_request?
            principals_by_role = @project.principals_by_role
            subprojects = @project.children.visible.to_a
            news = @project.news.limit(5).includes(:author, :project).reorder("#{News.table_name}.created_on DESC").to_a
            with_subprojects = Setting.display_subprojects_issues?
            trackers = @project.rolled_up_trackers(with_subprojects).visible
            cond = @project.project_condition(with_subprojects)
            open_issues_by_tracker = Issue.visible.open.where(cond).group(:tracker).count
            total_issues_by_tracker = Issue.visible.where(cond).group(:tracker).count
            total_hours = nil
            total_estimated_hours = nil
            if User.current.allowed_to_view_all_time_entries?(@project)
              total_hours = TimeEntry.visible.where(cond).sum(:hours).to_f
              total_estimated_hours = Issue.visible.where(cond).sum(:estimated_hours).to_f
            end
            gitlab_projects = @project.gitlab_projects
            parents = []
            project = @project
            while project.parent
              parents << project.parent
              project = project.parent
            end

            render_project_response({
              principalsByRole: principals_by_role,
              subprojects: subprojects,
              news: news,
              trackers: trackers,
              openIssuesByTracker: open_issues_by_tracker,
              totalIssuesByTracker: total_issues_by_tracker,
              totalHours: total_hours,
              totalEstimatedHours: total_estimated_hours,
              gitlabProjects: gitlab_projects,
              parents: parents.reverse
            })
          else
            redmine_base_show
          end
        end

        def settings
          if friday_request?
            render_project_response
          else
            redmine_base_settings
          end
        end

        def create
          if friday_request?
            @project = Project.new
            render_project_save_response(true)
          else
            redmine_base_create
          end
        end

        def update
          if friday_request?
            render_project_save_response
          else
            redmine_base_update
          end
        end

        def render_project_response(additional = {})
          custom_field_values = {}
          @project.visible_custom_field_values.each do |cfv|
            id = cfv.custom_field.id
            custom_field_values[id] = cfv.value
          end
          users = User.all.map { |user|
            {
              value: user.id,
              label: user.name,
              kind: "user"
            }
          }
          groups = Group.all.map { |group|
            {
              value: group.id,
              label: group.name,
              kind: "group"
            }
          }
          assignees = get_project_default_assigned_to_options(@project)
          versions = get_project_default_version_options(@project)
          eumerations = {}
          @project.activities(true).each do |activity|
            eumerations[activity.id] = {
              custom_field_values: {},
              active: activity.active
            }
            activity.custom_field_values.each do |cfv|
              eumerations[activity.id][:custom_field_values][cfv.custom_field.id] = cfv.value
            end
          end
          render json: {
            formAuthenticityToken: form_authenticity_token,
            id: @project.new_record? ? nil : @project.id,
            model: @project.attributes.merge({
              custom_field_values: custom_field_values,
              enabled_module_names: @project.enabled_module_names,
              tracker_ids: @project.trackers.map(&:id),
              issue_custom_field_ids: @project.all_issue_custom_fields.ids,
              gitlab_projects: @project.gitlab_projects(&:id),
              eumerations: eumerations,
              description: @project.description.nil? ? "" : @project.description
            }),
            members: @project.members.map { |member|
              {
                id: member.id,
                roles: member.roles.map(&:id)
              }
            },
            issueCategories: @project.issue_categories,
            versions: versions,
            repositories: @project.repositories,
            customFields: @project.visible_custom_field_values.map(&:custom_field).map { |cf|
              case cf.field_format
              when "user"
                cf.attributes.merge({
                  enumerations: get_enumerations_for_project_custom_user_field(cf)
                })
              when "version"
                cf.attributes.merge({
                  enumerations: get_enumerations_for_project_custom_versions_field(cf)
                })
              else
                cf.attributes.merge({
                  enumerations: cf.enumerations.collect { |v| {id: v.id, name: v.name, is_default: nil, position: v.position, active: v.active} }
                })
              end
            },
            values: {
              identifierMaxLength: Project::IDENTIFIER_MAX_LENGTH,
              members: users + groups,
              modules: Redmine::AccessControl.available_project_modules.map { |module_name|
                {
                  value: module_name,
                  label: l_or_humanize(module_name, prefix: "project_module_")
                }
              },
              trackers: Tracker.sorted.preload(:default_status).map { |tracker|
                {
                  id: tracker.id,
                  name: tracker.name
                }
              },
              activities: @project.activities(true).map { |activity|
                {
                  id: activity.id,
                  name: activity.name,
                  is_system: !activity.project
                }
              },
              versions: versions.map { |version|
                {
                  value: version.id,
                  label: version.name
                }
              },
              assignees: assignees,
              queries: get_project_default_issue_query_options(@project),
              gitlabProjects: GitlabProject.preload(:gitlab_instance).map { |gitlab_project|
                {
                  id: gitlab_project.id,
                  name: gitlab_project.name,
                  web_url: gitlab_project.web_url,
                  gitlab: gitlab_project.gitlab_instance.name
                }
              },
              parents: @project.allowed_parents.compact.map { |project|
                {
                  value: project.id,
                  label: project.name
                }
              },
              issueCustomFields: IssueCustomField.sorted.to_a,
              statuses: [
                {value: Project::STATUS_ACTIVE, color: "success", icon: "mdi-folder-play", label: l(:label_status_active)},
                {value: Project::STATUS_CLOSED, color: "info", icon: "mdi-folder", label: l(:label_status_closed)},
                {value: Project::STATUS_ARCHIVED, color: "warning", icon: "mdi-folder-lock", label: l(:label_status_archived)},
                {value: Project::STATUS_SCHEDULED_FOR_DELETION, color: "error", icon: "mdi-folder-remove", label: l(:label_status_scheduled_for_deletion), disabled: true}
              ],
              roles: Role.givable.map { |role|
                {
                  value: role.id,
                  label: role.name,
                  assignable: role.assignable,
                  external: role.is_external
                }
              }
            },
            permissions: {
              add_project: User.current.allowed_to?(:add_project, @project),
              edit_project: User.current.allowed_to?(:edit_project, @project),
              close_project: User.current.allowed_to?(:close_project, @project),
              delete_project: User.current.allowed_to?(:delete_project, @project),
              select_project_publicity: User.current.allowed_to?(:select_project_publicity, @project),
              select_project_modules: User.current.allowed_to?(:select_project_modules, @project),
              manage_members: User.current.allowed_to?(:manage_members, @project),
              manage_versions: User.current.allowed_to?(:manage_versions, @project),
              add_subprojects: User.current.allowed_to?(:add_subprojects, @project),
              manage_public_queries: User.current.allowed_to?(:manage_public_queries, @project),
              save_queries: User.current.allowed_to?(:save_queries, @project),
              view_associated_gitlab_projects: User.current.allowed_to?(:view_associated_gitlab_projects, @project),
              manage_associated_gitlab_projects: User.current.allowed_to?(:manage_associated_gitlab_projects, @project)
            }
          }.merge(additional)
        end

        def render_project_save_response(creating = false)
          @project.safe_attributes = params[:project]
          if @project.save
            if creating && !User.current.admin?
              @project.add_default_member(User.current)
            end
            render json: {
              id: @project.id,
              identifier: @project.identifier
            }, status: :created
          else
            render json: {
              errors: @project.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        def get_project_default_version_options(project)
          versions = project.shared_versions.open.to_a
          if project.default_version && !versions.include?(project.default_version)
            versions << project.default_version
          end
          versions
        end

        def get_project_default_assigned_to_options(project)
          results = (project.assignable_users.to_a + [project.default_assigned_to]).uniq.compact
          results.map { |user|
            {
              value: user.id,
              label: user.name
            }
          }
        end

        def get_project_default_issue_query_options(project)
          public_queries = IssueQuery.only_public
          options = []
          public_queries.where(project_id: nil).pluck(:name, :id).each do |name, id|
            options << {value: id, label: name}
          end
          public_queries.where(project: project).pluck(:name, :id).each do |name, id|
            options << {value: id, label: name}
          end
          options
        end

        def get_enumerations_for_project_custom_user_field(custom_field)
          enumerations = @project.members
          if custom_field[:format_store][:user_role].present?
            enumerations = enumerations.select { |member| member.roles.any? { |role| role.id == custom_field[:format_store][:user_role].to_i } }
          end
          enumerations.map { |member|
            {
              id: member.id,
              name: member.name,
              is_default: false,
              position: 1,
              active: true
            }
          }
        end

        def get_enumerations_for_project_custom_versions_field(custom_field)
          enumerations = @project.shared_versions
          if custom_field[:format_store][:version_status].present?
            enumerations = enumerations.select { |version| version.status == custom_field[:format_store][:version_status] }
          end
          enumerations.map { |version|
            {
              id: version.id,
              name: version.name,
              is_default: false,
              position: 1,
              active: true
            }
          }
        end
      end
    end
  end
end

ProjectsController.send(:include, FridayPlugin::ProjectsControllerPatch) unless ProjectsController.included_modules.include?(FridayPlugin::ProjectsControllerPatch)

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

        accept_api_auth :get_chart_for_issues_by_status, :get_chart_for_issues_by_tracker, :get_chart_for_activity_summary, :get_chart_for_time_summary

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
            principals_by_role = @project.principals_by_role.map { |role, principals|
              principals = principals.map { |principal|
                principal.attributes.merge({
                  type: principal.class.name.underscore.downcase,
                  name: principal.name
                })
              }
              {
                role: role,
                principals: principals
              }
            }
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
            gitlab_projects = @project.gitlab_projects.preload(:gitlab_instance).map { |gitlab_project|
              gitlab_project.attributes.merge({
                id: gitlab_project.id,
                name: gitlab_project.name,
                web_url: gitlab_project.web_url,
                gitlab: gitlab_project.gitlab_instance.name
              })
            }
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
            show
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

        def get_chart_for_activity_summary
          if friday_request?
            date_from = params[:from].present? ? params[:from].to_date : 10.days.ago.to_date
            date_to = params[:to].present? ? params[:to].to_date : Date.today.to_date
            activity = Redmine::Activity::Fetcher.new(User.current, project: @project,
              with_subprojects: true,
              author: nil)
            events = activity.events(date_from, date_to)
            events_by_day = events.group_by { |event| User.current.time_to_date(event.event_datetime) }
            activities_by_date = []
            events_by_day.each do |date, events|
              activities_by_date << [date.strftime("%Y-%m-%d"), events.size]
            end
            max_events_by_day = activities_by_date.map { |activity| activity[1] }.max
            render json: {
              series: {
                type: "heatmap",
                coordinateSystem: "calendar",
                data: activities_by_date
              },
              visualMap: {
                show: false,
                min: 0,
                max: max_events_by_day,
                inRange: {
                  color: ["#5291FF", "#C7DBFF"]
                },
                outOfRange: {
                  opacity: 0
                }
              }
            }, status: 200
          else
            render json: {}, status: :not_found
          end
        end

        def get_chart_for_issues_by_tracker
          if friday_request?
            date_from = params[:from].present? ? params[:from].to_date : 10.days.ago.to_date
            date_to = params[:to].present? ? params[:to].to_date : Date.today.to_date

            # Get all issues relevant for the time window.
            issues = @project.issues.includes(:tracker)
              .where("issues.created_on <= ?", date_to)
              .where("issues.closed_on IS NULL OR issues.closed_on >= ?", date_from)

            # Group issues by tracker
            issues_by_tracker = issues.group_by(&:tracker)

            data = []

            # Collect a unique list of tracker names
            trackers = issues_by_tracker.keys.map(&:name)

            # For each day and each tracker, determine how many issues are open
            (date_from..date_to).each do |day|
              issues_by_tracker.each do |tracker, tracker_issues|
                open_count = tracker_issues.count do |issue|
                  issue_created = issue.created_on.to_date
                  issue_closed = issue.closed_on&.to_date
                  issue_created <= day && (issue_closed.nil? || issue_closed >= day)
                end
                # Always push data, even if open_count is zero
                data << [day.strftime("%Y-%m-%d"), open_count, tracker.name]
              end
            end

            # Fetch colors for trackers or use a default
            colors = trackers.map do |tracker_name|
              Tracker.find_by(name: tracker_name).try(:color) || "#00854d"
            end

            render json: {
              legend: {
                data: trackers
              },
              series: [
                {
                  type: "themeRiver",
                  color: colors,
                  emphasis: {
                    itemStyle: {
                      shadowBlur: 20,
                      shadowColor: "rgba(0, 0, 0, 0.8)"
                    }
                  },
                  data: data
                }
              ]
            }, status: 200
          else
            render json: {}, status: :not_found
          end
        end

        def get_chart_for_issues_by_status
          if friday_request?
            date_from = params[:from].present? ? params[:from].to_date : 10.days.ago.to_date
            date_to = params[:to].present? ? params[:to].to_date : Date.today.to_date

            issues = @project.issues
              .includes(:status, journals: :details)
              .where("issues.created_on <= ?", date_to)
              .where("issues.closed_on IS NULL OR issues.closed_on >= ?", date_from)

            # We'll gather data as [day, count, status_name]
            data = []

            # We'll need a set of all statuses that appear over time. We'll discover them dynamically.
            all_status_names = Set.new

            # Preprocessing: Build a status timeline for each issue
            # Each timeline will map a date (or datetime) to a status_id that started on or after that date
            # We will use a list of [change_datetime, status_id] sorted chronologically,
            # starting with the initial status at issue creation.
            issue_timelines = {}

            # Pre-load statuses to avoid repeated lookups
            status_map = IssueStatus.all.index_by(&:id)

            issues.each do |issue|
              # Start from the issue's initial status and creation date
              timeline = []
              timeline << [issue.created_on, issue.status_id]

              # Extract all status changes
              status_changes = issue.journals.flat_map(&:details).select do |d|
                d.property == "attr" && d.prop_key == "status_id"
              end

              # Sort changes by their journal created_on time
              # Note: journal_details don't have their own created_on, they share journal's created_on
              status_changes = status_changes.sort_by { |d| d.journal.created_on }

              status_changes.each do |change|
                new_status_id = change.value.to_i
                change_time = change.journal.created_on
                timeline << [change_time, new_status_id]
              end

              issue_timelines[issue.id] = timeline
            end

            # Now we generate day-by-day data
            (date_from..date_to).each do |day|
              # Count how many issues are in each status on this day
              daily_status_counts = Hash.new(0)

              issues.each do |issue|
                # If the issue isn't created yet on this day, skip
                next if issue.created_on.to_date > day

                # If the issue was closed before this day, skip
                # If it was closed exactly on this day, it should appear as "Closed"
                if issue.closed_on
                  closed_day = issue.closed_on.to_date
                  if day > closed_day
                    # After closed day, do not show this issue at all
                    next
                  end
                end

                timeline = issue_timelines[issue.id]

                # Find the latest status applicable for this day
                # timeline is sorted by date
                current_status_id = nil
                timeline.each do |(change_time, status_id)|
                  if change_time.to_date <= day
                    current_status_id = status_id
                  else
                    break
                  end
                end

                # current_status_id now is the status on this day
                # If the issue is closed on this day, show "Closed"
                # Else, show the actual status name
                if issue.closed_on && issue.closed_on.to_date == day
                  status_name = "Closed"
                else
                  # Normal day (not closed day)
                  current_status = status_map[current_status_id]
                  status_name = current_status.name
                end

                daily_status_counts[status_name] += 1
                all_status_names << status_name
              end

              # Back-fill for all known statuses
              # If you want every status to appear even if zero, uncomment below:
              # But here, we only have statuses that actually appear at some point.
              all_status_names.each do |status_name|
                count = daily_status_counts[status_name] || 0
                data << [day.strftime("%Y-%m-%d"), count, status_name]
              end
            end

            # Convert all_status_names to an array to preserve some order (sort alphabetically if desired)
            statuses = all_status_names.to_a.sort

            # Assign a color for each status (you can customize this mapping)
            # status_colors = statuses.map { "#00854d" }
            status_colors = statuses.map do |status_name|
              IssueStatus.find_by(name: status_name).try(:background_color) || "#00854d"
            end

            render json: {
              legend: {
                data: statuses
              },
              series: [
                {
                  type: "themeRiver",
                  color: status_colors,
                  emphasis: {
                    itemStyle: {
                      shadowBlur: 20,
                      shadowColor: "rgba(0, 0, 0, 0.8)"
                    }
                  },
                  data: data
                }
              ]
            }, status: 200
          else
            render json: {}, status: :not_found
          end
        end

        def get_chart_for_time_summary
          if friday_request?
            date_from = params[:from].present? ? params[:from].to_date : 10.days.ago.to_date
            date_to = params[:to].present? ? params[:to].to_date : Date.today.to_date
            time_entries = TimeEntry.where(project: @project, spent_on: date_from..date_to).preload(:activity)

            time_entries_by_day_and_activity = time_entries.group_by { |te| [te.spent_on, te.activity.name] }.map do |(spent_on, activity_name), entries|
              total_hours = entries.sum(&:hours)
              [spent_on.to_date, total_hours.to_f, activity_name]
            end
            activities = time_entries_by_day_and_activity.map { |entry| entry[2] }.uniq
            existing_map = time_entries_by_day_and_activity.each_with_object({}) do |(d, h, a), hash|
              hash[[d, a]] = h
            end

            # Back-fill missing dates with zeros
            full_backfilled_data = []
            (date_from..date_to).each do |day|
              activities.each do |activity|
                hours = existing_map[[day, activity]] || 0.0
                full_backfilled_data << [day, hours, activity]
              end
            end
            render json: {
              legend: {
                data: activities
              },
              series: [
                {
                  type: "themeRiver",
                  emphasis: {
                    itemStyle: {
                      shadowBlur: 20,
                      shadowColor: "rgba(0, 0, 0, 0.8)"
                    }
                  },
                  data: full_backfilled_data
                }
              ]
            }, status: 200
          else
            render json: {}, status: :not_found
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
          menu_name = @project.new_record? ? nil : :project_menu
          menu_nodes = []
          if menu_name.present? && Redmine::MenuManager.items(menu_name).children.present?
            menu_items_for(menu_name, @project) do |node|
              menu_nodes << {
                key: node.name,
                title: node.caption(@project),
                to: node.url.nil? ? nil : get_vue_router_route_for_url(node.url, @project),
                children: if node.children.present? || !node.child_menus.nil?
                            node.children.map { |child|
                              {
                                key: child.name,
                                title: child.caption(@project),
                                to: child.url.nil? ? nil : get_vue_router_route_for_url(child.url, @project)
                              }
                            }
                          end
              }
            end
          end
          wiki = @project.wiki
          wiki_pages = []
          if wiki.present?
            wiki_pages = wiki.pages.with_updated_on.includes(wiki: :project).includes(:parent).to_a.map { |page|
              {
                id: page.id,
                title: page.title,
                url: project_wiki_page_path(page.wiki.project, page.title, parent: page.parent_id),
                parent: page.parent_id
              }
            }
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
              description: @project.description.nil? ? "" : @project.description,
              memberships: @project.memberships.preload(:member_roles, :roles).collect { |membership|
                {
                  principal: membership.principal[:id],
                  roles: membership.roles.sort.collect(&:id)
                }
              },
              issue_categories: @project.issue_categories.sort_by(&:id).map { |category|
                {
                  name: category.name,
                  assigned_to_id: category.assigned_to_id
                }
              },
              activities: @project.activities(true).select { |activity| activity.active }.map(&:id)
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
              manage_associated_gitlab_projects: User.current.allowed_to?(:manage_associated_gitlab_projects, @project),
              view_time_entries: User.current.allowed_to?(:view_time_entries, @project),
              view_issues: User.current.allowed_to?(:view_issues, @project),
              view_files: User.current.allowed_to?(:view_files, @project),
              manage_files: User.current.allowed_to?(:manage_files, @project),
              view_documents: User.current.allowed_to?(:view_documents, @project),
              add_documents: User.current.allowed_to?(:add_documents, @project),
              get_chart_for_issues_by_status: User.current.allowed_to?(:get_chart_for_issues_by_status, @project),
              get_chart_for_issues_by_tracker: User.current.allowed_to?(:get_chart_for_issues_by_tracker, @project),
              get_chart_for_activity_summary: User.current.allowed_to?(:get_chart_for_activity_summary, @project),
              get_chart_for_time_summary: User.current.allowed_to?(:get_chart_for_time_summary, @project),
              view_associated_monday_board: User.current.allowed_to?(:view_associated_monday_board, @project)
            },
            menu: menu_nodes,
            wiki: wiki_pages,
            documents: @project.documents.to_a.map { |document|
              {
                id: document.id,
                title: document.title,
                description: document.description,
                category: document.category&.name,
                attachment: document.attachments.first&.attributes
              }
            },
            files: @project.attachments.to_a,
            mondayBoard: @project.monday_board
          }.merge(additional)
        end

        def render_project_save_response(creating = false)
          if params[:project][:avatar].present?
            params[:project][:avatar] = process_avatar(params[:project][:avatar])
          end
          if params[:project][:banner].present?
            params[:project][:banner] = process_banner(params[:project][:banner])
          end
          @project.safe_attributes = params[:project]
          if @project.save
            if creating && !User.current.admin?
              @project.add_default_member(User.current)
            end
            if params[:project][:activities].present?
              syncronize_project_activities(@project, params[:project][:activities])
            end
            if params[:project][:memberships].present?
              syncronize_project_memberships(@project, params[:project][:memberships])
            end
            if params[:issue_categories].present?
              syncronize_issue_categories(@project, params[:issue_categories])
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

        def menu_items_for(menu, project = nil)
          items = []
          Redmine::MenuManager.items(menu).root.children.each do |node|
            if node.allowed?(User.current, project)
              if block_given?
                yield node
              else
                items << node
              end
            end
          end
          block_given? ? nil : items
        end

        def use_absolute_controller(url)
          if url.is_a?(Hash) && url[:controller].present? && !url[:controller].start_with?("/")
            url[:controller] = "/#{url[:controller]}"
          end
          url
        end

        def get_vue_router_route_for_url(url, project)
          case url[:controller]
          when "projects"
            case url[:action]
            when "settings"
              {name: "projects-id-settings", params: {id: project.identifier}}
            else
              {name: "projects-id", params: {id: project.identifier}}
            end
          when "gantt"
            {name: "projects-project-id-issues-gantt", params: {project_id: project.identifier}}
          when "calendar"
            {name: "projects-project-id-issues-calendar", params: {project_id: project.identifier}}
          else
            case url[:action]
            when "new"
              {name: "projects-project-id-#{url[:controller]}-new", params: {project_id: project.identifier}}
            else
              {name: "projects-project-id-#{url[:controller]}", params: {project_id: project.identifier}}
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

        def process_banner(base64_image)
          # Decode the base64 image
          image_data = Base64.decode64(base64_image.sub(/^data:image\/\w+;base64,/, ""))

          # Create a Tempfile to store the image
          temp_image = Tempfile.new(["banner", ".png"])
          temp_image.binmode
          temp_image.write(image_data)
          temp_image.rewind

          # Use MiniMagick to process the image
          image = MiniMagick::Image.new(temp_image.path)
          image.resize "3000x150>"

          # Return the modified image as a base64 string
          output = Tempfile.new(["banner_processed", ".png"])
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

        def syncronize_project_activities(project, activity_ids)
          project.activities(true).each do |activity|
            activity.active = activity_ids.include?(activity.id)
            activity.save
          end
        end

        def syncronize_project_memberships(project, memberships)
          existing_memberships = project.memberships.preload(:member_roles, :roles)
          # Remove existing memberships that are not in the new list
          existing_memberships.each do |existing_membership|
            if !memberships.any? { |membership| membership[:principal] == existing_membership[:principal_id] }
              existing_membership.destroy
            end
          end
          # Add new memberships that are not in the existing list
          # or update existing memberships with new roles
          memberships.each do |membership|
            principal = Principal.find(membership[:principal])
            if !existing_memberships.any? { |existing_membership| existing_membership[:principal_id] == membership[:principal] }
              Member.create_principal_memberships(principal, {
                project_ids: [project.id],
                role_ids: membership[:roles]
              })
            else
              existing_membership = existing_memberships.find { |existing_membership| existing_membership[:principal_id] == membership[:principal] }
              existing_membership.role_ids = membership[:roles]
              existing_membership.save
            end
          end
        end

        def syncronize_issue_categories(project, categories)
          existing_categories = project.issue_categories
          # Remove existing categories that are not in the new list
          existing_categories.each do |existing_category|
            if !categories.any? { |category| category[:name] == existing_category[:name] }
              existing_category.destroy
            end
          end
          # Add new memberships that are not in the existing list
          # or update existing memberships with new roles
          categories.each do |category|
            existing_category = existing_categories.find { |existing_category| existing_category[:name] == category[:name] }
            if existing_category.nil?
              # project.issue_categories.create(category)
              new_issue_category = IssueCategory.new
              new_issue_category.name = category[:name]
              new_issue_category.assigned_to_id = category[:assigned_to_id]
              new_issue_category.project = project
              new_issue_category.save
            else
              existing_category.assigned_to_id = category[:assigned_to_id]
              existing_category.save
            end
          end
        end
      end
    end
  end
end

ProjectsController.send(:include, FridayPlugin::ProjectsControllerPatch) unless ProjectsController.included_modules.include?(FridayPlugin::ProjectsControllerPatch)

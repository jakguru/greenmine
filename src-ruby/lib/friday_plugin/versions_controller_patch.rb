module FridayPlugin
  module VersionsControllerPatch
    def self.included(base)
      base.class_eval do
        alias_method :redmine_index, :index

        def index
          # If the request is made using FridayUI, respond with JSON
          if friday_request?
            handle_friday_json_response
          else
            # Call the original Redmine index action
            redmine_index
          end
        end

        private

        # Custom method to handle JSON responses for FridayUI
        def handle_friday_json_response
          trackers = @project.trackers.sorted.to_a
          selected_tracker_ids = retrieve_selected_tracker_ids(trackers, trackers.select(&:is_in_roadmap?))
          with_subprojects = params[:with_subprojects].nil? ? Setting.display_subprojects_issues? : (params[:with_subprojects] == "1")
          project_ids = with_subprojects ? @project.self_and_descendants.pluck(:id) : [@project.id]

          all_versions = @project.shared_versions.preload(:custom_values)
          all_versions += @project.rolled_up_versions.visible.preload(:custom_values) if with_subprojects
          all_versions = all_versions.to_a.uniq.sort

          completed_versions = params[:completed] ? [] : all_versions.select(&:completed?).reverse
          active_versions = all_versions - completed_versions

          issues_by_version = {}
          if selected_tracker_ids.any? && active_versions.any?
            issues = Issue.visible
              .includes(:project, :tracker)
              .preload(:status, :priority, :impact, :fixed_version)
              .where(tracker_id: selected_tracker_ids, project_id: project_ids, fixed_version_id: active_versions.map(&:id))
              .order("#{Project.table_name}.lft, #{Tracker.table_name}.position, #{Issue.table_name}.calculated_priority, #{Issue.table_name}.id")
            issues_by_version = issues.group_by(&:fixed_version)
          end

          filtered_versions = active_versions.reject do |version|
            !project_ids.include?(version.project_id) && issues_by_version[version].blank?
          end

          render_project_response({
            versions: filtered_versions.map do |version|
              {
                id: version.id,
                name: version.name,
                status: version.status,
                sharing: version.sharing,
                project_id: version.project_id,
                completed: version.completed?,
                issues: issues_by_version[version]&.map do |issue|
                  {
                    id: issue.id,
                    subject: issue.subject,
                    tracker: {
                      id: issue.tracker_id,
                      name: issue.tracker.name
                    },
                    status: {
                      id: issue.status_id,
                      name: issue.status.name
                    },
                    project: {
                      id: issue.project_id,
                      name: issue.project.name
                    },
                    priority: issue.calculated_priority
                  }
                end || [],
                count_issues_total: version.visible_fixed_issues.count,
                count_issues_closed: version.visible_fixed_issues.closed_count,
                count_issues_open: version.visible_fixed_issues.open_count,
                percent_issues_closed: version.visible_fixed_issues.closed_percent,
                percent_issues_completed: version.visible_fixed_issues.completed_percent,
                can_edit: User.current.allowed_to?(:manage_versions, version.project)
              }
            end,
            permissions: {
              manage_versions: User.current.allowed_to?(:manage_versions, @project)
            }
          })
        end
      end
    end
  end
end

VersionsController.send(:include, FridayPlugin::VersionsControllerPatch) unless VersionsController.included_modules.include?(FridayPlugin::VersionsControllerPatch)

module FridayPlugin
  module TrackersControllerPatch
    def self.included(base)
      base.class_eval do
        base.send(:include, FridayHelper)
        alias_method :redmine_base_index, :index
        alias_method :redmine_base_create, :create
        alias_method :redmine_base_update, :update
        alias_method :redmine_base_destroy, :destroy

        def index
          if friday_request?
            core_fields = Tracker::CORE_FIELDS.to_a
            issue_custom_fields = IssueCustomField.sorted.to_a
            hashed = {
              formAuthenticityToken: form_authenticity_token,
              coreFields: core_fields.map { |v|
                {
                  value: v.to_s,
                  label: l("field_#{v}".sub(/_id$/, ""))
                }
              },
              issueCustomFields: issue_custom_fields.map { |v|
                {
                  value: v.id,
                  label: v.name
                }
              },
              trackers: Tracker.sorted.preload(:default_status).each.collect { |v|
                {
                  id: v.id,
                  name: v.name,
                  default_status_id: v.default_status_id,
                  is_in_roadmap: v.is_in_roadmap,
                  description: v.description,
                  core_fields: core_fields.select { |field| v.core_fields.include?(field) }.map(&:to_s),
                  custom_field_ids: issue_custom_fields.select { |field| v.custom_fields.to_a.include?(field) }.map(&:id),
                  position: v.position,
                  icon: v.icon,
                  color: v.color,
                  project_ids: v.projects.map(&:id)
                }
              },
              projects: get_project_nested_items(Project.all),
              statuses: IssueStatus.sorted.each.collect { |v|
                {
                  value: v.id,
                  label: v.name
                }
              }
            }
            render json: hashed
          else
            redmine_base_index
          end
        end

        def create
          if friday_request?
            @tracker = Tracker.new
            @tracker.safe_attributes = params[:tracker]
            if request.post? && @tracker.save
              enqueue_realtime_updates
              render json: {
                id: @tracker.id
              }, status: 201
            else
              render json: {errors: @issue_status.errors.full_messages}, status: :unprocessable_entity
            end
          else
            redmine_base_create
          end
        end

        def update
          if friday_request?
            @tracker = Tracker.find(params[:id])
            @tracker.safe_attributes = params[:tracker]
            if @tracker.save
              enqueue_realtime_updates
              render json: {
                id: @tracker.id
              }, status: 201
            else
              render json: {errors: @tracker.errors.full_messages}, status: :unprocessable_entity
            end
          else
            redmine_base_update
          end
        end

        def destroy
          if friday_request?
            Tracker.find(params[:id]).destroy
            render json: {}, status: 200
          else
            redmine_base_destroy
          end
        rescue => e
          render json: {errors: ERB::Util.h(e.message)}, status: :unprocessable_entity
        end

        private

        def enqueue_realtime_updates
          ActionCable.server.broadcast("rtu_application", {updated: true})
          ActionCable.server.broadcast("rtu_trackers", {updated: true})
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
      end
    end
  end
end

TrackersController.send(:include, FridayPlugin::TrackersControllerPatch) unless TrackersController.included_modules.include?(FridayPlugin::TrackersControllerPatch)

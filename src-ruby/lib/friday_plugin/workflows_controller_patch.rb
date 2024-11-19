module FridayPlugin
  module WorkflowsControllerPatch
    def self.included(base)
      base.class_eval do
        base.send(:include, FridayHelper)
        alias_method :redmine_base_index, :index
        alias_method :redmine_base_update, :update

        def index
          if friday_request?
            core_fields = Tracker::CORE_FIELDS.to_a
            issue_custom_fields = IssueCustomField.sorted.to_a
            trackers = Tracker.sorted.preload(:default_status)
            roles = Role.sorted.select(&:consider_workflow?).each.collect { |v|
              {
                id: v.id,
                name: v.name,
                position: v.position
              }
            }
            tracker = params[:tracker] ? Tracker.find(params[:tracker]) : Tracker.sorted.first
            render json: {
              formAuthenticityToken: form_authenticity_token,
              tracker: tracker.nil? ? nil : {
                id: tracker.id,
                name: tracker.name,
                default_status_id: tracker.default_status_id,
                is_in_roadmap: tracker.is_in_roadmap,
                description: tracker.description,
                core_fields: core_fields.select { |field| tracker.core_fields.include?(field) }.map(&:to_s),
                custom_field_ids: issue_custom_fields.select { |field| tracker.custom_fields.to_a.include?(field) }.map(&:id),
                position: tracker.position,
                icon: tracker.icon,
                color: tracker.color,
                project_ids: tracker.projects.map(&:id),
                nodes: tracker.workflow_nodes,
                edges: tracker.workflow_edges,
                newIssueStatuses: make_new_issue_statuses_for_tracker(tracker, roles),
                coreFields: core_fields.select { |field| tracker.core_fields.include?(field) }.map { |f|
                  {
                    value: f.to_s,
                    label: l("field_#{f}".sub(/_id$/, "")),
                    required: field_required?(f)
                  }
                },
                issueCustomFields: issue_custom_fields.select { |field| tracker.custom_fields.to_a.include?(field) }.map { |f|
                  {
                    value: f.id,
                    label: f.name,
                    required: field_required?(f)
                  }
                }
              },
              trackers: trackers.map { |v|
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
                  project_ids: v.projects.map(&:id),
                  nodes: v.workflow_nodes,
                  edges: v.workflow_edges,
                  newIssueStatuses: v.workflow_new_issue_statuses,
                  coreFields: core_fields.select { |field| v.core_fields.include?(field) }.map { |f|
                    {
                      value: f.to_s,
                      label: l("field_#{f}".sub(/_id$/, "")),
                      required: field_required?(f)
                    }
                  },
                  issueCustomFields: issue_custom_fields.select { |field| v.custom_fields.to_a.include?(field) }.map { |f|
                    {
                      value: f.id,
                      label: f.name,
                      required: field_required?(f)
                    }
                  }
                }
              }
            }
          else
            redmine_base_index
          end
        end

        def update
          if friday_request?
            tracker = Tracker.find(params[:trackerId])
            if tracker.nil?
              render json: {}, status: 404
              return
            end
            tracker.nodes_json = params[:nodes].to_json
            tracker.edges_json = params[:edges].to_json
            tracker.new_issue_statuses_json = params[:status_ids_for_new].to_json
            if tracker.save
              render json: {}, status: 201
            else
              render json: {errors: tracker.errors}, status: 400
            end
          else
            redmine_base_update
          end
        end

        def field_required?(field)
          field.is_a?(CustomField) ? field.is_required? : %w[project_id tracker_id subject priority_id impact_id is_private].include?(field)
        end

        private

        def make_new_issue_statuses_for_tracker(tracker, roles)
          ret = {}
          roles.each do |role|
            ret[role[:id]] = tracker.workflow_new_issue_statuses[role[:id]] || [tracker.default_status_id]
            if !ret[role[:id]].include?(tracker.default_status_id)
              ret[role[:id]] << tracker.default_status_id
            end
          end
          ret
        end
      end
    end
  end
end

WorkflowsController.send(:include, FridayPlugin::WorkflowsControllerPatch) unless WorkflowsController.included_modules.include?(FridayPlugin::WorkflowsControllerPatch)

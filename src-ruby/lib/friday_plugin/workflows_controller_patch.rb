module FridayPlugin
  module WorkflowsControllerPatch
    def self.included(base)
      base.class_eval do
        base.send(:include, FridayHelper)
        alias_method :redmine_base_index, :index

        def index
          if friday_request?
            core_fields = Tracker::CORE_FIELDS.to_a
            issue_custom_fields = IssueCustomField.sorted.to_a
            trackers = Tracker.sorted.preload(:default_status)
            available_fields_by_tracker = trackers.each.collect { |v|
              {
                trackerId: v.id,
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
            render json: {
              formAuthenticityToken: form_authenticity_token,
              fieldsByTracker: available_fields_by_tracker
            }
          else
            redmine_base_index
          end
        end

        def field_required?(field)
          field.is_a?(CustomField) ? field.is_required? : %w[project_id tracker_id subject priority_id impact_id is_private].include?(field)
        end
      end
    end
  end
end

WorkflowsController.send(:include, FridayPlugin::WorkflowsControllerPatch) unless WorkflowsController.included_modules.include?(FridayPlugin::WorkflowsControllerPatch)

module FridayPlugin
  module IssueStatusesControllerPatch
    def self.included(base)
      base.class_eval do
        base.send(:include, FridayHelper)
        alias_method :redmine_base_index, :index
        alias_method :redmine_base_update, :update

        def index
          if friday_request?
            hashed = {
              formAuthenticityToken: form_authenticity_token,
              statuses: IssueStatus.sorted.each.collect { |v|
                {
                  id: v.id,
                  name: v.name,
                  is_closed: v.is_closed,
                  position: v.position,
                  description: v.description,
                  default_done_ratio: v.default_done_ratio,
                  icon: v.icon,
                  text_color: v.text_color,
                  background_color: v.background_color
                }
              }
            }
            render json: hashed
          else
            redmine_base_index
          end
        end

        def update
          if friday_request?
            render json: {}, status: 201
          else
            redmine_base_update
          end
        end

        def create
          render json: {}, status: 201
        end

        def destroy
          render json: {}, status: 201
        end

        private

        def enqueue_realtime_updates
          ActionCable.server.broadcast("rtu_application", {updated: true})
          ActionCable.server.broadcast("rtu_enumerations", {updated: true})
        end
      end
    end
  end
end

IssueStatusesController.send(:include, FridayPlugin::IssueStatusesControllerPatch) unless IssueStatusesController.included_modules.include?(FridayPlugin::IssueStatusesControllerPatch)

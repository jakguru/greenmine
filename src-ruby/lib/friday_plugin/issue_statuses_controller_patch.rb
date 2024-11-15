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

        def create
          @issue_status = IssueStatus.new
          @issue_status.safe_attributes = params[:issue_status]
          if request.post? && @issue_status.save
            enqueue_realtime_updates
            render json: {
              id: @issue_status.id
            }, status: 201
          else
            render action: "new"
          end
        end

        def update
          if friday_request?
            @issue_status = IssueStatus.find(params[:id])
            @issue_status.safe_attributes = params[:issue_status]
            if @issue_status.save
              enqueue_realtime_updates
              render json: {
                id: @issue_status.id
              }, status: 201
            else
              render json: {errors: @issue_status.errors.full_messages}, status: :unprocessable_entity
            end
          else
            redmine_base_update
          end
        end

        def destroy
          IssueStatus.find(params[:id]).destroy
          render json: {}, status: 200
        rescue => e
          render json: {errors: ERB::Util.h(e.message)}, status: :unprocessable_entity
        end

        private

        def enqueue_realtime_updates
          ActionCable.server.broadcast("rtu_application", {updated: true})
          ActionCable.server.broadcast("rtu_issue_statuses", {updated: true})
        end
      end
    end
  end
end

IssueStatusesController.send(:include, FridayPlugin::IssueStatusesControllerPatch) unless IssueStatusesController.included_modules.include?(FridayPlugin::IssueStatusesControllerPatch)

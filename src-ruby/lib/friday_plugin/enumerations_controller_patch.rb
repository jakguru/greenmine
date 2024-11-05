module FridayPlugin
  module EnumerationsControllerPatch
    def self.included(base)
      base.class_eval do
        base.send(:include, FridayHelper)
        alias_method :redmine_base_index, :index
        alias_method :redmine_base_update, :update

        def index
          if friday_request?
            hashed = {
              formAuthenticityToken: form_authenticity_token
            }
            Enumeration.get_subclasses.each do |klass|
              hashed[klass.name] = {
                name: klass.name,
                values: klass.shared.sorted.collect { |v| {id: v.id, name: v.name, is_default: v.is_default, position: v.position, active: v.active} }
              }
            end
            render json: hashed
          else
            redmine_base_index
          end
        end

        def update
          if friday_request?
            if @enumeration.update(enumeration_params)
              ActionCable.server.broadcast("rtu_application", {updated: true})
              ActionCable.server.broadcast("rtu_enumerations", {updated: true})
              enqueue_realtime_updates
              render json: @enumeration
            else
              render json: {errors: @enumeration.errors.full_messages}, status: :unprocessable_entity
            end
          else
            redmine_base_update
          end
        end

        def create
          if request.post? && @enumeration.save
            flash[:notice] = l(:notice_successful_create)
            enqueue_realtime_updates
            redirect_to enumerations_path
          else
            render action: "new"
          end
        end

        def destroy
          if !@enumeration.in_use?
            # No associated objects
            @enumeration.destroy
            enqueue_realtime_updates
            redirect_to enumerations_path
            return
          elsif params[:reassign_to_id].present? && (reassign_to = @enumeration.class.find_by_id(params[:reassign_to_id].to_i))
            @enumeration.destroy(reassign_to)
            enqueue_realtime_updates
            redirect_to enumerations_path
            return
          end
          @enumerations = @enumeration.class.system.to_a - [@enumeration]
        end

        private

        def enqueue_realtime_updates
          ActionCable.server.broadcast("rtu_application", {updated: true})
          ActionCable.server.broadcast("rtu_enumerations", {updated: true})
          if @enumeration.is_a?(IssuePriority) || @enumeration.is_a?(IssueImpact)
            UpdateCalculatedPriorityWorker.perform_async
          end
        end
      end
    end
  end
end

EnumerationsController.send(:include, FridayPlugin::EnumerationsControllerPatch) unless EnumerationsController.included_modules.include?(FridayPlugin::EnumerationsControllerPatch)

module FridayPlugin
  module CalendarsControllerPatch
    def self.included(base)
      base.class_eval do
        base.send(:include, FridayHelper)
        alias_method :redmine_base_show, :show

        def show
          if friday_request?
            if @project
              render_project_response({
                calendar: calendar_response
              })
            else
              render json: calendar_response
            end
          else
            redmine_base_show
          end
        end

        def calendar_response
          {}
        end
      end
    end
  end
end

CalendarsController.send(:include, FridayPlugin::CalendarsControllerPatch) unless CalendarsController.included_modules.include?(FridayPlugin::CalendarsControllerPatch)

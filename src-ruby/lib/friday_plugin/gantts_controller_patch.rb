module FridayPlugin
  module GanttsControllerPatch
    def self.included(base)
      base.class_eval do
        base.send(:include, FridayHelper)
        alias_method :redmine_base_show, :show

        def show
          if friday_request?
            if @project
              render_project_response({
                gantt: gantt_response
              })
            else
              render json: gantt_response
            end
          else
            redmine_base_show
          end
        end

        def gantt_response
          {}
        end
      end
    end
  end
end

GanttsController.send(:include, FridayPlugin::GanttsControllerPatch) unless GanttsController.included_modules.include?(FridayPlugin::GanttsControllerPatch)

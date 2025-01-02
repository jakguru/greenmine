module FridayPlugin
  module WikiControllerPatch
    def self.included(base)
      base.class_eval do
        base.send(:include, FridayHelper)
        alias_method :redmine_base_show, :show

        def show
          if friday_request?
            if @project
              render_project_response({
                wikiData: wiki_response
              })
            else
              render json: wiki_response
            end
          else
            redmine_base_show
          end
        end

        def wiki_response
          {}
        end
      end
    end
  end
end

WikiController.send(:include, FridayPlugin::WikiControllerPatch) unless WikiController.included_modules.include?(FridayPlugin::WikiControllerPatch)

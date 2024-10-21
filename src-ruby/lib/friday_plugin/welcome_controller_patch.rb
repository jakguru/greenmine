module FridayPlugin
  module WelcomeControllerPatch
    def self.included(base)
      base.class_eval do
        base.send(:include, FridayHelper)
        alias_method :redmine_base_index, :index

        def index
          if friday_request?
            @news = News.latest User.current
            render json: {
              welcome: Setting.welcome_text,
              news: @news
            }
          else
            redmine_base_index
          end
        end
      end
    end
  end
end

WelcomeController.send(:include, FridayPlugin::WelcomeControllerPatch) unless WelcomeController.included_modules.include?(FridayPlugin::WelcomeControllerPatch)

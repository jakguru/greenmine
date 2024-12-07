module FridayPlugin
  module ApplicationControllerPatch
    def self.included(base)
      base.class_eval do
        base.send(:include, FridayHelper)
        alias_method :redmine_base_check_password_change, :check_password_change

        def check_password_change
          if friday_request?
            if session[:pwd]
              if User.current.must_change_password?
                render json: {
                  mustChangePassword: true,
                  to: my_password_path
                }, status: 307
              else
                session.delete(:pwd)
              end
            end
          else
            redmine_base_check_password_change
          end
        end
      end
    end
  end
end

ApplicationController.send(:include, FridayPlugin::ApplicationControllerPatch) unless ApplicationController.included_modules.include?(FridayPlugin::ApplicationControllerPatch)

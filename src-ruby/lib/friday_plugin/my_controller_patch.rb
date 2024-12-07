module FridayPlugin
  module MyControllerPatch
    def self.included(base)
      base.class_eval do
        base.send(:include, FridayHelper)
        alias_method :redmine_base_password, :password

        def password
          if friday_request?
            if request.post?
              render json: {
                formAuthenticityToken: form_authenticity_token,
                passwordMinLength: Setting.send(:password_min_length)&.to_i,
                passwordRequiredCharClasses: Setting.send(:password_required_char_classes)
              }, status: 418
            else
              render json: {
                error: flash[:error],
                formAuthenticityToken: form_authenticity_token,
                passwordMinLength: Setting.send(:password_min_length)&.to_i,
                passwordRequiredCharClasses: Setting.send(:password_required_char_classes)
              }
            end
          else
            redmine_base_password
          end
        end
      end
    end
  end
end

MyController.send(:include, FridayPlugin::MyControllerPatch) unless MyController.included_modules.include?(FridayPlugin::MyControllerPatch)

module FridayPlugin
  module MyControllerPatch
    def self.included(base)
      base.class_eval do
        base.send(:include, FridayHelper)
        alias_method :redmine_base_password, :password

        def password
          if friday_request?
            if request.post?
              @user = User.current
              unless @user.change_password_allowed?
                return render json: {error: l(:error_cannot_change_password)}, status: 403
              end
              if !@user.check_password?(params[:password])
                return render json: {error: l(:error_invalid_password)}, status: 403
              end
              if params[:password] == params[:new_password]
                return render json: {error: l(:error_new_password_same_as_old)}, status: 403
              end
              # render json: {
              #   formAuthenticityToken: form_authenticity_token,
              #   passwordMinLength: Setting.send(:password_min_length)&.to_i,
              #   passwordRequiredCharClasses: Setting.send(:password_required_char_classes)
              # }, status: 418
              @user.password, @user.password_confirmation = params[:new_password], params[:new_password_confirmation]
              @user.must_change_passwd = false
              if @user.save
                session[:tk] = @user.generate_session_token
                Mailer.deliver_password_updated(@user, User.current)
                render json: {notice: l(:notice_account_password_updated)}, status: 201
              end
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

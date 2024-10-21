module FridayPlugin
  module AccountControllerPatch
    def self.included(base)
      base.class_eval do
        base.send(:include, FridayHelper)
        alias_method :redmine_login, :login
        alias_method :redmine_password_authentication, :password_authentication
        alias_method :redmine_successful_authentication, :successful_authentication
        alias_method :redmine_handle_inactive_user, :handle_inactive_user
        alias_method :redmine_account_pending, :account_pending
        alias_method :account_locked, :account_locked

        def login
          if friday_request?
            if request.post?
              password_authentication
            elsif User.current.logged?
              render json: {
                to: home_url
              }
            else
              render json: {
                homeUrl: home_url,
                backUrl: validate_back_url(back_url),
                signinPath: signin_path,
                params: params,
                lostPassword: Setting.lost_password?,
                lostPasswordPath: lost_password_path,
                autologin: Setting.autologin?,
                formAuthenticityToken: form_authenticity_token
              }
            end
          else
            redmine_login
          end
        rescue AuthSourceException => e
          logger.error "An error occurred when authenticating #{params[:username]}: #{e.message}"
          if friday_request?
            return render json: {
              message: e.message
            }, status: :unauthorized
          end
          render_error message: e.message
        end

        def logout
          if User.current.anonymous?
            if friday_request?
              return render json: {
                to: home_url
              }
            end
            redirect_to home_url
          elsif request.post?
            logout_user
            if friday_request?
              return render json: {
                to: home_url
              }
            end
            redirect_to home_url
          end
          if friday_request?
            logout_user
            render json: {
              to: home_url
            }
          end
        end

        def password_authentication
          if friday_request?
            user = User.try_to_login!(params[:username], params[:password], false)
            if user.nil?
              render json: {
                message: l(:notice_account_invalid_creditentials)
              }, status: :unauthorized
            elsif user.new_record?
              # TODO: replace this functionality for use with Friday UI
              onthefly_creation_failed(user, {login: user.login, auth_source_id: user.auth_source_id})
            elsif user.active?
              if user.twofa_active?
                setup_twofa_session user
                twofa = Redmine::Twofa.for_user(user)
                if twofa.send_code(controller: "account", action: "twofa")
                  flash[:notice] = l("twofa_code_sent")
                end
                render json: {
                  to: account_twofa_confirm_path,
                  message: l("twofa_code_sent")
                }, status: 412
              else
                handle_active_user(user)
              end
            else
              handle_inactive_user(user)
            end
          else
            redmine_password_authentication
          end
        end

        def handle_inactive_user(user, redirect_path = signin_path)
          if friday_request?
            if user.registered?
              account_pending(user, redirect_path)
            else
              account_locked(user, redirect_path)
            end
          else
            redmine_handle_inactive_user(user, redirect_path)
          end
        end

        def account_pending(user, redirect_path = signin_path)
          if Setting.self_registration == "1"
            session[:registered_user_id] = user.id
            render json: {
              to: redirect_path,
              message: l(:notice_account_not_activated_yet, url: activation_email_path)
            }, status: 412
          else
            render json: {
              to: redirect_path,
              message: l(:notice_account_pending)
            }, status: 402
          end
        end

        def account_locked(user, redirect_path = signin_path)
          render json: {
            to: redirect_path,
            message: l(:notice_account_locked)
          }, status: 406
        end

        def successful_authentication(user)
          if friday_request?
            self.logged_user = user
            if params[:autologin] && Setting.autologin?
              set_autologin_cookie(user)
            end
            call_hook(:controller_account_success_authentication_after, {user: user})
          else
            redmine_successful_authentication(user)
          end
        end
      end
    end
  end
end

AccountController.send(:include, FridayPlugin::AccountControllerPatch) unless AccountController.included_modules.include?(FridayPlugin::AccountControllerPatch)

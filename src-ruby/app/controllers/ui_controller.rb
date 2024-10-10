# frozen_string_literal: true

class UiController < ApplicationController
    unloadable

    def get_app_data
        render json: {
            name: Redmine::Info.app_name,
            i18n: ::I18n.locale,
            identity: {
                authenticated: User.current.logged?,
                identity: User.current.logged? ? User.current : nil,
            },
            settings: {
                loginRequired: Setting.login_required?,
                gravatarEnabled: Setting.gravatar_enabled?,
                selfRegistrationEnabled: Setting.self_registration?
            },
            fetchedAt: Time.now
        }
    end
end
  
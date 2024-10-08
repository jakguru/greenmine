# frozen_string_literal: true

class UiController < ApplicationController
    unloadable

    def get_app_data
        render json: {
            identity: {
                authenticated: User.current.logged?,
                identity: User.current.logged? ? User.current : nil,
            },
            settings: {
                loginRequired: Setting.login_required?,
                gravatarEnabled: Setting.gravatar_enabled?
            }
        }
    end
end
  
# frozen_string_literal: true

class UiController < ApplicationController
    unloadable

    def get_app_data
        projects = projects_for_jump_box(User.current)
        jump_box = Redmine::ProjectJumpBox.new User.current
        bookmarked = jump_box.bookmarked_projects
        recents = jump_box.recently_used_projects
        render json: {
            name: Redmine::Info.app_name,
            i18n: ::I18n.locale,
            identity: {
                authenticated: User.current.logged?,
                identity: User.current.logged? ? User.current : nil,
            },
            projects: {
                active: projects,
                bookmarked: bookmarked,
                recent: recents
            },
            queries: {
                projects: {
                    operators: Query.operators_by_filter_type,
                }
            },
            settings: {
                loginRequired: Setting.login_required?,
                gravatarEnabled: Setting.gravatar_enabled?,
                selfRegistrationEnabled: Setting.self_registration?
            },
            fetchedAt: Time.now
        }
    end

    private

    def projects_for_jump_box(user=User.current)
        if user.logged?
            user.projects.active.select(:id, :name, :identifier, :lft, :rgt).to_a
        else
            []
        end
    end
end
  
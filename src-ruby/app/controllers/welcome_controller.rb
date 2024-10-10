# frozen_string_literal: true

class WelcomeController < ApplicationController
  self.main_menu = false

  skip_before_action :check_if_login_required, only: [:robots]

  def index
    @news = News.latest User.current
    if (request.xhr?)
      render json: {
        welcome: Setting.welcome_text,
        news: @news
      }
    end
  end

  def robots
    @projects = Project.visible(User.anonymous) unless Setting.login_required?
    render :layout => false, :content_type => 'text/plain'
  end
end

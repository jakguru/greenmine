require "rake"

class DockerController < ApplicationController
  skip_before_action :verify_authenticity_token, :check_if_login_required

  # GET,POST /nht/docker/health
  def answer_health_check
    render json: {status: "OK"}
  end
end

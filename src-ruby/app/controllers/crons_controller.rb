require "rake"

class CronsController < ApplicationController
  skip_before_action :verify_authenticity_token, :check_if_login_required

  def poll
    FridayPlugin::ScheduledJobRunner.run_if_needed
    render json: {status: "OK"}
  end
end

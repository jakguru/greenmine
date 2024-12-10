module Webhooks
  class MondayController < ApplicationController
    skip_before_action :verify_authenticity_token, :check_if_login_required

    def handle
      if params[:challenge].present?
        render json: {challenge: params[:challenge]}
        return
      end
      important_headers = {
        "authorization" => request.headers["Authorization"]
      }
      ProcessMondayWebhookJob.perform_async(params.to_json, important_headers.to_json)
      render json: {accepted: true}, status: :accepted
    end
  end
end

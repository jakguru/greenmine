module Webhooks
  class GitlabController < ApplicationController
    skip_before_action :verify_authenticity_token, :check_if_login_required

    def handle
      ProcessGitlabWebhookJob.perform_async(params.to_json)
      render json: {accepted: true}
    end
  end
end

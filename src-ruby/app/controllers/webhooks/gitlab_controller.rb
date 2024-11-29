module Webhooks
  class GitlabController < ApplicationController
    skip_before_action :verify_authenticity_token, :check_if_login_required

    def handle
      important_headers = {
        "x-gitlab-event" => request.headers["X-Gitlab-Event"],
        "x-gitlab-webhook-uuid" => request.headers["X-Gitlab-Webhook-UUID"],
        "x-gitlab-instance" => request.headers["X-Gitlab-Instance"],
        "x-gitlab-event-uuid" => request.headers["X-Gitlab-Event-UUID"],
        "x-gitlab-token" => request.headers["X-Gitlab-Token"]
      }
      ProcessGitlabWebhookJob.perform_async(params.to_json, important_headers.to_json)
      render json: {accepted: true}, status: :accepted
    end
  end
end

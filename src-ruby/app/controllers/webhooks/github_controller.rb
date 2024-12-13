module Webhooks
  class GithubController < ApplicationController
    skip_before_action :verify_authenticity_token, :check_if_login_required

    def handle
      important_headers = {
        "x-github-delivery" => request.headers["X-GitHub-Delivery"],
        "x-hub-signature" => request.headers["X-Hub-Signature"],
        "x-hub-signature-256" => request.headers["X-Hub-Signature-256"],
        "x-github-event" => request.headers["X-GitHub-Event"],
        "x-github-hook-id" => request.headers["X-GitHub-Hook-ID"],
        "x-github-hook-installation-target-id" => request.headers["X-GitHub-Hook-Installation-Target-ID"],
        "x-github-hook-installation-target-type" => request.headers["X-GitHub-Hook-Installation-Target-Type"]
      }
      ProcessGithubWebhooksJob.perform_async(params.to_json, important_headers.to_json)
      render json: {accepted: true}, status: :accepted
    end
  end
end

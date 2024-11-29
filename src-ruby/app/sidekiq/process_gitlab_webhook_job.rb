class ProcessGitlabWebhookJob
  include Sidekiq::Job

  def perform(json_encoded_params)
    params = JSON.parse(json_encoded_params)
    Rails.logger.info("Processing GitLab Webhook: #{params.inspect}")
  end
end

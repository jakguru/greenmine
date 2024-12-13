class ProcessGitlabWebhookJob
  include Sidekiq::Job

  def perform(json_encoded_params, json_encoded_headers)
    params = JSON.parse(json_encoded_params)
    headers = JSON.parse(json_encoded_headers)
    Rails.logger.info("Processing Gitlab Webhook: #{params.inspect} with headers: #{headers.inspect}")
    # TODO: Implement the webhook processing logic here
  end
end

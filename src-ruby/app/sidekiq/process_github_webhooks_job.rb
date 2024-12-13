class ProcessGithubWebhooksJob
  include Sidekiq::Job

  def perform(json_encoded_params, json_encoded_headers)
    params = JSON.parse(json_encoded_params, {
      symbolize_names: true
    })
    headers = JSON.parse(json_encoded_headers, {
      symbolize_names: true
    })
    Rails.logger.info("Processing Github Webhook: #{params.inspect} with headers: #{headers.inspect}")
    github_instance = GithubInstance.find_by(params[:ghid])
    if github_instance.nil?
      Rails.logger.error("GithubInstance with id #{params[:ghid]} not found")
      return
    end
    github_repository = GithubRepository.find_by(id: params[:ghrid])
    if github_repository.nil?
      Rails.logger.error("GithubRepository with id #{params[:ghrid]} not found under GithubInstance with id #{params[:ghid]}")
      nil
    elsif github_repository[:github_id] != github_instance.id
      Rails.logger.error("GithubRepository with id #{params[:ghrid]} not found under GithubInstance with id #{params[:ghid]}")
    end
    github_repository.do_process_webhook(params, headers)
  end
end

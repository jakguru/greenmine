class ProcessGitlabWebhookJob
  include Sidekiq::Job

  def perform(json_encoded_params, json_encoded_headers)
    params = JSON.parse(json_encoded_params, {
      symbolize_names: true
    })
    headers = JSON.parse(json_encoded_headers, {
      symbolize_names: true
    })
    Rails.logger.info("Processing Gitlab Webhook: #{params.inspect} with headers: #{headers.inspect}")
    gitlab_instance = GitlabInstance.find_by(params[:glid])
    if gitlab_instance.nil?
      Rails.logger.error("GitlabInstance with id #{params[:glid]} not found")
      return
    end
    gitlab_project = GitlabProject.find_by(id: params[:glpid])
    if gitlab_project.nil?
      Rails.logger.error("GitlabProject with id #{params[:glpid]} not found under GitlabInstance with id #{params[:glid]}")
      nil
    elsif gitlab_project[:gitlab_id] != gitlab_instance.id
      Rails.logger.error("GitlabProject with id #{params[:glpid]} not found under GitlabInstance with id #{params[:glid]}")
    end
    gitlab_project.do_process_webhook(params, headers)
  end
end

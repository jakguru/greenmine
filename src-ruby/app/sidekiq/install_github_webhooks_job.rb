class InstallGithubWebhooksJob
  include Sidekiq::Job

  def perform(github_instance_id, github_repository_id)
    github_instance = GithubInstance.find(github_instance_id)
    if github_instance.nil?
      Rails.logger.error("Gitlab Instance ID: #{github_instance_id} not found")
      return
    end
    github_repository = GithubRepository.find_by(id: github_repository_id)
    if github_repository.nil?
      Rails.logger.error("Gitlab Project ID: #{github_repository_id} not found")
      return
    end
    webhook_url_protocol = Setting.send(:protocol)
    webhook_url_host = Setting.send(:host_name)
    github_webhook_url = "#{webhook_url_protocol}://#{webhook_url_host}/webhooks/github?ghid=#{github_instance_id}&ghrid=#{github_repository_id}"
    Rails.logger.info("Installing Github Webhook #{github_webhook_url} for Github Repository ID: #{github_repository.repository_id} on Github Instance ID: #{github_instance_id}")
    needs_webhook_installation = true
    needs_webhook_update = false
    owner = github_repository.path_with_namespace.split("/").first
    repo = github_repository.path_with_namespace.split("/").last
    web_options = {
      owner: owner,
      repo: repo,
      name: "web",
      active: true,
      events: [
        "check_run",
        "check_suite",
        "code_scanning_alert",
        "commit_comment",
        "create",
        "delete",
        "dependabot_alert",
        "deployment",
        "deployment_status",
        "discussion",
        "discussion_comment",
        "gollum",
        "issue_comment",
        "issues",
        "milestone",
        "package",
        "page_build",
        "ping",
        "pull_request",
        "pull_request_review_comment",
        "pull_request_review",
        "pull_request_review_thread",
        "push",
        "release",
        "repository_advisory",
        "repository",
        "repository_vulnerability_alert",
        "secret_scanning_alert",
        "secret_scanning_alert_location",
        "security_and_analysis",
        "workflow_job",
        "workflow_run"
      ],
      config: {
        url: github_webhook_url,
        content_type: "json",
        insecure_ssl: "0"
      }
    }
    client = github_instance.api_client
    hooks = []
    res = client.hooks(github_repository.path_with_namespace)
    res.each do |hook|
      hooks << hook
    end
    while client.last_response.rels[:next].present?
      res = client.hooks(github_repository.path_with_namespace)
      res.each do |hook|
        hooks << hook
      end
    end
    hooks.each do |hook|
      if hook[:config][:url] == github_webhook_url
        needs_webhook_installation = false
        Rails.logger.info(hook.inspect)
        web_options.keys.each do |key|
          if hook[key.to_s] != web_options[key]
            needs_webhook_update = hook[:id]
            break
          end
        end
        web_options[:config].keys.each do |key|
          if hook[:config][key.to_s] != web_options[:config][key]
            needs_webhook_update = hook[:id]
            break
          end
        end
      end
    end
    if needs_webhook_update.is_a?(Integer)
      client.remove_hook(github_repository.path_with_namespace, needs_webhook_update)
      needs_webhook_installation = true
    end
    if needs_webhook_installation
      client.create_hook(
        github_repository.path_with_namespace,
        web_options[:name],
        web_options[:config],
        {
          events: web_options[:events],
          active: web_options[:active]
        }
      )
    end
  end
end

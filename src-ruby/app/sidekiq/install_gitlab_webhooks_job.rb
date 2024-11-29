class InstallGitlabWebhooksJob
  include Sidekiq::Job

  def perform(gitlab_instance_id, gitlab_project_id)
    gitlab_instance = GitlabInstance.find(gitlab_instance_id)
    if gitlab_instance.nil?
      Rails.logger.error("GitLab Instance ID: #{gitlab_instance_id} not found")
      return
    end
    gitlab_project = GitlabProject.find_by(id: gitlab_project_id)
    if gitlab_project.nil?
      Rails.logger.error("GitLab Project ID: #{gitlab_project_id} not found")
      return
    end
    webhook_url_protocol = Setting.send(:protocol)
    webhook_url_host = Setting.send(:host_name)
    gitlab_webhook_url = "#{webhook_url_protocol}://#{webhook_url_host}/webhooks/gitlab?glid=#{gitlab_instance_id}&glpid=#{gitlab_project_id}"
    Rails.logger.info("Installing GitLab Webhook #{gitlab_webhook_url} for GitLab Project ID: #{gitlab_project.project_id} on GitLab Instance ID: #{gitlab_instance_id}")
    needs_webhook_installation = true
    needs_webhook_update = false
    web_options = {
      name: "#{Setting.send(:app_title)} Webhook",
      description: "Webhook for #{Setting.send(:app_title)} Redmine Application GitLab Integration",
      push_events: true,
      tag_push_events: true,
      merge_requests_events: true,
      enable_ssl_verification: true,
      issues_events: true,
      confidential_issues_events: true,
      note_events: true,
      confidential_note_events: true,
      pipeline_events: true,
      wiki_page_events: true,
      deployment_events: true,
      feature_flag_events: true,
      job_events: true,
      releases_events: true,
      emoji_events: true,
      resource_access_token_events: true,
      repository_update_events: true,
      alert_status: "executable",
      disabled_until: nil,
      push_events_branch_filter: nil,
      branch_filter_strategy: "all_branches",
      custom_webhook_template: ""
    }
    client = gitlab_instance.api_client
    client.project_hooks(gitlab_project.project_id).auto_paginate do |hook|
      if hook.url == gitlab_webhook_url
        needs_webhook_installation = false
        web_options.keys.each do |key|
          if hook[key.to_s] != web_options[key]
            needs_webhook_update = hook.id
            break
          end
        end
      end
    end
    if needs_webhook_installation
      client.add_project_hook(gitlab_project.project_id, gitlab_webhook_url, web_options)
    elsif needs_webhook_update.is_a?(Integer)
      client.edit_project_hook(gitlab_project.project_id, needs_webhook_update, web_options)
    end
  end
end

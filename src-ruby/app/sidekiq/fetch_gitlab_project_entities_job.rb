class FetchGitlabProjectEntitiesJob
  include Sidekiq::Job

  def perform(id, only = ["branch", "commit", "merge_request", "tag", "pipeline", "release"], since = nil)
    gitlab_project = GitlabProject.find(id)
    if gitlab_project.nil?
      return nil
    end
    gitlab = gitlab_project.gitlab_instance
    if gitlab.nil?
      return nil
    end
    api_client = gitlab.api_client
    if only.include?("branch")
      Rails.logger.info("Fetching branches for Gitlab project #{gitlab_project.id}")
    end
  end
end

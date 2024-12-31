GITABLE_CLASSES = ["GithubInstance", "GitlabInstance"]

class FetchGitableEntitiesJob
  include Sidekiq::Job

  def perform(klass, id)
    unless GITABLE_CLASSES.include?(klass)
      return nil
    end
    instance = klass.constantize.find(id)
    if instance.nil?
      nil
    end
    children = []
    case klass
    when "GithubInstance"
      children = GithubRepository.where(github_id: instance.id)
    when "GitlabInstance"
      children = GitlabProject.where(gitlab_id: instance.id)
    end
    children.each do |child|
      case klass
      when "GithubInstance"
        FetchGithubRepositoryEntitiesJob.perform_async(child.id)
      when "GitlabInstance"
        FetchGitlabProjectEntitiesJob.perform_async(child.id)
      end
    end
  end
end

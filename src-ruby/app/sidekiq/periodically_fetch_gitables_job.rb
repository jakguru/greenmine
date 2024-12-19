class PeriodicallyFetchGitablesJob
  include Sidekiq::Job

  def perform
    GithubInstance.active.each do |instance|
      FetchGithubRepositoriesJob.perform_async(instance.id)
      FetchGithubUsersJob.perform_async(instance.id)
    end
    GitlabInstance.active.each do |instance|
      FetchGitlabProjectsJob.perform_async(instance.id)
      FetchGitlabUsersJob.perform_async(instance.id)
    end
  end
end

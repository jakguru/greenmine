class FetchGithubRepositoriesJob
  include Sidekiq::Job

  def perform(id)
    github = GithubInstance.find(id)
    api_client = github.api_client
    repos = []
    res = api_client.repos
    res.each do |repo|
      repos << repo
    end
    while api_client.last_response.rels[:next].present?
      res = api_client.get(api_client.last_response.rels[:next].href)
      res.each do |repo|
        repos << repo
      end
    end
    repos.each do |repository|
      if repository[:permissions][:admin] || repository[:permissions][:maintain]
        github_instance_repository = GithubRepository.find_by(github_id: github.id, repository_id: repository[:id])
        if github_instance_repository.nil?
          github_instance_repository = GithubRepository.new(
            github_id: github.id,
            repository_id: repository[:id],
            name: repository[:name],
            name_with_namespace: repository[:full_name],
            path: repository[:name],
            path_with_namespace: repository[:full_name]
          )
        end
        github_instance_repository.name = repository[:name]
        github_instance_repository.name_with_namespace = repository[:full_name]
        github_instance_repository.path = repository[:name]
        github_instance_repository.path_with_namespace = repository[:full_name]
        github_instance_repository.save!
      end
    end
    ActionCable.server.broadcast("rtu_github_instance_repositories", {github_instance_id: github.id})
  end
end

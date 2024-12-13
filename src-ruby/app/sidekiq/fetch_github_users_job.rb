class FetchGithubUsersJob
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
    github_users_by_id = {}
    repos.each do |repository|
      if repository[:owner][:type] == "User"
        owner = repository[:owner]
        github_users_by_id[owner[:id]] = owner
      end
      if repository[:permissions][:admin] || repository[:permissions][:maintain]
        collaborators = api_client.collaborators(repository[:full_name])
        collaborators.each do |collaborator|
          if collaborator[:type] == "User"
            github_users_by_id[collaborator[:id]] = collaborator
          end
        end
      end
    end
    github_users_by_id.each do |user_id, user|
      github_user = GithubUser.find_by(github_id: github.id, user_id: user_id)
      if github_user.nil?
        github_user = GithubUser.new(
          github_id: github.id,
          user_id: user_id,
          name: user[:login],
          username: user[:login]
        )
      end
      github_user.name = user[:login]
      github_user.username = user[:login]
      github_user.save!
    end
    ActionCable.server.broadcast("rtu_github_instance_repositories", {github_instance_id: github.id})
  end
end

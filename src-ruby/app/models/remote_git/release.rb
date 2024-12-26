module RemoteGit
  class Release < ActiveRecord::Base
    self.table_name = "remote_git_releases"
    # Associations
    belongs_to :tag, class_name: "RemoteGit::Tag"
    has_and_belongs_to_many :versions, class_name: "Version", join_table: "remote_git_releases_versions"

    # Validations
    validates :name, presence: true
    validates :remote_id, presence: true, uniqueness: true
    validates :tag, presence: true

    # Custom method to retrieve projects (optional if needed)
    def projects
      case tag.taggable
      when GitLabProject
        tag.taggable.projects
      when GitHubRepository
        tag.taggable.projects
      else
        []
      end
    end

    def refresh
      case tag.taggable
      when GithubRepository
        api_client = tag.taggable.github_instance.api_client
        release_data = api_client.release_for_tag(tag.taggable.path_with_namespace, tag.name).to_h
        update_release_from_data(release_data)
      when GitlabProject
        api_client = tag.taggable.gitlab_instance.api_client
        release_data = api_client.project_release(tag.taggable.path_with_namespace, tag.name).to_h
        update_release_from_data(release_data)
      else
        raise NotImplementedError, "Refresh not supported for #{tag.taggable.class.name}"
      end
    rescue => e
      Rails.logger.error("Failed to refresh release #{id}: #{e.message}")
    end

    private

    def update_release_from_data(data)
      Rails.logger.info("Updating release with data: #{data.inspect}")
      # Handle both symbol and string keys by using `dig` and fallback to nil for missing fields.
      update!(
        name: data.dig("name") || data.dig(:name),
        description: data.dig("body") || data.dig(:body) || data.dig("description") || data.dig(:description),
        released_at: data.dig("published_at") || data.dig(:published_at) || data.dig("created_at") || data.dig(:created_at)
      )
      Rails.logger.info("Release #{name} updated successfully.")
    end
  end
end

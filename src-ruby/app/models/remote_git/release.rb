module RemoteGit
  class Release < ActiveRecord::Base
    include FridayRemoteGitEntityHelper
    include Redmine::Acts::ActivityProvider
    include Redmine::Acts::Event
    self.table_name = "remote_git_releases"
    # Associations
    belongs_to :tag, class_name: "RemoteGit::Tag"
    has_and_belongs_to_many :versions, class_name: "Version", join_table: "remote_git_releases_versions"
    has_many :remote_git_associations, as: :associable, dependent: :destroy
    has_many :issues, through: :remote_git_associations
    has_many :projects, through: :issues
    # has_many :projects, -> { distinct }, through: :tag, source: :projects

    # Validations
    validates :name, presence: true
    validates :remote_id, presence: true, uniqueness: true
    validates :tag, presence: true

    after_save :create_issue_relationships

    acts_as_event datetime: proc { |release| release.tag&.commit&.committed_at },
      title: proc { |release| "Release: #{release.name}" },
      description: :description,
      author: :author,
      type: "remote-git-release",
      url: nil

    acts_as_activity_provider type: "releases",
      timestamp: "remote_git_commits.committed_at", # Explicitly reference the commit's committed_at column
      author_key: proc { |release| release.tag&.commit&.committer&.user_id },
      permission: :view_project,
      scope: proc {
        joins(tag: :commit) # Ensure we join from tag to commit
          .joins(:projects)
          .where("#{Project.table_name}.status = ?", Project::STATUS_ACTIVE)
          .where.not("remote_git_commits.committed_at" => nil)
      }

    def author
      tag&.commit&.committer&.user
    end

    def url
      case tag&.commitable
      when GithubRepository
        {host: "#{tag.commitable.web_url}/releases/tag/#{name}", port: nil, controller: "", action: ""}
      when GitlabRepository
        {host: "#{tag.commitable.web_url}/-/releases/#{name}", port: nil, controller: "", action: ""}
      else
        {host: nil}
      end
    end

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

    def create_issue_relationships
      related_commits = tag&.commit&.message
      self.issues = scan_for_issue_references(description, related_commits)
    end
  end
end

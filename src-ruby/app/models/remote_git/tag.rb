module RemoteGit
  class Tag < ActiveRecord::Base
    include FridayRemoteGitEntityHelper
    include Redmine::Acts::ActivityProvider
    include Redmine::Acts::Event
    self.table_name = "remote_git_tags"

    # Polymorphic association
    belongs_to :taggable, polymorphic: true
    has_many :remote_git_associations, as: :associable, dependent: :destroy
    has_many :issues, through: :remote_git_associations
    has_many :projects, through: :issues
    # has_many :projects, -> { distinct }, through: :taggable, source: :projects

    # Association with the commit that the tag points to
    belongs_to :commit, class_name: "RemoteGit::Commit"

    # Association with the committer
    belongs_to :committer, class_name: "RemoteGit::Committer", optional: true

    has_many :pipelines, class_name: "RemoteGit::Pipeline", foreign_key: "tag_id", dependent: :destroy

    # Validations
    validates :name, presence: true
    validates :remote_id, presence: true, uniqueness: true
    validates :commit, presence: true
    validates :taggable, presence: true

    # Ensure uniqueness at the model level as well
    validates :name, uniqueness: {scope: [:taggable_type, :taggable_id]}

    after_save :create_issue_relationships

    acts_as_event datetime: proc { |tag| tag.commit&.committed_at },
      title: proc { |tag| "Tag: #{tag.name}" },
      description: proc { |tag| "Tagged commit #{tag.commit&.sha&.[](0..6)}" },
      author: :author,
      type: "remote-git-tag",
      url: nil

    acts_as_activity_provider type: "tags",
      timestamp: "remote_git_commits.committed_at", # Explicitly reference the associated commit's committed_at
      author_key: proc { |tag| tag.commit&.committer&.user_id },
      permission: :view_project,
      scope: proc {
        joins(:commit, :projects) # Join commit and projects
          .where("#{Project.table_name}.status = ?", Project::STATUS_ACTIVE)
      }

    # Self-referential logic for parent tags
    def parent_commit
      RemoteGit::Commit.find_by(sha: parent_sha) if parent_sha.present?
    end

    def author
      commit&.committer&.user
    end

    def url
      case commitable
      when GithubRepository
        {host: "#{commitable.web_url}/releases/tag/#{name}", port: nil, controller: "", action: ""}
      when GitlabRepository
        {host: "#{commitable.web_url}/-/tags/#{name}", port: nil, controller: "", action: ""}
      else
        {host: nil}
      end
    end

    # Custom method to retrieve associated projects
    def projects
      case taggable
      when GitLabProject
        taggable.projects
      when GitHubRepository
        taggable.projects
      else
        []
      end
    end

    def refresh
      case taggable
      when GithubRepository
        # GitHub logic remains unchanged
        api_client = taggable.github_instance.api_client
        tag_data = api_client.tags(taggable.path_with_namespace).find { |t| t[:name] == name }
        raise "Tag #{name} not found" unless tag_data

        if tag_data[:commit][:sha]
          begin
            detailed_tag_data = api_client.get("/repos/#{taggable.path_with_namespace}/git/tags/#{tag_data[:commit][:sha]}")
            update_tag_from_data(detailed_tag_data)
          rescue Octokit::NotFound
            commit_data = api_client.commit(taggable.path_with_namespace, tag_data[:commit][:sha])
            update_tag_from_commit_data(commit_data)
          end
        else
          Rails.logger.warn("Tag #{name} for #{taggable.class.name} has no associated SHA.")
        end
      when GitlabProject
        api_client = taggable.gitlab_instance.api_client
        tag_data = api_client.tag(taggable.path_with_namespace, name).to_h
        raise "Tag #{name} not found" unless tag_data

        commit_sha = tag_data.dig("commit", "id")
        tagged_at = tag_data.dig("commit", "committed_date") || tag_data["created_at"]

        if commit_sha.nil?
          # Handle lightweight tag
          Rails.logger.info("Tag #{name} appears to be lightweight. Fetching associated commit.")
          commit_sha = fetch_commit_for_lightweight_tag(api_client, taggable.path_with_namespace, name)
          tagged_at ||= Time.now
        end
        raise "Commit SHA missing for tag #{name}" unless commit_sha

        # Ensure the commit exists
        commit = RemoteGit::Commit.find_or_create_by!(sha: commit_sha) do |c|
          c.refresh
        end

        update!(
          commit: commit,
          tagged_at: tagged_at
        )
        Rails.logger.info("Tag #{name} updated successfully for GitLab project.")
      else
        raise NotImplementedError, "Refresh not supported for #{taggable.class.name}"
      end
    rescue => e
      Rails.logger.error("Failed to refresh tag #{id}: #{e.message}")
    end

    private

    def fetch_commit_for_lightweight_tag(api_client, namespace, tag_name)
      commit_data = api_client.commit(namespace, tag_name).to_h
      commit_data["id"]
    rescue => e
      Rails.logger.error("Failed to fetch commit for lightweight tag #{tag_name}: #{e.message}")
      nil
    end

    def create_issue_relationships
      related_commit = commit&.message
      self.issues = scan_for_issue_references(description, related_commit)
    end
  end
end

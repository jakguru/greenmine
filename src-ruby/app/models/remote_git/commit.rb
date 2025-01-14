module RemoteGit
  class Commit < ActiveRecord::Base
    include FridayRemoteGitEntityHelper
    include Redmine::Acts::ActivityProvider
    include Redmine::Acts::Event
    self.table_name = "remote_git_commits"

    # Polymorphic association
    belongs_to :commitable, polymorphic: true
    has_many :remote_git_associations, as: :associable, dependent: :destroy
    has_many :issues, through: :remote_git_associations
    has_many :projects, through: :issues
    # has_many :projects, -> { distinct }, through: :commitable, source: :projects

    # Many-to-Many relationship with Branch
    has_and_belongs_to_many :branches, class_name: "RemoteGit::Branch", join_table: "remote_git_branches_commits"

    # One-to-Many relationship with Tags
    has_many :tags, class_name: "RemoteGit::Tag", dependent: :destroy

    # RemoteGit::Committer association
    belongs_to :committer, class_name: "RemoteGit::Committer", optional: true

    # RemoteGit::Pipeline association
    has_many :pipelines, class_name: "RemoteGit::Pipeline", foreign_key: "commit_id", dependent: :destroy

    # Validations
    validates :sha, presence: true, uniqueness: true
    validates :message, presence: true
    validates :author_name, presence: true
    validates :author_email, presence: true, format: {with: URI::MailTo::EMAIL_REGEXP}
    validates :commitable, presence: true

    after_save :create_issue_relationships

    acts_as_event datetime: :committed_at,
      title: proc { |commit| "Commit: #{commit.sha[0..6]}" },
      description: :message,
      author: :author,
      type: "remote-git-commit",
      url: nil

    acts_as_activity_provider type: "commits",
      timestamp: :committed_at,
      author_key: proc { |commit| commit.committer&.user_id },
      permission: :view_project,
      scope: proc { joins(:projects).where("#{Project.table_name}.status = ?", Project::STATUS_ACTIVE) }

    # Relationships with parent and child commits via parent_sha
    def parent_commit
      RemoteGit::Commit.find_by(sha: parent_sha)
    end

    def child_commits
      RemoteGit::Commit.where(parent_sha: sha)
    end

    def author
      committer&.user
    end

    def url
      case commitable
      when GithubRepository
        {host: "#{commitable.web_url}/commit/#{sha}", port: nil, controller: "", action: ""}
      when GitlabRepository
        {host: "#{commitable.web_url}/-/commit/#{sha}", port: nil, controller: "", action: ""}
      else
        {host: nil}
      end
    end

    def refresh
      case commitable
      when GithubRepository
        api_client = commitable.github_instance.api_client
        commit_data = api_client.commit(commitable.path_with_namespace, sha)
        update_commit_from_data(commit_data)
      when GitlabProject
        api_client = commitable.gitlab_instance.api_client
        commit_data = api_client.commit(commitable.path_with_namespace, sha)
        update_commit_from_data(commit_data)
      else
        raise NotImplementedError, "Refresh not supported for #{commitable.class.name}"
      end
    rescue => e
      Rails.logger.error("Failed to refresh commit #{id}: #{e.message}")
    end

    private

    def update_commit_from_data(data)
      # Extract fields directly from the GitLab response
      update!(
        message: data.message,
        author_name: data.author_name,
        author_email: data.author_email,
        committed_at: data.committed_date
      )
      Rails.logger.info("Commit #{sha} updated successfully.")
    end

    def create_issue_relationships
      self.issues = scan_for_issue_references(message)
    end
  end
end

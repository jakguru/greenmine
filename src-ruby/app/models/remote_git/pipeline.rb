module RemoteGit
  class Pipeline < ActiveRecord::Base
    include FridayRemoteGitEntityHelper
    include Redmine::Acts::ActivityProvider
    self.table_name = "remote_git_pipelines"
    # Relationships
    belongs_to :branch, class_name: "RemoteGit::Branch", optional: true
    belongs_to :tag, class_name: "RemoteGit::Tag", optional: true
    belongs_to :merge_request, class_name: "RemoteGit::MergeRequest", optional: true
    belongs_to :commit, class_name: "RemoteGit::Commit"
    has_many :remote_git_associations, as: :associable, dependent: :destroy
    has_many :issues, through: :remote_git_associations
    has_many :projects, through: :issues

    # Validations
    validates :name, presence: true
    validates :remote_id, presence: true, uniqueness: true
    validates :commit, presence: true
    validates :remote_user, presence: true
    validates :start_time, presence: true
    validates :status, presence: true

    after_save :create_issue_relationships

    acts_as_activity_provider type: "pipelines_started",
      timestamp: :start_time,
      author_key: proc { |pipeline| pipeline.find_user_id }

    acts_as_activity_provider type: "pipelines_ended",
      timestamp: :end_time,
      author_key: proc { |pipeline| pipeline.find_user_id },
      scope: proc {
        select("#{table_name}.*, #{table_name}.status AS end_status")
      }

    # Custom method to retrieve associated projects
    def projects
      # Get projects through branch or tag, falling back to the commit's projects
      return branch.projects if branch
      return tag.projects if tag

      commit.projects
    end

    # Utility method for checking pipeline duration
    def duration
      return nil unless end_time

      end_time - start_time
    end

    # Utility method to check if the pipeline is still running
    def running?
      status == "running"
    end

    def refresh
      case branch&.branchable || tag&.taggable || commit&.commitable
      when GithubRepository
        api_client = branch&.branchable&.github_instance&.api_client || tag&.taggable&.github_instance&.api_client || commit&.commitable&.github_instance&.api_client
        pipeline_data = api_client.get("/repos/#{branch&.branchable&.path_with_namespace || tag&.taggable&.path_with_namespace || commit&.commitable&.path_with_namespace}/actions/runs/#{remote_id}")
        update_pipeline_from_data(pipeline_data)
      when GitlabProject
        api_client = branch&.branchable&.gitlab_instance&.api_client || tag&.taggable&.gitlab_instance&.api_client || commit&.commitable&.gitlab_instance&.api_client
        pipeline_data = api_client.pipeline(branch&.branchable&.path_with_namespace || tag&.taggable&.path_with_namespace || commit&.commitable&.path_with_namespace, remote_id)
        update_pipeline_from_data(format_gitlab_pipeline_data(pipeline_data))
      else
        raise NotImplementedError, "Refresh not supported for #{branchable.class.name}"
      end
    rescue => e
      Rails.logger.error("Failed to refresh pipeline #{id}: #{e.message}")
    end

    private

    def update_pipeline_from_data(data)
      update!(
        name: data[:name] || "Pipeline #{data[:id]}",
        start_time: data[:start_time],
        end_time: data[:end_time],
        status: data[:status],
        remote_user: data[:remote_user]
      )
      Rails.logger.info("Pipeline #{id} updated successfully.")
    end

    def format_gitlab_pipeline_data(data)
      {
        id: data.id,
        name: "Pipeline #{data.id}", # GitLab pipelines may not have a name
        start_time: data.created_at,
        end_time: data.updated_at || data.finished_at,
        status: data.status,
        remote_user: data.user&.id # Adjust to match GitLab's structure
      }
    end

    def create_issue_relationships
      issues = []

      # Scan for issues in the pipeline's own fields
      issues += scan_for_issue_references(name)

      # Include issues referenced in related commits
      if commits.any?
        commit_issues = commits.flat_map { |commit| scan_for_issue_references(commit.message) }
        issues += commit_issues
      end

      # Include issues referenced in related branches
      if branches.any?
        branch_issues = branches.flat_map { |branch| scan_for_issue_references(branch.name) }
        issues += branch_issues
      end

      # Include issues referenced in related tags/releases
      if tags.any?
        tag_issues = tags.flat_map { |tag| scan_commit_message_for_tag_issues(tag) }
        issues += tag_issues
      end
      if releases.any?
        release_issues = releases.flat_map { |release| scan_for_issue_references(release.description) }
        release_issues += releases.flat_map { |release| scan_commit_message_for_tag_issues(release.tag) if release.tag }
        issues += release_issues
      end

      # Ensure issues are unique and assign them to the pipeline
      self.issues = issues.uniq
    end

    # Scan commit messages of tags for issues
    def scan_commit_message_for_tag_issues(tag)
      return [] unless tag&.commit

      scan_for_issue_references(tag.commit.message)
    end

    def find_user_id
      branch&.gitlab_user&.user_id ||
        branch&.github_user&.user_id ||
        tag&.gitlab_user&.user_id ||
        tag&.github_user&.user_id ||
        merge_request&.gitlab_user&.user_id ||
        merge_request&.github_user&.user_id ||
        commit&.committer&.user_id
    end
  end
end

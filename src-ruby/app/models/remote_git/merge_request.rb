module RemoteGit
  class MergeRequest < ActiveRecord::Base
    self.table_name = "remote_git_merge_requests"
    # Polymorphic association
    belongs_to :merge_requestable, polymorphic: true
    belongs_to :closing_commit, class_name: "RemoteGit::Commit", optional: true

    # Branch associations
    belongs_to :source_branch, class_name: "RemoteGit::Branch"
    belongs_to :target_branch, class_name: "RemoteGit::Branch"

    has_many :pipelines, class_name: "RemoteGit::Pipeline", foreign_key: "merge_request_id", dependent: :destroy

    # Validations
    validates :title, presence: true
    validates :state, presence: true
    validates :remote_id, presence: true
    validates :source_branch, presence: true
    validates :target_branch, presence: true

    # Custom method to retrieve projects
    def projects
      case merge_requestable
      when GitLabProject
        merge_requestable.projects
      when GitHubRepository
        merge_requestable.projects
      else
        []
      end
    end

    # Convenience method for checking mergeability
    def mergeable?
      can_merge
    end

    def refresh
      case merge_requestable
      when GithubRepository
        api_client = merge_requestable.github_instance.api_client
        Rails.logger.info("Fetching GitHub pull request for repo: #{merge_requestable.path_with_namespace}, PR number: #{remote_id}")
        mr_data = api_client.pull_request(merge_requestable.path_with_namespace, remote_id.to_i)
        update_merge_request_from_data(mr_data)
      when GitlabProject
        api_client = merge_requestable.gitlab_instance.api_client
        project_id = merge_requestable.project_id # Use numerical project ID
        Rails.logger.info("Fetching GitLab merge request for project ID: #{project_id}, MR IID: #{remote_id}")
        # Use remote_id as the merge request IID
        mr_data = api_client.merge_request(project_id, remote_id.to_i)
        update_merge_request_from_data(mr_data)
      else
        raise NotImplementedError, "Refresh not supported for #{merge_requestable.class.name}"
      end
    rescue => e
      Rails.logger.error("Failed to refresh merge request #{id}: #{e.message}")
    end

    private

    def update_merge_request_from_data(data)
      Rails.logger.info("Updating merge request with data: #{data.inspect}")
      update!(
        title: data.title,
        state: data.state,
        description: data.description || data.body,
        merged_at: data.merged_at,
        can_merge: data.merge_status == "can_be_merged"
      )
      Rails.logger.info("MergeRequest #{remote_id} updated successfully.")
    end
  end
end

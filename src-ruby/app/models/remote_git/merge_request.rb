module RemoteGit
  class MergeRequest < ActiveRecord::Base
    self.table_name = "remote_git_merge_requests"
    # Polymorphic association
    belongs_to :merge_requestable, polymorphic: true
    belongs_to :closing_commit, class_name: "RemoteGit::Commit", optional: true

    # Branch associations
    belongs_to :source_branch, class_name: "RemoteGit::Branch"
    belongs_to :target_branch, class_name: "RemoteGit::Branch"

    # Validations
    validates :title, presence: true
    validates :state, presence: true
    validates :remote_id, presence: true, uniqueness: true
    validates :author_name, presence: true
    validates :author_email, presence: true, format: {with: URI::MailTo::EMAIL_REGEXP}
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
  end
end

module RemoteGit
  class Branch < ActiveRecord::Base
    self.table_name = "remote_git_branches"
    # Polymorphic association
    belongs_to :branchable, polymorphic: true
    has_many :remote_git_associations, as: :associable, dependent: :destroy
    has_many :issues, through: :remote_git_associations
    has_many :projects, through: :issues

    # Many-to-Many relationship with Commits
    has_and_belongs_to_many :commits, class_name: "RemoteGit::Commit", join_table: "remote_git_branches_commits"

    has_many :pipelines, class_name: "RemoteGit::Pipeline", foreign_key: "branch_id", dependent: :destroy

    # Validations
    validates :name, presence: true
    validates :branchable, presence: true

    include FridayRemoteGitEntityHelper

    after_save :create_issue_relationships

    # Psuedo Association with Projects
    def projects
      case branchable
      when GitLabProject
        branchable.projects
      when GitHubRepository
        branchable.projects
      else
        []
      end
    end

    private

    def create_issue_relationships
      self.issues = scan_for_issue_references(name)
    end
  end
end

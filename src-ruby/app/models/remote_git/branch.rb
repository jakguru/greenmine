module RemoteGit
  class Branch < ActiveRecord::Base
    self.table_name = "remote_git_branches"
    # Polymorphic association
    belongs_to :branchable, polymorphic: true

    # Many-to-Many relationship with Commits
    has_and_belongs_to_many :commits, class_name: "RemoteGit::Commit", join_table: "remote_git_branches_commits"

    has_many :pipelines, class_name: "RemoteGit::Pipeline", foreign_key: "branch_id", dependent: :destroy

    # Validations
    validates :name, presence: true
    validates :branchable, presence: true

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
  end
end

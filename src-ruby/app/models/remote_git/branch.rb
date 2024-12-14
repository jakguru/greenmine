module RemoteGit
  class Branch < ActiveRecord::Base
    self.table_name = "remote_git_branches"
    # Polymorphic association
    belongs_to :branchable, polymorphic: true

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

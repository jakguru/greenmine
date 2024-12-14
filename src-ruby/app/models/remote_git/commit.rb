module RemoteGit
  class Commit < ActiveRecord::Base
    self.table_name = "remote_git_commits"
    # Polymorphic association
    belongs_to :commitable, polymorphic: true

    # Many-to-Many relationship with Branch
    has_and_belongs_to_many :branches, class_name: "RemoteGit::Branch", join_table: "remote_git_branches_commits"

    # One-to-Many relationship with Tags
    has_many :tags, class_name: "RemoteGit::Tag", dependent: :destroy

    # Self-referential association for parent commit
    belongs_to :parent_commit, class_name: "RemoteGit::Commit", optional: true
    has_many :child_commits, class_name: "RemoteGit::Commit", foreign_key: "parent_commit_id", dependent: :nullify

    # Validations
    validates :sha, presence: true, uniqueness: true
    validates :message, presence: true
    validates :author_name, presence: true
    validates :author_email, presence: true, format: {with: URI::MailTo::EMAIL_REGEXP}
    validates :remote_user, presence: true
    validates :commitable, presence: true

    # Custom method to retrieve projects
    def projects
      case commitable
      when GitLabProject
        commitable.projects
      when GitHubRepository
        commitable.projects
      else
        []
      end
    end
  end
end

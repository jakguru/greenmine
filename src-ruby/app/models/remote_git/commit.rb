module RemoteGit
  class Commit < ActiveRecord::Base
    self.table_name = "remote_git_commits"

    # Polymorphic association
    belongs_to :commitable, polymorphic: true

    # Many-to-Many relationship with Branch
    has_and_belongs_to_many :branches, class_name: "RemoteGit::Branch", join_table: "remote_git_branches_commits"

    # One-to-Many relationship with Tags
    has_many :tags, class_name: "RemoteGit::Tag", dependent: :destroy

    # RemoteGit::Committer association
    belongs_to :committer, class_name: "RemoteGit::Committer", optional: true

    # Validations
    validates :sha, presence: true, uniqueness: true
    validates :message, presence: true
    validates :author_name, presence: true
    validates :author_email, presence: true, format: {with: URI::MailTo::EMAIL_REGEXP}
    validates :commitable, presence: true

    # Relationships with parent and child commits via parent_sha
    def parent_commit
      RemoteGit::Commit.find_by(sha: parent_sha)
    end

    def child_commits
      RemoteGit::Commit.where(parent_sha: sha)
    end
  end
end

module RemoteGit
  class Committer < ActiveRecord::Base
    self.table_name = "remote_git_committers"

    # Association with Redmine user
    belongs_to :user, class_name: "User", optional: true

    # Validations
    validates :name, presence: true
    validates :email, presence: true, format: {with: URI::MailTo::EMAIL_REGEXP}

    # Reverse association with commits
    has_many :commits, class_name: "RemoteGit::Commit", foreign_key: "committer_id", dependent: :nullify
  end
end

module RemoteGit
  class Tag < ActiveRecord::Base
    self.table_name = "remote_git_tags"
    # Relationships
    belongs_to :commit, class_name: "RemoteGit::Commit"
    belongs_to :taggable, polymorphic: true

    # Validations
    validates :name, presence: true
    validates :tagged_at, presence: true
    validates :author_name, presence: true
    validates :author_email, presence: true, format: {with: URI::MailTo::EMAIL_REGEXP}
    validates :commit, presence: true

    # Custom method to retrieve projects
    def projects
      case taggable
      when GitLabProject
        taggable.projects
      when GitHubRepository
        taggable.projects
      else
        []
      end
    end
  end
end

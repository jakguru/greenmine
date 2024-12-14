module RemoteGit
  class Release < ActiveRecord::Base
    self.table_name = "remote_git_releases"
    # Associations
    belongs_to :tag, class_name: "RemoteGit::Tag"
    has_and_belongs_to_many :versions, class_name: "Version", join_table: "remote_git_releases_versions"

    # Validations
    validates :name, presence: true
    validates :released_at, presence: true
    validates :tag, presence: true

    # Custom method to retrieve projects (optional if needed)
    def projects
      case tag.taggable
      when GitLabProject
        tag.taggable.projects
      when GitHubRepository
        tag.taggable.projects
      else
        []
      end
    end
  end
end

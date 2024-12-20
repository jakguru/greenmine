module RemoteGit
  class Tag < ActiveRecord::Base
    self.table_name = "remote_git_tags"

    # Polymorphic association
    belongs_to :taggable, polymorphic: true

    # Association with the commit that the tag points to
    belongs_to :commit, class_name: "RemoteGit::Commit"

    # Association with the committer
    belongs_to :committer, class_name: "RemoteGit::Committer", optional: true

    # Validations
    validates :name, presence: true
    validates :remote_id, presence: true, uniqueness: true
    validates :commit, presence: true
    validates :taggable, presence: true

    # Ensure uniqueness at the model level as well
    validates :name, uniqueness: {scope: [:taggable_type, :taggable_id]}

    # Self-referential logic for parent tags
    def parent_commit
      RemoteGit::Commit.find_by(sha: parent_sha) if parent_sha.present?
    end

    # Custom method to retrieve associated projects
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

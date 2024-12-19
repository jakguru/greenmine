module RemoteGit
  class Pipeline < ActiveRecord::Base
    self.table_name = "remote_git_pipelines"
    # Relationships
    belongs_to :branch, class_name: "RemoteGit::Branch", optional: true
    belongs_to :tag, class_name: "RemoteGit::Tag", optional: true
    belongs_to :merge_request, class_name: "RemoteGit::MergeRequest", optional: true
    belongs_to :commit, class_name: "RemoteGit::Commit"

    # Validations
    validates :name, presence: true
    validates :commit, presence: true
    validates :remote_user, presence: true
    validates :start_time, presence: true
    validates :status, presence: true

    # Custom method to retrieve associated projects
    def projects
      # Get projects through branch or tag, falling back to the commit's projects
      return branch.projects if branch
      return tag.projects if tag

      commit.projects
    end

    # Utility method for checking pipeline duration
    def duration
      return nil unless end_time

      end_time - start_time
    end

    # Utility method to check if the pipeline is still running
    def running?
      status == "running"
    end
  end
end

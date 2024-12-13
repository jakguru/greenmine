require_dependency "project"

module FridayPlugin
  module ProjectPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        has_many :project_gitlab_projects, class_name: "ProjectGitlabProject", foreign_key: "project_id"
        has_many :gitlab_projects, through: :project_gitlab_projects
        has_many :project_github_repositories, class_name: "ProjectGithubRepository", foreign_key: "project_id"
        has_many :github_repositories, through: :project_github_repositories
        has_one :monday_board, class_name: "MondayBoard", foreign_key: "project_id"
        safe_attributes "avatar"
        safe_attributes "banner"

        def self.possible_modules
          # call the original method first
          super - %w[boards repository]
        end
      end
    end

    module InstanceMethods
    end
  end
end

Project.send(:include, FridayPlugin::ProjectPatch) unless Project.included_modules.include?(FridayPlugin::ProjectPatch)

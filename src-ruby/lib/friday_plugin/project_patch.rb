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
        # Access all branches through GitLab projects and GitHub repositories
        has_many :remote_git_branches, through: :gitlab_projects, source: :branches
        has_many :remote_git_branches, through: :github_repositories, source: :branches

        # Access all commits through GitLab projects and GitHub repositories
        has_many :remote_git_commits, through: :gitlab_projects, source: :commits
        has_many :remote_git_commits, through: :github_repositories, source: :commits

        # Access all merge requests through GitLab projects and GitHub repositories
        has_many :remote_git_merge_requests, through: :gitlab_projects, source: :merge_requests
        has_many :remote_git_merge_requests, through: :github_repositories, source: :merge_requests

        # Access all tags through GitLab projects and GitHub repositories
        has_many :remote_git_tags, through: :gitlab_projects, source: :tags
        has_many :remote_git_tags, through: :github_repositories, source: :tags

        # Access all releases through GitLab projects and GitHub repositories
        has_many :remote_git_releases, through: :gitlab_projects, source: :releases
        has_many :remote_git_releases, through: :github_repositories, source: :releases

        # Access all pipelines through GitLab projects and GitHub repositories
        has_many :remote_git_pipelines, through: :gitlab_projects, source: :pipelines
        has_many :remote_git_pipelines, through: :github_repositories, source: :pipelines

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

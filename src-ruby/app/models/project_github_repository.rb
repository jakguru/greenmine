class ProjectGithubRepository < ActiveRecord::Base
  self.table_name = "project_github_repository"
  belongs_to :project
  belongs_to :github_repository

  validates :project_id, presence: true
  validates :github_repository_id, presence: true
end

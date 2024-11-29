class ProjectGitlabProject < ActiveRecord::Base
  self.table_name = "project_gitlab_project"
  belongs_to :project
  belongs_to :gitlab_project

  validates :project_id, presence: true
  validates :gitlab_project_id, presence: true
end

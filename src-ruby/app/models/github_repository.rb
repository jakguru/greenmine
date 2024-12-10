class GithubRepository < ActiveRecord::Base
  include Redmine::SafeAttributes
  # Associations
  belongs_to :github_instance, class_name: "GithubInstance", foreign_key: "github_id"
  has_many :project_repositories, class_name: "ProjectGithubRepository", foreign_key: "github_project_id"
  has_many :projects, through: :project_repositories

  # Validations
  validates :github_id, presence: true
  validates :project_id, presence: true  # This represents the GitLab API project ID
  validates :name, presence: true
  validates :name_with_namespace, presence: true
  validates :path, presence: true
  validates :path_with_namespace, presence: true

  def safe_attribute?(attribute)
    # You can add more complex logic here based on attribute security, but for now, return true for all attributes
    true
  end

  def projects=(projects)
    set_associated_projects(projects)
  end

  def set_associated_projects(projects)
    existing_projects = self.projects
    # Remove any projects that are no longer associated
    existing_projects.each do |project|
      if !projects.any? { |p| p.id == project.id }
        project_github_project = ProjectGithubRepository.where(project_id: project.id, github_project_id: self[:id]).first
        project_github_project.destroy
      end
    end
    # Add any new projects
    projects.each do |project|
      if !existing_projects.any? { |p| p.id == project.id }
        project_github_project = ProjectGithubRepository.new(project_id: project.id, github_project_id: self[:id])
        project_github_project.save
      end
    end
    ActionCable.server.broadcast("rtu_project_github_project", {github_instance_id: github_instance.id, github_project_id: self[:id]})
  end
end

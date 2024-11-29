class GitlabProject < ActiveRecord::Base
  include Redmine::SafeAttributes
  # Associations
  belongs_to :gitlab_instance, class_name: "GitlabInstance", foreign_key: "gitlab_id"
  has_many :project_gitlab_projects, class_name: "ProjectGitlabProject", foreign_key: "gitlab_project_id"
  has_many :projects, through: :project_gitlab_projects

  # Validations
  validates :gitlab_id, presence: true
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
        project_gitlab_project = ProjectGitlabProject.where(project_id: project.id, gitlab_project_id: self[:id]).first
        project_gitlab_project.destroy
      end
    end
    # Add any new projects
    projects.each do |project|
      if !existing_projects.any? { |p| p.id == project.id }
        project_gitlab_project = ProjectGitlabProject.new(project_id: project.id, gitlab_project_id: self[:id])
        project_gitlab_project.save
      end
    end
    ActionCable.server.broadcast("rtu_project_gitlab_project", {gitlab_instance_id: gitlab_instance.id, gitlab_project_id: self[:id]})
  end

  def web_url
    "#{gitlab_instance.url}/#{path_with_namespace}"
  end

  def git_http_url
    "#{gitlab_instance.url}/#{path_with_namespace}.git"
  end

  def git_ssh_url
    "git@#{gitlab_instance.url.sub("https://", "")}:#{path_with_namespace}.git"
  end

  def remote_info
    client = gitlab_instance.api_client
    client.project(self[:project_id])
  end
end

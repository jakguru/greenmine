class GithubRepository < ActiveRecord::Base
  include Redmine::SafeAttributes
  # Associations
  belongs_to :github_instance, class_name: "GithubInstance", foreign_key: "github_id"
  has_many :project_repositories, class_name: "ProjectGithubRepository", foreign_key: "github_repository_id"
  has_many :projects, through: :project_repositories

  # Validations
  validates :github_id, presence: true
  validates :repository_id, presence: true  # This represents the Gitlab API project ID
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
        project_github_repository = ProjectGithubRepository.where(project_id: project.id, github_repository_id: self[:id]).first
        project_github_repository.destroy
      end
    end
    # Add any new projects
    projects.each do |project|
      if !existing_projects.any? { |p| p.id == project.id }
        project_github_repository = ProjectGithubRepository.new(project_id: project.id, github_repository_id: self[:id])
        project_github_repository.save
      end
    end
    ActionCable.server.broadcast("rtu_project_github_repository", {github_instance_id: github_instance.id, github_repository_id: self[:id]})
  end

  def web_url
    "https://github.com/#{path_with_namespace}"
  end

  def git_http_url
    "https://github.com/#{path_with_namespace}.git"
  end

  def git_ssh_url
    "git@github.com:#{path_with_namespace}.git"
  end

  def remote_info
    client = github_instance.api_client
    client.repository(self[:repository_id]).to_h
  end

  def do_process_webhook(params, headers)
    Rails.logger.info("Processing GitHub Webhook for repository #{name} in GitHub account #{github_instance.name}")
    # TODO: Implement webhook processing logic here
  end
end

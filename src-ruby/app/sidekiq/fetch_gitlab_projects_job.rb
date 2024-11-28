class FetchGitlabProjectsJob
  include Sidekiq::Job

  def perform(id)
    gitlab = GitlabInstance.find(id)
    api_client = gitlab.api_client
    api_client.projects(membership: true).auto_paginate do |project|
      gitlab_instance_project = GitlabProject.find_by(gitlab_id: gitlab.id, project_id: project.id)
      if gitlab_instance_project.nil?
        gitlab_instance_project = GitlabProject.new(
          gitlab_id: gitlab.id,
          project_id: project.id,
          name: project.name,
          name_with_namespace: project.name_with_namespace,
          path: project.path,
          path_with_namespace: project.path_with_namespace
        )
      end
      gitlab_instance_project.name = project.name
      gitlab_instance_project.name_with_namespace = project.name_with_namespace
      gitlab_instance_project.path = project.path
      gitlab_instance_project.path_with_namespace = project.path_with_namespace
      gitlab_instance_project.save!
    end
    ActionCable.server.broadcast("rtu_gitlab_instance_projects", {gitlab_instance_id: gitlab.id})
  end
end

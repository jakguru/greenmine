class FetchGitlabUsersJob
  include Sidekiq::Job

  def perform(id)
    gitlab = GitlabInstance.find(id)
    api_client = gitlab.api_client
    gitlab_group_ids = []
    gitlab_user_ids = []
    gitlab_users_by_id = {}
    api_client.projects(membership: true).auto_paginate do |project|
      if project.namespace.kind == "group"
        if !gitlab_group_ids.include?(project.namespace.id)
          gitlab_group_ids << project.namespace.id
        end
      elsif project.namespace.kind == "user"
        if !gitlab_user_ids.include?(project.namespace.id)
          gitlab_user_ids << project.namespace.id
        end
      end
    end
    gitlab_group_ids.each do |group_id|
      api_client.group_members(group_id).auto_paginate do |user|
        gitlab_users_by_id[user.id] = user
      end
    end
    gitlab_user_ids.each do |user_id|
      if !gitlab_users_by_id.has_key?(user_id)
        gitlab_user = api_client.user(user_id)
        gitlab_users_by_id[gitlab_user.id] = gitlab_user
      end
    end
    gitlab_users_by_id.each do |user_id, user|
      gitlab_user = GitlabUser.find_by(gitlab_id: gitlab.id, user_id: user_id)
      if gitlab_user.nil?
        gitlab_user = GitlabUser.new(
          gitlab_id: gitlab.id,
          user_id: user_id,
          name: user.name,
          username: user.username
        )
      end
      gitlab_user.name = user.name
      gitlab_user.username = user.username
      gitlab_user.save!
    end
    Rails.logger.info(gitlab_users_by_id.inspect)
    ActionCable.server.broadcast("rtu_gitlab_instance_users", {gitlab_instance_id: gitlab.id})
  end
end

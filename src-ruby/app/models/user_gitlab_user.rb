class UserGitlabUser < ActiveRecord::Base
  self.table_name = "user_gitlab_users"
  belongs_to :user
  belongs_to :gitlab_user

  validates :user_id, presence: true
  validates :gitlab_user_id, presence: true
end

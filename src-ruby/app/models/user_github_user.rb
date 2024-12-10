class UserGithubUser < ActiveRecord::Base
  self.table_name = "user_github_users"
  belongs_to :user
  belongs_to :github_user

  validates :user_id, presence: true
  validates :github_user_id, presence: true
end

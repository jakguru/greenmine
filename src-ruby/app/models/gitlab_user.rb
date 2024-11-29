class GitlabUser < ActiveRecord::Base
  include Redmine::SafeAttributes
  # Associations
  belongs_to :gitlab_instance, class_name: "GitlabInstance", foreign_key: "gitlab_id"
  has_many :user_gitlab_users, class_name: "UserGitlabUser", foreign_key: "gitlab_user_id"
  has_many :users, through: :user_gitlab_users

  # Validations
  validates :gitlab_id, presence: true
  validates :user_id, presence: true  # This represents the GitLab API user ID
  validates :username, presence: true
  validates :name, presence: true

  def safe_attribute?(attribute)
    # You can add more complex logic here based on attribute security, but for now, return true for all attributes
    true
  end

  def redmine_user
    users.first
  end

  def redmine_user=(redmine_user_id)
    set_redmine_user(redmine_user_id)
  end

  def set_redmine_user(redmine_user_id)
    user_gitlab_user = UserGitlabUser.where(gitlab_user_id: self[:id]).first
    if user_gitlab_user.nil?
      user_gitlab_user = UserGitlabUser.new(gitlab_user_id: self[:id])
    elsif redmine_user_id.nil?
      user_gitlab_user.destroy!
      return true
    end
    user_gitlab_user.user_id = redmine_user_id
    user_gitlab_user.save!
  end
end

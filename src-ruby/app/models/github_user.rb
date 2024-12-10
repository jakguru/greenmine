class GithubUser < ActiveRecord::Base
  include Redmine::SafeAttributes
  # Associations
  belongs_to :github_instance, class_name: "GithubInstance", foreign_key: "github_id"
  has_many :user_github_users, class_name: "UserGithubUser", foreign_key: "github_user_id"
  has_many :users, through: :user_github_users

  # Validations
  validates :github_id, presence: true
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
    user_github_user = UserGithubUser.where(github_user_id: self[:id]).first
    if user_github_user.nil?
      user_github_user = UserGithubUser.new(github_user_id: self[:id])
    elsif redmine_user_id.nil?
      user_github_user.destroy!
      return true
    end
    user_github_user.user_id = redmine_user_id
    user_github_user.save!
  end
end

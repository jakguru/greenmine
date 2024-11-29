# require "gitlab"

class GitlabInstance < ActiveRecord::Base
  self.table_name = "gitlabs"
  include Redmine::SafeAttributes
  # Associations
  has_many :gitlab_projects, dependent: :destroy, class_name: "GitlabProject", foreign_key: "gitlab_id"
  has_many :gitlab_users, dependent: :destroy, class_name: "GitlabUser", foreign_key: "gitlab_id"

  # Validations
  validates :name, presence: true
  validates :url, presence: true
  validates :api_token, presence: true

  # Scopes
  scope :active, -> { where(active: true) }

  def safe_attribute?(attribute)
    # You can add more complex logic here based on attribute security, but for now, return true for all attributes
    true
  end

  # Method to provide an instance of the GitLab API client
  def api_client
    raise "GitLab instance is disabled" unless active

    ::Gitlab.client(endpoint: "#{url}/api/v4", private_token: api_token)
  end
end

# require "github"

class GithubInstance < ActiveRecord::Base
  self.table_name = "githubs"
  include Redmine::SafeAttributes
  # Associations
  has_many :github_repositories, dependent: :destroy, class_name: "GithubRepository", foreign_key: "github_id"
  has_many :github_users, dependent: :destroy, class_name: "GithubUser", foreign_key: "github_id"

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
  # def api_client
  #   raise "GitLab instance is disabled" unless active

  #   ::Github.client(endpoint: "#{url}/api/v4", private_token: api_token)
  # end
end

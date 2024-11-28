class GitlabProject < ActiveRecord::Base
  include Redmine::SafeAttributes
  # Associations
  belongs_to :gitlab_instance, class_name: "GitlabInstance", foreign_key: "gitlab_id"

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
end

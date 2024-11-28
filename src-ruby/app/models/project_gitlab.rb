class ProjectGitlab < ActiveRecord::Base
  include Redmine::SafeAttributes
  # Associations
  belongs_to :gitlab
  belongs_to :project

  # Validations
  validates :gitlab_id, presence: true
  validates :project_id, presence: true

  def safe_attribute?(attribute)
    # You can add more complex logic here based on attribute security, but for now, return true for all attributes
    true
  end
end

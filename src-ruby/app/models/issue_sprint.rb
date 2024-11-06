class IssueSprint < ActiveRecord::Base
  before_create :check_assign_permission
  before_destroy :check_unassign_permission

  after_create :push_on_create
  after_destroy :push_on_destroy

  belongs_to :issue
  belongs_to :sprint

  validates :issue_id, presence: true
  validates :sprint_id, presence: true

  private

  # Check if the user has permission to assign the issue to the sprint
  def check_assign_permission
    unless User.current.admin? || User.current.allowed_to?(:assign_to_sprint, issue.project)
      errors.add(:base, "You do not have permission to assign this issue to a sprint.")
      throw(:abort)
    end
  end

  # Check if the user has permission to unassign the issue from the sprint
  def check_unassign_permission
    unless User.current.admin? || User.current.allowed_to?(:unassign_from_sprint, issue.project)
      errors.add(:base, "You do not have permission to unassign this issue from the sprint.")
      throw(:abort)
    end
  end

  # After create hook to push updates on create
  def push_on_create
    FridayPlugin::IssuesChannel.broadcast_to(issue, issue)
    FridayPlugin::SprintsChannel.broadcast_to(sprint, sprint)
  end

  # After destroy hook to push updates on destroy
  def push_on_destroy
    FridayPlugin::IssuesChannel.broadcast_to(issue, issue)
    FridayPlugin::SprintsChannel.broadcast_to(sprint, sprint)
    FridayPlugin::SprintsChannel.broadcast_to(Sprint.backlog, Sprint.backlog)
  end
end

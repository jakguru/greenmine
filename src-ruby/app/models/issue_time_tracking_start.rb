class IssueTimeTrackingStart < ActiveRecord::Base
  belongs_to :issue
  belongs_to :user

  validates :start_time, presence: true
  validates :activity_id, presence: true

  # Ensures that the activity_id corresponds to a valid TimeEntryActivity enumeration
  validate :valid_activity

  private

  def valid_activity
    activity = Enumeration.find_by(id: activity_id, type: "TimeEntryActivity")
    errors.add(:activity_id, "is not a valid activity") unless activity
  end
end

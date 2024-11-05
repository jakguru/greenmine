class Sprint < ActiveRecord::Base
  include Redmine::SafeAttributes
  has_many :issue_sprints, dependent: :destroy
  has_many :issues, through: :issue_sprints

  validates :name, :start_date, :end_date, presence: true
  validate :no_overlap, :dates_consistency

  # Hook to call after save
  # after_save :trigger_sprint_webhook

  def self.backlog
    BacklogSprint.new
  end

  def self.backlog_hashed
    BacklogSprint.new.to_hash
  end

  # Check sprint overlap
  def no_overlap
    # overlapping_sprints = Sprint.where('(start_date <= ? AND end_date >= ?) OR (start_date <= ? AND end_date >= ?)', start_date, start_date, end_date, end_date)
    # errors.add(:base, 'Sprints cannot overlap') if overlapping_sprints.exists?
  end

  # Check start/end date consistency
  def dates_consistency
    errors.add(:end_date, "must be after the start date") if start_date >= end_date
  end

  def total_estimated_work
    # Use to_f to handle nil values
    issues.sum { |issue| issue.estimated_hours.to_f }
  end

  def total_time_logged
    # Sum the time entries for each issue and use to_f to handle nil values
    issues.sum { |issue| issue.time_entries.sum { |entry| entry.hours.to_f } }
  end

  def state
    if start_date > Date.today
      "New"
    elsif end_date < Date.today
      "Closed"
    else
      "Open"
    end
  end

  def visible?
    true
  end

  def to_hash
    {
      id: id,
      name: name,
      start_date: start_date,
      end_date: end_date,
      state: state,
      total_estimated_work: total_estimated_work,
      total_time_logged: total_time_logged
    }
  end

  def to_shallow_hash
    {
      id: id,
      name: name,
      start_date: start_date,
      end_date: end_date,
      state: state,
      total_estimated_work: total_estimated_work,
      total_time_logged: total_time_logged
    }
  end

  def safe_attribute?(attribute)
    # You can add more complex logic here based on attribute security, but for now, return true for all attributes
    true
  end

  private

  # # Trigger the sprint webhook after save
  # def trigger_sprint_webhook
  #   Redmine::Hook.call_hook(:sprint_after_save, {sprint: self})
  # end
end

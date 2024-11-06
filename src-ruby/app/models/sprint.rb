class Sprint < ActiveRecord::Base
  include Redmine::SafeAttributes
  has_many :issue_sprints, dependent: :destroy
  has_many :issues, through: :issue_sprints

  validates :name, :start_date, :end_date, presence: true
  validate :can_edit, :no_overlap, :dates_consistency

  # Hook to call after save
  # after_save :trigger_sprint_webhook
  after_save :push_realtime_update

  def self.backlog
    BacklogSprint.new
  end

  def self.backlog_hashed
    BacklogSprint.new.to_hash
  end

  def can_edit
    user.allowed_to?(:manage_sprints, nil, global: true) || user.admin?
  end

  # Check sprint overlap
  def no_overlap
    overlapping_sprints = Sprint.where.not(id: id)
      .where("(start_date < ? AND end_date > ?) OR (start_date < ? AND end_date > ?)", end_date, start_date, end_date, start_date)
    errors.add(:base, "Sprints cannot overlap") if overlapping_sprints.exists?
  end

  # Check start/end date consistency
  def dates_consistency
    errors.add(:end_date, "must be after the start date") if start_date >= end_date
  end

  def total_estimated_work
    estimated_and_worked_progress = get_progress
    estimated_and_worked_progress[:estimated].values.sum
  end

  def total_time_logged
    estimated_and_worked_progress = get_progress
    estimated_and_worked_progress[:worked].values.sum
  end

  def state
    if start_date > Date.today
      "sprint.state.future"
    elsif end_date < Date.today
      "sprint.state.closed"
    else
      "sprint.state.current"
    end
  end

  def visible?
    true
  end

  def progress
    estimated_and_worked_progress = get_progress
    total_estimated_hours = estimated_and_worked_progress[:estimated].values.sum
    total_logged_hours = estimated_and_worked_progress[:worked].values.sum
    total = [total_estimated_hours, total_logged_hours].max
    closed_estimatd_hours = estimated_and_worked_progress[:estimated]["closed"]
    closed_logged_hours = estimated_and_worked_progress[:worked]["closed"]
    closed = [closed_estimatd_hours, closed_logged_hours].max
    total.zero? ? 0 : (closed / total) * 100
  end

  def safe_attribute?(attribute)
    # You can add more complex logic here based on attribute security, but for now, return true for all attributes
    true
  end

  def get_progress
    estimated_hours_by_status = Hash.new(0.0)
    worked_hours_by_status = Hash.new(0.0)

    issues.each do |issue|
      hours_within_sprint = restrict_hours_within_sprint(issue)
      is_closed = issue.status.is_closed ? "closed" : "open"
      estimated_hours_by_status[is_closed] += hours_within_sprint[:estimated_hours]
      worked_hours_by_status[is_closed] += hours_within_sprint[:logged_hours]
    end

    {
      estimated: estimated_hours_by_status,
      worked: worked_hours_by_status
    }
  end

  def next_sprint_id
    if is_a?(BacklogSprint)
      return Sprint.order(start_date: :asc).first&.id || 0
    end
    Sprint.where("start_date >= ?", end_date.to_date).order(start_date: :asc).first&.id || 0
  end

  def previous_sprint_id
    if is_a?(BacklogSprint)
      return Sprint.order(end_date: :desc).first&.id || 0
    end
    Sprint.where("end_date <= ?", start_date.to_date).order(end_date: :desc).first&.id || 0
  end

  def get_workload_allocation_by_role
    non_working_week_days = Setting.send(:non_working_week_days).map(&:to_i)
    assignable_hours_per_user = {}

    User.joins(memberships: :project).joins("LEFT JOIN groups_users ON groups_users.user_id = #{User.table_name}.id").joins("LEFT JOIN issues ON issues.assigned_to_id = groups_users.group_id")
      .where("#{User.table_name}.status = ?", User::STATUS_ACTIVE)
      .distinct
      .each do |user|
      assignable_hours = 0
      (start_date.to_date..end_date.to_date).each do |date|
        next if non_working_week_days.include?(date.wday)
        assignable_hours += 7 # assuming 7 working hours per working day
      end
      assignable_hours_per_user[user.id] = assignable_hours
    end

    # Calculate total hours logged by each user for the issues in the sprint
    hours_logged_per_user = issues.each_with_object(Hash.new(0)) do |issue, result|
      restrict_time_entries_within_sprint(issue).each do |time_entry|
        result[time_entry.user_id] += time_entry.hours.to_f || 0.0
      end
    end

    # Merge the data to get workload allocation by user
    assignable_hours_per_user.map do |user_id, assignable_hours|
      user = User.select(:id, :firstname, :lastname).find(user_id)
      hours_logged = hours_logged_per_user[user_id] || 0

      {
        user: {id: user.id, firstname: user.firstname, lastname: user.lastname},
        assignable_hours: assignable_hours,
        hours_logged: hours_logged
      }
    end
  end

  def get_breakdown_by_calculated_priority
    breakdown = {}

    issues.includes(:time_entries).group_by(&:calculated_priority).each do |priority, issues|
      total_estimated_hours = 0
      total_logged_hours = 0

      issues.each do |issue|
        hours_within_sprint = restrict_hours_within_sprint(issue)
        total_estimated_hours += hours_within_sprint[:estimated_hours]
        total_logged_hours += hours_within_sprint[:logged_hours]
      end

      breakdown[priority] = {
        total_estimated_hours: total_estimated_hours,
        total_logged_hours: total_logged_hours
      }
    end

    breakdown
  end

  def get_breakdown_by_tracker
    breakdown = {}

    issues.includes(:time_entries).group_by(&:tracker).each do |tracker, issues|
      total_estimated_hours = 0
      total_logged_hours = 0

      issues.each do |issue|
        hours_within_sprint = restrict_hours_within_sprint(issue)
        total_estimated_hours += hours_within_sprint[:estimated_hours]
        total_logged_hours += hours_within_sprint[:logged_hours]
      end

      breakdown[tracker.name] = {
        total_estimated_hours: total_estimated_hours,
        total_logged_hours: total_logged_hours
      }
    end

    breakdown
  end

  def get_breakdown_by_activity
    breakdown = {}

    issues.joins(:time_entries).each do |issue|
      restrict_time_entries_within_sprint(issue).each do |time_entry|
        next if time_entry.activity.nil?

        breakdown[time_entry.activity.name] ||= {total_estimated_hours: 0, total_logged_hours: 0}
        breakdown[time_entry.activity.name][:total_estimated_hours] += issue.estimated_hours.to_f if issue.estimated_hours
        breakdown[time_entry.activity.name][:total_logged_hours] += time_entry.hours.to_f
      end
    end

    breakdown
  end

  def get_breakdown_by_project
    breakdown = {}

    issues.includes(:time_entries, :project).group_by(&:project).each do |project, issues|
      total_estimated_hours = 0
      total_logged_hours = 0

      issues.each do |issue|
        hours_within_sprint = restrict_hours_within_sprint(issue)
        total_estimated_hours += hours_within_sprint[:estimated_hours]
        total_logged_hours += hours_within_sprint[:logged_hours]
      end

      breakdown[project.name] = {
        total_estimated_hours: total_estimated_hours,
        total_logged_hours: total_logged_hours
      }
    end

    breakdown
  end

  def get_releases
    issues.joins(:fixed_version).where(
      "#{Version.table_name}.effective_date BETWEEN ? AND ?",
      start_date, end_date
    ).distinct.collect(&:fixed_version)
  end

  def push_realtime_update
    FridayPlugin::SprintsChannel.broadcast_to(self, self)
  end

  private

  def restrict_hours_within_sprint(issue)
    non_working_week_days = Setting.send(:non_working_week_days).map(&:to_i)
    issue_start_date = issue.start_date.nil? ? start_date.to_date : [issue.start_date.to_date, start_date].max
    issue_due_date = issue.due_date.nil? ? end_date.to_date : [issue.due_date.to_date, end_date].min

    if issue_start_date > end_date || issue_due_date < start_date
      return {estimated_hours: 0.0, logged_hours: 0.0}
    end

    estimated_hours = 0.0

    # Calculate estimated hours within sprint
    if issue.estimated_hours
      total_days = (issue.due_date - issue.start_date).to_i
      daily_estimate = issue.estimated_hours.to_f / (total_days.nonzero? || 1)

      (issue_start_date..issue_due_date).each do |date|
        next if non_working_week_days.include?(date.wday)
        estimated_hours += daily_estimate
      end
    end

    # Calculate logged hours within sprint
    logged_hours = restrict_time_entries_within_sprint(issue)
      .sum("#{TimeEntry.table_name}.hours").to_f || 0.0

    {estimated_hours: estimated_hours, logged_hours: logged_hours}
  end

  def restrict_time_entries_within_sprint(issue)
    issue_start_date = issue.start_date.nil? ? start_date.to_date : [issue.start_date.to_date, start_date].max
    issue_due_date = issue.due_date.nil? ? end_date.to_date : [issue.due_date.to_date, end_date].min

    issue.time_entries.where("#{TimeEntry.table_name}.spent_on >= ? AND #{TimeEntry.table_name}.spent_on <= ?", issue_start_date, issue_due_date)
  end

  # # Trigger the sprint webhook after save
  # def trigger_sprint_webhook
  #   Redmine::Hook.call_hook(:sprint_after_save, {sprint: self})
  # end
end

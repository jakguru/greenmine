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
    User.current.allowed_to?(:manage_sprints, nil, global: true) || User.current.admin?
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

    estimated_hours_by_status["open"] = 0
    estimated_hours_by_status["closed"] = 0
    worked_hours_by_status["open"] = 0
    worked_hours_by_status["closed"] = 0

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

  # https://chatgpt.com/c/672d29fa-43a4-800d-9461-ed0581ee65ef?model=gpt-4o
  def get_workload
    assignable_hours_per_user = []

    # Get all active users
    eligible_users = User.where(status: User::STATUS_ACTIVE).distinct

    eligible_users.each do |user|
      total_workable_hours = 0
      total_assigned_estimate = 0
      daily_breakdown = {}

      # Loop through each day in the sprint
      (start_date.to_date..end_date.to_date).each do |date|
        workable_hours = default_capacity(date, user)
        assigned_estimated_hours = 0

        # Calculate assigned estimated hours, considering both direct and group assignments
        issues.each do |issue|
          # Check if the issue is directly assigned to the user
          if issue.assigned_to == user
            assigned_estimated_hours += estimated_hours_per_day(issue, date)
          # Check if the issue is assigned to a group and the user is a group member
          elsif issue.assigned_to.is_a?(Group) && issue.assigned_to.users.include?(user)
            assigned_estimated_hours += estimated_hours_per_day(issue, date)
          end
        end

        remaining_capacity = workable_hours - assigned_estimated_hours
        total_workable_hours += workable_hours
        total_assigned_estimate += assigned_estimated_hours

        # Record the daily breakdown for this date
        daily_breakdown[date] = {
          assigned_estimated_hours: assigned_estimated_hours,
          workable_hours: workable_hours,
          remaining_capacity: remaining_capacity
        }
      end

      # Calculate overall metrics
      total_days = (end_date.to_date - start_date.to_date).to_i + 1
      average_assigned_estimate_daily = total_assigned_estimate.to_f / total_days
      average_workable_hours_daily = total_workable_hours.to_f / total_days
      remaining_capacity_total = total_workable_hours - total_assigned_estimate

      # Add user's workload summary to the array
      assignable_hours_per_user << {
        user: {id: user.id, firstname: user.firstname, lastname: user.lastname},
        total_assigned_estimate: total_assigned_estimate,
        average_assigned_estimate_daily: average_assigned_estimate_daily,
        total_workable_hours: total_workable_hours,
        average_workable_hours_daily: average_workable_hours_daily,
        remaining_capacity_total: remaining_capacity_total,
        daily_breakdown: daily_breakdown
      }
    end

    assignable_hours_per_user
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

  def get_burndown
    non_working_week_days = Setting.send(:non_working_week_days).map(&:to_i)

    # Limit the burndown to a maximum span of 3 months
    today = Date.today
    max_span_end = [end_date.to_date, (today + 1.month).to_date].min.to_date
    max_span_start = [start_date.to_date, (max_span_end - 3.months).to_date].max.to_date
    if max_span_end - today < 1.month
      max_span_start = [start_date.to_date, (today - (3.months - (max_span_end - today))).to_date].max.to_date
    end

    # Precompute the total estimated and logged work
    total_estimated_hours = total_estimated_work
    daily_logged_hours = {}
    cumulative_ideal_hours = total_estimated_hours

    # Aggregate logged hours for each date
    issues.includes(:time_entries).each do |issue|
      restrict_time_entries_within_sprint(issue).each do |time_entry|
        date = time_entry.spent_on.to_date
        daily_logged_hours[date] ||= 0.0
        daily_logged_hours[date] += time_entry.hours.to_f
      end
    end

    # Precompute cumulative logged hours for each date in the limited range
    total_logged_hours = 0.0
    max_span_start.upto(max_span_end).each do |date|
      next if non_working_week_days.include?(date.wday)

      total_logged_hours += daily_logged_hours[date] || 0.0
    end

    # Generate the burndown data for each day in the limited range
    max_span_start.upto(max_span_end).each_with_object({}) do |date, data|
      next if non_working_week_days.include?(date.wday)

      remaining_ideal_hours = cumulative_ideal_hours
      cumulative_ideal_hours -= (total_estimated_hours / (max_span_end - max_span_start + 1))

      remaining_actual_hours = total_estimated_hours - total_logged_hours

      data[date] = {
        ideal_remaining_work: [remaining_ideal_hours, 0].max,
        actual_remaining_work: [remaining_actual_hours, 0].max,
        estimated_work: get_estimated_work_on_date(date),
        logged_work: daily_logged_hours[date] || 0.0
      }
    end
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

  def get_estimated_work_on_date(date)
    issues.sum do |issue|
      estimated_hours_per_day(issue, date)
    end
  end

  def get_logged_work_on_date(date)
    issues.sum do |issue|
      restrict_time_entries_within_sprint(issue).where(spent_on: date).sum(:hours).to_f
    end
  end

  def estimated_hours_per_day(issue, date)
    issue_start_date = issue.start_date.nil? ? start_date.to_date : [issue.start_date.to_date, start_date].max
    issue_due_date = issue.due_date.nil? ? end_date.to_date : [issue.due_date.to_date, end_date].min

    return 0 if date < issue_start_date || date > issue_due_date
    return 0 if non_working_week_days.include?(date.wday)

    estimated_hours = issue.estimated_hours.to_f || 0.0
    total_days = (issue_due_date - issue_start_date).to_i.nonzero? || 1
    estimated_hours / total_days
  end

  def non_working_week_days
    @non_working_week_days ||= Setting.send(:non_working_week_days).map(&:to_i)
  end

  def default_capacity(date, user)
    # Placeholder logic: Currently 7 hours on working days, 0 on non-working days
    # Future customization: different capacity based on user roles, preferences, etc.
    non_working_week_days.include?(date.wday) ? 0 : 7
  end
end

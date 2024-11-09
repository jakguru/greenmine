class IssueTimeTrackingStartsController < ApplicationController
  before_action :find_issue, except: [:get_activities, :get_available_statuses_for_issue_for_user]
  before_action :authorize_log_time, except: [:get, :get_activities, :get_available_statuses_for_issue_for_user]

  def create
    # End any existing tracking for the user on this issue by deleting it
    current_tracking = IssueTimeTrackingStart.where(issue: @issue, user: User.current).first
    if current_tracking.present?
      current_tracking.destroy
    end

    # Ensure the activity is valid from the enumerations
    activity = Enumeration.find_by(id: params[:activity_id], type: "TimeEntryActivity")
    unless activity
      render json: {status: "error", message: "Invalid activity"}, status: :unprocessable_entity
      return
    end

    # Start new tracking
    @tracking = IssueTimeTrackingStart.create(
      issue: @issue,
      user: User.current,
      start_time: Time.now,
      activity_id: activity.id
    )

    status = IssueStatus.find_by(id: params[:status_id])
    if status
      @issue.status_id = status.id
      @issue.save
    else
      Rails.logger.error "Invalid status ID: #{params[:status_id]}"
    end

    render json: {status: "started", tracking_id: @tracking.id}
  end

  def stop
    # Find the ongoing tracking and delete it
    @tracking = IssueTimeTrackingStart.find_by(issue_id: @issue.id, user_id: User.current.id)
    time_spent = (Time.now - @tracking.start_time) / 1.hour

    Rails.logger.info "Creating a time entry to add #{time_spent} hours to issue ##{@issue.id}"

    # Create a time entry
    entry = TimeEntry.create!(
      author: User.current,
      user: User.current,
      project: @issue.project,
      issue: @issue,
      spent_on: User.current.today,
      hours: time_spent,
      activity_id: @tracking.activity_id,
      comments: "Worked on #{Enumeration.find(@tracking.activity_id).name}"
    )

    Rails.logger.info "Time entry created with #{entry.to_json}"

    # Delete the tracking record
    @tracking.destroy

    render json: {status: "paused"}
  end

  def get
    # Find any existing tracking for the user on this issue
    current_tracking = IssueTimeTrackingStart.where(issue: @issue, user: User.current).first

    # Calculate total time entries for the user on this issue
    total_seconds = TimeEntry.where(issue: @issue, user: User.current).sum(:hours) * 3600
    total_time = convert_seconds_to_hms(total_seconds)

    response_data = {
      total: total_time, # Add the total time
      can_act: User.current.allowed_to?(:log_time, @issue.project),
      status_id: @issue.status_id
    }

    if current_tracking
      response_data.merge!(
        status: "running",
        start_time: current_tracking.start_time,
        activity: Enumeration.find(current_tracking.activity_id).name
      )
    else
      response_data[:status] = "paused"
    end

    render json: response_data
  end

  def get_activities
    activities = Enumeration.where(type: "TimeEntryActivity", active: true)
    render json: activities.to_json
  end

  def get_available_statuses_for_issue_for_user
    @issue = Issue.find(params[:id])
    available = @issue.new_statuses_allowed_to(User.current)
    render json: available.to_json
  end

  private

  def convert_seconds_to_hms(total_seconds)
    hours = (total_seconds / 3600).floor
    minutes = ((total_seconds % 3600) / 60).floor
    seconds = (total_seconds % 60).floor
    {
      hours: hours,
      minutes: minutes,
      seconds: seconds
    }
  end

  def find_issue
    @issue = Issue.find(params[:issue_id])
  end

  # Ensure the user has permission to log time
  def authorize_log_time
    unless User.current.allowed_to?(:log_time, @issue.project)
      render_403({message: "You are not permitted to work on this issue"})
    end
  end
end

class SprintsController < ApplicationController
  default_search_scope :sprints
  before_action :find_sprint, only: [:show, :edit, :update, :destroy]
  accept_atom_auth :index, :show
  accept_api_auth :index, :show, :create, :update, :destroy

  rescue_from Query::StatementInvalid, with: :query_statement_invalid
  rescue_from Query::QueryError, with: :query_error

  helper :queries
  include QueriesHelper
  include FridayHelper

  def index
    use_session = false
    retrieve_default_query(use_session)
    retrieve_query(SprintsQuery, use_session)
    if friday_request?
      render_query_response(@query, @query.base_scope, SprintsQuery, @project, User.current, params, per_page_option)
    end
  end

  def new
    if friday_request?
      render json: {
        formAuthenticityToken: form_authenticity_token
      }
    end
  end

  def edit
    render json: {}
  end

  def create
    @sprint = Sprint.new(sprint_params)
    if @sprint.save
      render json: @sprint, status: 201
    else
      render json: {success: false}
    end
  end

  def show
    if friday_request?
      render_sprint_response(@sprint)
    end
  end

  def update
    if @sprint.update(sprint_params)
      render json: @sprint, status: 201
    else
      render json: {success: false}
    end
  end

  private

  def find_sprint
    @sprint = if params[:id].to_i == 0
      Sprint.backlog
    else
      Sprint.find(params[:id])
    end
  end

  def sprint_params
    params.require(:sprint).permit(:name, :start_date, :end_date)
  end

  def retrieve_default_query(use_session)
    return if params[:query_id].present?
    return if api_request?
    return if params[:set_filter]

    if params[:without_default].present?
      params[:set_filter] = 1
      return
    end
    if !params[:set_filter] && use_session && session[:issue_query]
      query_id, project_id = session[:issue_query].values_at(:id, :project_id)
      return if SprintsQuery.where(id: query_id).exists? && project_id == @project&.id
    end
    if default_query = SprintsQuery.default(project: @project)
      params[:query_id] = default_query.id
    end
  end

  def render_sprint_response(sprint)
    use_session = false
    params[:set_filter] = 1
    params[:f] = ["sprint_ids"]
    params[:op] = {"sprint_ids" => "="}
    params[:v] = {"sprint_ids" => [sprint.id.to_s]}
    retrieve_query(IssueQuery, use_session)
    issues = query_response(@query, @query.base_scope, IssueQuery, @project, User.current, params, per_page_option)
    render json: {
      sprint: sprint,
      issues: issues,
      progress: get_sprint_progress(sprint),
      workload: get_sprint_workload_allocation_by_role(sprint)
    }
  end

  # Returns the total number of hours logged in the sprint's related issues during the duration of the sprint
  # compared to the total number of hours estimated in the sprints's related issues during the duration of the sprint
  def get_sprint_progress(sprint)
    non_working_week_days = Setting.send(:non_working_week_days).map(&:to_i)
    total_estimated_hours = 0
    total_logged_hours = 0
    daily_estimated = {}
    daily_worked = {}
    sprint_start_date = sprint.start_date
    sprint_end_date = sprint.end_date
    if sprint.is_a?(BacklogSprint)
      # set the current date ranges to a week before and a week after today if we're in the backlog sprint
      sprint_start_date = Date.today - 7
      sprint_end_date = Date.today + 7
    end
    sprint_start_date = sprint_start_date.to_date
    sprint_end_date = sprint_end_date.to_date
    sprint.issues.each do |issue|
      issue_start_date = issue.start_date.nil? ? sprint_start_date : issue.start_date
      issue_due_date = issue.due_date.nil? ? sprint_end_date : issue.due_date
      issue_start_date = issue_start_date.to_date
      issue_due_date = issue_due_date.to_date
      if !issue.estimated_hours.nil?
        # calculate the total daily estimated hours for the issue
        issue_total_estimated_daily_hours = issue.estimated_hours.to_f / (issue_due_date - issue_start_date).to_i
        # determine how many of the issue's estimated hours fall within the sprint's duration
        # we also need to respect "non-working weekdays"
        issue_estimated_hours = 0
        (issue_start_date..issue_due_date).each do |date|
          if !non_working_week_days.include?(date.wday) && sprint_start_date <= date && date <= sprint_end_date
            issue_estimated_hours += issue_total_estimated_daily_hours
            daily_estimated[date] ||= 0
            daily_estimated[date] += issue_total_estimated_daily_hours
          end
        end
        total_estimated_hours += issue_estimated_hours
      end
      (issue_start_date..issue_due_date).each do |date|
        if sprint_start_date <= date && date <= sprint_end_date
          daily_estimated[date] ||= 0
          daily_worked[date] ||= 0
          daily_worked[date] += issue.self_and_descendants.joins(:time_entries)
            .where("#{TimeEntry.table_name}.spent_on = ?", date)
            .sum("#{TimeEntry.table_name}.hours").to_f || 0.0
        end
      end
      total_logged_hours += issue.self_and_descendants.joins(:time_entries)
        .where("#{TimeEntry.table_name}.spent_on >= ? AND #{TimeEntry.table_name}.spent_on <= ?", sprint_start_date, sprint_end_date)
        .sum("#{TimeEntry.table_name}.hours").to_f || 0.0
    end
    (sprint_start_date.to_date..sprint_end_date.to_date).each do |date|
      daily_estimated[date] ||= 0
      daily_worked[date] ||= 0
    end
    {
      total_estimated_hours: total_estimated_hours,
      total_logged_hours: total_logged_hours,
      daily_estimated: daily_estimated,
      daily_worked: daily_worked
    }
  end

  # Returns the list of users who are allowed to log time on issues in the sprint
  # for each user we get the total number of assignable hours in the sprint
  # vs the total number of hours logged by the user in the sprint for issues
  # that are assigned to the user and are in the sprint
  def get_sprint_workload_allocation_by_role(sprint)
    non_working_week_days = Setting.send(:non_working_week_days).map(&:to_i)
    sprint_start_date = sprint.start_date.to_date
    sprint_end_date = sprint.end_date.to_date

    # Calculate total assignable hours for each user within the sprint period
    assignable_hours_per_user = {}
    User.joins(memberships: :project).joins("LEFT JOIN groups_users ON groups_users.user_id = #{User.table_name}.id").joins("LEFT JOIN issues ON issues.assigned_to_id = groups_users.group_id")
      .where("#{User.table_name}.status = ?", User::STATUS_ACTIVE)
      .distinct
      .each do |user|
      assignable_hours = 0
      (sprint_start_date..sprint_end_date).each do |date|
        next if non_working_week_days.include?(date.wday)
        assignable_hours += 7 # assuming 7 working hours per working day
      end
      assignable_hours_per_user[user.id] = assignable_hours
    end

    # Calculate total hours logged by each user for the issues in the sprint
    hours_logged_per_user = TimeEntry.joins(:issue)
      .where(issues: {sprint_id: sprint.id})
      .select("user_id, SUM(hours) AS hours_logged")
      .group(:user_id)

    # Daily estimated and daily logged hours within the sprint period
    daily_estimated = {}
    daily_logged = {}

    sprint.issues.each do |issue|
      issue_start_date = issue.start_date.nil? ? sprint_start_date : issue.start_date.to_date
      issue_due_date = issue.due_date.nil? ? sprint_end_date : issue.due_date.to_date

      (issue_start_date..issue_due_date).each do |date|
        next if non_working_week_days.include?(date.wday) || date < sprint_start_date || date > sprint_end_date

        daily_estimated[date] ||= 0
        daily_estimated[date] += (issue.estimated_hours.to_f / (issue_due_date - issue_start_date + 1).to_i) if issue.estimated_hours
        if issue.assigned_to.is_a?(Group)
          issue.assigned_to.users.each do |user|
            daily_estimated[date] += (issue.estimated_hours.to_f / (issue_due_date - issue_start_date + 1).to_i)
          end
        end

        daily_logged[date] ||= 0
        daily_logged[date] += issue.time_entries.where("spent_on = ?", date).sum(:hours).to_f
      end
    end

    # Merge the data to get workload allocation by user
    assignable_hours_per_user.map do |user_id, assignable_hours|
      logged_data = hours_logged_per_user.find { |h| h.user_id == user_id }
      hours_logged = logged_data ? logged_data.hours_logged : 0

      {
        user_id: user_id,
        assignable_hours: assignable_hours,
        hours_logged: hours_logged,
        daily_estimated: daily_estimated,
        daily_logged: daily_logged
      }
    end
  end
end

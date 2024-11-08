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

  def show_burndown
    find_sprint
    render json: @sprint.get_burndown
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
    params[:f] ||= []

    # Ensure params[:f] always includes "sprint_ids"
    params[:f] << "sprint_ids" unless params[:f].include?("sprint_ids")

    # Add "status_id" to params[:f] if sprint.id is nil
    if sprint.id.nil?
      params[:f] << "status_id" unless params[:f].include?("status_id")
      params[:op] ||= {}
      params[:v] ||= {}
      params[:op]["status_id"] = "o"
      params[:v]["status_id"] = [""]
    end

    params[:op] ||= {}
    params[:v] ||= {}
    params[:op]["sprint_ids"] = "="
    params[:v]["sprint_ids"] = [sprint.id.nil? ? "0" : sprint.id.to_s]
    retrieve_query(IssueQuery, use_session)
    issues = query_response(@query, @query.base_scope, IssueQuery, @project, User.current, params, per_page_option)
    render json: {
      formAuthenticityToken: form_authenticity_token,
      sprint: sprint,
      issues: issues,
      rate: sprint.progress,
      progress: sprint.get_progress,
      workload: sprint.get_workload,
      releases: sprint.get_releases,
      byCalculatedPriority: sprint.get_breakdown_by_calculated_priority,
      byTracker: sprint.get_breakdown_by_tracker,
      byActivity: sprint.get_breakdown_by_activity,
      byProject: sprint.get_breakdown_by_project,
      navigation: {
        next: sprint.next_sprint_id,
        previous: sprint.previous_sprint_id
      },
      permissions: {
        edit: User.current.allowed_to?(:manage_sprints, nil, global: true) || User.current.admin?
      }
    }
  end
end

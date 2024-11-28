module Admin
  module Integrations
    class GitlabController < ApplicationController
      default_search_scope :gitlabs
      before_action :find_gitlab, only: [:show, :edit, :update, :destroy]
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
        retrieve_query(GitlabsQuery, use_session)
        if friday_request?
          render_query_response(@query, @query.base_scope, GitlabsQuery, @project, User.current, params, per_page_option)
        else
          render_blank
        end
      end

      def new
        @gitlab = GitlabInstance.new
        if friday_request?
          render_model_response
        else
          render_blank
        end
      end

      def show
        if friday_request?
          render_model_response
        else
          render_blank
        end
      end

      def edit
        render json: {}
      end

      def create
        @gitlab = GitlabInstance.new(gitlab_params)
        render_save_response
      end

      def update
        render_save_response
      end

      def enqueue_fetch_projects
        FetchGitlabProjectsJob.perform_async(params[:id])
        render json: {}, status: 202
      end

      private

      def render_model_response
        params[:set_filter] = 1
        params[:f] ||= []
        params[:f] << "gitlab_id" unless params[:f].include?("gitlab_id")
        params[:op] ||= {}
        params[:v] ||= {}
        params[:op]["gitlab_id"] = "="
        params[:v]["gitlab_id"] = [@gitlab.id.nil? ? "0" : @gitlab.id.to_s]
        retrieve_query(GitlabProjectsQuery, false)
        projects = query_response(@query, @query.base_scope, GitlabProjectsQuery, @project, User.current, params, per_page_option)
        render json: {
          formAuthenticityToken: form_authenticity_token,
          id: @gitlab.id,
          model: @gitlab,
          projects: projects
        }
      end

      def render_save_response
        @gitlab.safe_attributes = params[:gitlab]
        @gitlab.active = params[:gitlab][:active].present?
        if @gitlab.save
          render json: {
            id: @gitlab.id
          }, status: 201
        else
          render json: {errors: @gitlab.errors.full_messages}, status: 422
        end
      end

      def find_gitlab
        @gitlab = GitlabInstance.find(params[:id])
      end

      def gitlab_params
        params.require(:gitlab).permit(:name, :url, :api_token, :active)
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
          return if GitlabsQuery.where(id: query_id).exists? && project_id == @project&.id
        end
        if default_query = GitlabsQuery.default(project: @project)
          params[:query_id] = default_query.id
        end
      end
    end
  end
end

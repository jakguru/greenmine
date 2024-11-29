module Admin
  module Integrations
    class GitlabController < ApplicationController
      default_search_scope :gitlabs
      before_action :find_gitlab, only: [:show, :edit, :update, :destroy, :show_project, :handle_project_action, :update_project_gitlab_project_association, :update_user_gitlab_user_association]
      accept_atom_auth :index, :show
      accept_api_auth :index, :show, :create, :update, :destroy, :show_project

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

      def destroy
        @gitlab.destroy
        render json: {}, status: 200
      end

      def enqueue_fetch_projects
        FetchGitlabProjectsJob.perform_async(params[:id])
        render json: {}, status: 202
      end

      def enqueue_fetch_users
        FetchGitlabUsersJob.perform_async(params[:id])
        render json: {}, status: 202
      end

      def show_project
        @gitlab_project = GitlabProject.where(gitlab_id: @gitlab.id, project_id: params[:project_id]).first
        if friday_request?
          render json: {
            id: @gitlab_project.id,
            parentName: @gitlab.name,
            parentId: @gitlab.id,
            model: @gitlab_project.attributes.merge({
              web_url: @gitlab_project.web_url,
              git_http_url: @gitlab_project.git_http_url,
              git_ssh_url: @gitlab_project.git_ssh_url,
              projects: @gitlab_project.projects.map(&:id),
              remote_info: @gitlab_project.remote_info
            }),
            values: {
              projects: get_project_nested_items(Project.all)
            }
          }
        else
          render_blank
        end
      end

      def update_project_gitlab_project_association
        @gitlab_project = GitlabProject.where(gitlab_id: @gitlab.id, project_id: params[:project_id]).first
        if friday_request?
          if @gitlab_project.set_associated_projects(Project.where(id: params[:project_ids]))
            render json: {
              id: @gitlab_project.id
            }, status: 201
          else
            render json: {errors: @gitlab_project.errors.full_messages}, status: 422
          end
        else
          render_blank
        end
      end

      def handle_project_action
        @gitlab_project = GitlabProject.where(gitlab_id: @gitlab.id, project_id: params[:project_id]).first
        case params[:action_to_perform]
        when "install-webhooks"
          InstallGitlabWebhooksJob.perform_async(@gitlab.id, @gitlab_project.id)
          render json: {}, status: 202
        else
          render json: {}, status: 400
        end
      end

      def update_user_gitlab_user_association
        @gitlab_user = GitlabUser.where(gitlab_id: @gitlab.id, user_id: params[:gitlab_user_id]).first
        if friday_request?
          if @gitlab_user.set_redmine_user(params[:redmine_user_id])
            render json: {
              id: @gitlab_user.id
            }, status: 201
          else
            render json: {errors: @gitlab_user.errors.full_messages}, status: 422
          end
        else
          render_blank
        end
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
          model: @gitlab.attributes.merge({
            users: @gitlab.gitlab_users.map { |gitlab_user|
              gitlab_user.attributes.merge({
                redmine_user: gitlab_user.redmine_user,
                redmine_user_id: gitlab_user.redmine_user.nil? ? nil : gitlab_user.redmine_user.id
              })
            }
          }),
          projects: projects,
          values: {
            users: [{value: nil, label: l(:label_none)}] + User.active.sorted.collect { |user|
              {
                value: user.id,
                label: user.name
              }
            }
          }
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

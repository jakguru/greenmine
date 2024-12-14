module Admin
  module Integrations
    class GithubController < ApplicationController
      default_search_scope :githubs
      before_action :find_github, only: [:show, :edit, :update, :destroy, :show_repository, :handle_repository_action, :update_project_github_repository_association, :update_user_github_user_association]
      accept_atom_auth :index, :show
      accept_api_auth :index, :show, :create, :update, :destroy, :show_repository

      rescue_from Query::StatementInvalid, with: :query_statement_invalid
      rescue_from Query::QueryError, with: :query_error

      helper :queries
      include QueriesHelper
      include FridayHelper

      def index
        use_session = false
        retrieve_default_query(use_session)
        retrieve_query(GithubsQuery, use_session)
        if friday_request?
          render_query_response(@query, @query.base_scope, GithubsQuery, @project, User.current, params, per_page_option)
        else
          render_blank
        end
      end

      def new
        @github = GithubInstance.new
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
        @github = GithubInstance.new(github_params)
        render_save_response
      end

      def update
        render_save_response
      end

      def destroy
        @github.destroy
        render json: {}, status: 200
      end

      def enqueue_fetch_repositories
        FetchGithubRepositoriesJob.perform_async(params[:id])
        render json: {}, status: 202
      end

      def enqueue_fetch_users
        FetchGithubUsersJob.perform_async(params[:id])
        render json: {}, status: 202
      end

      def enqueue_fetch_entities
        # TODO: Implement this
        render json: {}, status: 202
      end

      def show_repository
        @github_repository = GithubRepository.where(github_id: @github.id, repository_id: params[:repository_id]).first
        if friday_request?
          render json: {
            id: @github_repository.id,
            parentName: @github.name,
            parentId: @github.id,
            model: @github_repository.attributes.merge({
              web_url: @github_repository.web_url,
              git_http_url: @github_repository.git_http_url,
              git_ssh_url: @github_repository.git_ssh_url,
              projects: @github_repository.projects.map(&:id),
              remote_info: @github_repository.remote_info
            }),
            values: {
              projects: get_project_nested_items(Project.all)
            }
          }
        else
          render_blank
        end
      end

      def update_project_github_repository_association
        @github_repository = GithubRepository.where(github_id: @github.id, repository_id: params[:repository_id]).first
        if friday_request?
          if @github_repository.set_associated_projects(Project.where(id: params[:project_ids]))
            render json: {
              id: @github_repository.id
            }, status: 201
          else
            render json: {errors: @github_repository.errors.full_messages}, status: 422
          end
        else
          render_blank
        end
      end

      def handle_repository_action
        @github_repository = GithubRepository.where(github_id: @github.id, repository_id: params[:repository_id]).first
        case params[:action_to_perform]
        when "install-webhooks"
          InstallGithubWebhooksJob.perform_async(@github.id, @github_repository.id)
          render json: {}, status: 202
        else
          render json: {}, status: 400
        end
      end

      def update_user_github_user_association
        @github_user = GithubUser.where(github_id: @github.id, user_id: params[:github_user_id]).first
        if friday_request?
          if @github_user.set_redmine_user(params[:redmine_user_id])
            render json: {
              id: @github_user.id
            }, status: 201
          else
            render json: {errors: @github_user.errors.full_messages}, status: 422
          end
        else
          render_blank
        end
      end

      private

      def render_model_response
        params[:set_filter] = 1
        params[:f] ||= []
        params[:f] << "github_id" unless params[:f].include?("github_id")
        params[:op] ||= {}
        params[:v] ||= {}
        params[:op]["github_id"] = "="
        params[:v]["github_id"] = [@github.id.nil? ? "0" : @github.id.to_s]
        retrieve_query(GithubRepositoriesQuery, false)
        repositories = query_response(@query, @query.base_scope, GithubRepositoriesQuery, @project, User.current, params, per_page_option)
        render json: {
          formAuthenticityToken: form_authenticity_token,
          id: @github.id,
          model: @github.attributes.merge({
            users: @github.github_users.map { |github_user|
              github_user.attributes.merge({
                redmine_user: github_user.redmine_user,
                redmine_user_id: github_user.redmine_user.nil? ? nil : github_user.redmine_user.id
              })
            }
          }),
          repositories: repositories,
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
        @github.name = params[:github][:name]
        @github.api_token = params[:github][:api_token]
        @github.active = params[:github][:active].present?
        if @github.save
          render json: {
            id: @github.id
          }, status: 201
        else
          render json: {errors: @github.errors.full_messages}, status: 422
        end
      end

      def find_github
        @github = GithubInstance.find(params[:id])
      end

      def github_params
        params.require(:github).permit(:name, :url, :api_token, :active)
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
          return if GithubsQuery.where(id: query_id).exists? && project_id == @project&.id
        end
        if default_query = GithubsQuery.default(project: @project)
          params[:query_id] = default_query.id
        end
      end
    end
  end
end

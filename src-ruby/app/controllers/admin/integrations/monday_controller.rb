module Admin
  module Integrations
    class MondayController < ApplicationController
      default_search_scope :mondays
      before_action :find_monday, only: [:show, :edit, :update, :destroy, :show_board, :handle_board_action, :update_board, :update_user_monday_user_association]
      accept_atom_auth :index, :show
      accept_api_auth :index, :show, :create, :update, :destroy, :show_board

      rescue_from Query::StatementInvalid, with: :query_statement_invalid
      rescue_from Query::QueryError, with: :query_error

      helper :queries
      include QueriesHelper
      include FridayHelper

      def index
        use_session = false
        retrieve_default_query(use_session)
        retrieve_query(MondaysQuery, use_session)
        if friday_request?
          render_query_response(@query, @query.base_scope, MondaysQuery, @project, User.current, params, per_page_option)
        else
          render_blank
        end
      end

      def new
        @monday = MondayInstance.new
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
        @monday = MondayInstance.new(monday_params)
        render_save_response
      end

      def update
        render_save_response
      end

      def destroy
        @monday.destroy
        render json: {}, status: 200
      end

      def enqueue_fetch_boards
        FetchMondayBoardsJob.perform_async(params[:id])
        render json: {}, status: 202
      end

      def enqueue_fetch_users
        FetchMondayUsersJob.perform_async(params[:id])
        render json: {}, status: 202
      end

      def show_board
        @monday_board = MondayBoard.where(monday_id: @monday.id, monday_board_id: params[:monday_board_id]).first
        if friday_request?
          render json: {
            id: @monday_board.id,
            parentName: @monday.name,
            parentId: @monday.id,
            model: @monday_board.attributes.merge({
              # web_url: @monday_board.web_url,
              # git_http_url: @monday_board.git_http_url,
              # git_ssh_url: @monday_board.git_ssh_url,
              # boards: @monday_board.boards.map(&:id),
              # remote_info: @monday_board.remote_info
            }),
            values: {
              projects: [
                {value: 0, label: l(:label_none)}
              ] + get_project_nested_items(Project.all),
              fields: [
                {value: "", label: l(:label_none), monday_can_edit: false, monday_types: ["checkbox", "color_picker", "board_relation", "country", "creation_log", "date", "dependency", "dropdown", "email", "file", "formula", "hour", "item_id", "last_updated", "link", "location", "long_text", "mirror", "doc", "name", "numbers", "people", "phone", "rating", "status", "tags", "text", "timeline", "time_tracking", "vote", "week", "world_clock"]},
                {value: "url", label: l(:field_url), monday_can_edit: false, monday_types: ["link", "text"]},
                {value: "id", label: "ID", monday_can_edit: false, monday_types: ["numbers", "text"]},
                {value: "project", label: l(:field_project), monday_can_edit: false, monday_types: ["text"]},
                {value: "tracker", label: l(:field_tracker), monday_can_edit: false, monday_types: ["dropdown", "text"]},
                {value: "status", label: l(:field_status), monday_can_edit: false, monday_types: ["dropdown", "status", "text"]},
                {value: "urgency", label: l(:field_urgency), monday_can_edit: true, monday_types: ["dropdown", "status", "text"]},
                {value: "impact", label: l(:field_impact), monday_can_edit: true, monday_types: ["dropdown", "status", "text"]},
                {value: "calculated_priority", label: l(:field_calculated_priority), monday_can_edit: false, monday_types: ["text", "number"]},
                {value: "author", label: l(:field_author), monday_can_edit: false, monday_types: ["people", "text"]},
                {value: "assigned_to", label: l(:field_assigned_to), monday_can_edit: false, monday_types: ["people", "text"]},
                {value: "category", label: l(:field_category), monday_can_edit: false, monday_types: ["text"]},
                {value: "fixed_version", label: l(:field_fixed_version), monday_can_edit: false, monday_types: ["text"]},
                {value: "parent", label: l(:field_parent), monday_can_edit: false, monday_types: ["link", "text", "numbers"]},
                {value: "subject", label: l(:field_subject), monday_can_edit: true, monday_types: ["name", "text"]},
                {value: "description", label: l(:field_description), monday_can_edit: true, monday_types: ["long_text", "doc"]},
                {value: "start_date", label: l(:field_start_date), monday_can_edit: false, monday_types: ["date", "text"]},
                {value: "due_date", label: l(:field_due_date), monday_can_edit: false, monday_types: ["date", "text"]},
                {value: "done_ratio", label: l(:field_done_ratio), monday_can_edit: false, monday_types: ["numbers", "text"]},
                {value: "estimated_hours", label: l(:field_estimated_hours), monday_can_edit: false, monday_types: ["numbers", "text"]},
                {value: "total_estimated_hours", label: l(:field_total_estimated_hours), monday_can_edit: false, monday_types: ["numbers", "text"]},
                {value: "spent_hours", label: l(:field_spent_hours), monday_can_edit: false, monday_types: ["numbers", "text"]},
                {value: "total_spent_hours", label: l(:field_total_spent_hours), monday_can_edit: false, monday_types: ["numbers", "text"]},
                {value: "created_on", label: l(:field_created_on), monday_can_edit: false, monday_types: ["date", "text"]},
                {value: "updated_on", label: l(:field_updated_on), monday_can_edit: false, monday_types: ["date", "text"]},
                {value: "closed_on", label: l(:field_closed_on), monday_can_edit: false, monday_types: ["date", "text"]},
                {value: "attachments", label: l(:field_attachments), monday_can_edit: false, monday_types: ["file"]},
                {value: "sprints", label: l(:field_sprints), monday_can_edit: false, monday_types: ["text"]}
              ]
            }
          }
        else
          render_blank
        end
      end

      def update_board
        @monday_board = MondayBoard.where(monday_id: @monday.id, monday_board_id: params[:monday_board_id]).first
        if friday_request?
          @monday_board[:project_id] = params[:monday_board][:project_id].to_i
          board_field_mappings = params[:monday_board][:board_field_mappings]
          @monday_board[:board_meta_data]["columns"].each do |column|
            column_id = column["id"].to_sym
            board_field_mappings[column_id] ||= ""
          end
          Rails.logger.info board_field_mappings.to_json
          @monday_board.board_field_mappings = board_field_mappings
          if @monday_board.save
            InstallMondayFieldConfigurationsJob.perform_async(@monday.id, @monday_board.id)
            render json: {
              id: @monday_board.id
            }, status: 201
          else
            render json: {errors: @monday_board.errors.full_messages}, status: 422
          end
        else
          render_blank
        end
      end

      def handle_board_action
        @monday_board = MondayBoard.where(monday_id: @monday.id, monday_board_id: params[:monday_board_id]).first
        case params[:action_to_perform]
        when "install-webhooks"
          InstallMondayWebhooksJob.perform_async(@monday.id, @monday_board.id)
          render json: {}, status: 202
        when "refresh-board-meta"
          RefreshMondayBoardMetaJob.perform_async(@monday.id, @monday_board.id)
          render json: {}, status: 202
        else
          render json: {}, status: 400
        end
      end

      def update_user_monday_user_association
        @monday_user = MondayUser.where(monday_id: @monday.id, user_id: params[:monday_user_id]).first
        if friday_request?
          if @monday_user.set_redmine_user(params[:redmine_user_id])
            render json: {
              id: @monday_user.id
            }, status: 201
          else
            render json: {errors: @monday_user.errors.full_messages}, status: 422
          end
        else
          render_blank
        end
      end

      private

      def render_model_response
        params[:set_filter] = 1
        params[:f] ||= []
        params[:f] << "monday_id" unless params[:f].include?("monday_id")
        params[:op] ||= {}
        params[:v] ||= {}
        params[:op]["monday_id"] = "="
        params[:v]["monday_id"] = [@monday.id.nil? ? "0" : @monday.id.to_s]
        retrieve_query(MondayBoardsQuery, false)
        boards = query_response(@query, @query.base_scope, MondayBoardsQuery, @project, User.current, params, per_page_option)
        render json: {
          formAuthenticityToken: form_authenticity_token,
          id: @monday.id,
          model: @monday.attributes.merge({
            users: @monday.monday_users.map { |monday_user|
              monday_user.attributes.merge({
                redmine_user: monday_user.redmine_user,
                redmine_user_id: monday_user.redmine_user.nil? ? nil : monday_user.redmine_user.id
              })
            }
          }),
          boards: boards,
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
        @monday.safe_attributes = params[:monday]
        @monday.active = params[:monday][:active].present?
        if @monday.save
          render json: {
            id: @monday.id
          }, status: 201
        else
          render json: {errors: @monday.errors.full_messages}, status: 422
        end
      end

      def find_monday
        @monday = MondayInstance.find(params[:id])
      end

      def monday_params
        params.require(:monday).permit(:name, :url, :api_token, :active)
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
          return if MondaysQuery.where(id: query_id).exists? && project_id == @project&.id
        end
        if default_query = MondaysQuery.default(project: @project)
          params[:query_id] = default_query.id
        end
      end
    end
  end
end

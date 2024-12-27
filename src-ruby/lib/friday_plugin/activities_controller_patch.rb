module FridayPlugin
  module ActivitiesControllerPatch
    def self.included(base)
      base.class_eval do
        alias_method :redmine_index, :index

        def index
          # If the request is made using FridayUI, respond with JSON
          if friday_request?
            handle_friday_json_response
          else
            # Call the original Redmine index action
            redmine_index
          end
        end

        private

        # Custom method to handle JSON responses for FridayUI
        def handle_friday_json_response
          # Calculate date range
          days = Setting.activity_days_default.to_i
          date_to = if params[:to].present?
            begin
              params[:to].to_date + 1
            rescue
              nil
            end
          elsif params[:from].present?
            begin
              params[:from].to_date + 1
            rescue
              nil
            end
          else
            User.current.today + 1
          end

          date_from = if days > 0
            date_to - days
          else
            date_to << 3 # Subtract 3 months
          end

          # Determine subproject inclusion
          with_subprojects = params[:with_subprojects].nil? ? Setting.display_subprojects_issues? : (params[:with_subprojects] == "1")

          # Build activity fetcher
          activity = Redmine::Activity::Fetcher.new(
            User.current,
            project: @project,
            with_subprojects: with_subprojects
          )
          activity.scope_select { |t| !params["show_#{t}"].nil? }

          activity.scope = :default if activity.scope.blank?

          # Fetch events
          events = activity.events(date_from, date_to)

          # If we have a defined project, use "render_project_response"
          if @project
            render_project_response({
              events: events.map do |event|
                {
                  id: event.id,
                  type: event.event_type,
                  title: event.event_title,
                  description: event.event_description,
                  author: event.event_author ? {
                    id: event.event_author.id,
                    name: event.event_author.name
                  } : nil,
                  datetime: event.event_datetime,
                  url: event.event_url.nil? ? nil : url_for(event.event_url)
                }
              end,
              dateFrom: date_from,
              dateTo: date_to,
              eventTypes: activity.event_types.map do |type|
                {
                  value: type,
                  label: l("label_#{type.singularize}_plural")
                }
              end,
              scope: activity.scope
            })
          else
            render json: {
              formAuthenticityToken: form_authenticity_token,
              events: events.map do |event|
                {
                  id: event.id,
                  type: event.event_type,
                  title: event.event_title,
                  description: event.event_description,
                  author: event.event_author ? {
                    id: event.event_author.id,
                    name: event.event_author.name
                  } : nil,
                  datetime: event.event_datetime,
                  url: event.event_url.nil? ? nil : url_for(event.event_url)
                }
              end,
              dateFrom: date_from,
              dateTo: date_to,
              eventTypes: activity.event_types.map do |type|
                {
                  value: type,
                  label: l("label_#{type.singularize}_plural")
                }
              end,
              scope: activity.scope
            }
          end
        end

        # Get the list of users who could have authored an activity within a project
        def activity_authors_options(project)
          options = []
          if User.current.logged?
            options += [{
              label: "<< #{l(:label_me)} >>",
              value: User.current.id
            }]
          end
          if project
            options += Query.new(project: project).users.select { |user| user.active? }.map { |user| {label: user.name, value: user.id} }
          end
          options
        end
      end
    end
  end
end

ActivitiesController.send(:include, FridayPlugin::ActivitiesControllerPatch) unless ActivitiesController.included_modules.include?(FridayPlugin::ActivitiesControllerPatch)

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
          date_to = params[:from].present? ? begin
            params[:from].to_date + 1
          rescue
            nil
          end : (User.current.today + 1)
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

          # Return JSON response
          render json: {
            events: events.map do |event|
              {
                id: event.id,
                type: event.event_type,
                title: event.event_title,
                description: event.event_description,
                author: event.event_author.try(:name),
                datetime: event.event_datetime,
                url: url_for(event.event_url)
              }
            end,
            date_from: date_from,
            date_to: date_to
          }
        end
      end
    end
  end
end

ActivitiesController.send(:include, FridayPlugin::ActivitiesControllerPatch) unless ActivitiesController.included_modules.include?(FridayPlugin::ActivitiesControllerPatch)

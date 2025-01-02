module FridayPlugin
  module DocumentsControllerPatch
    def self.included(base)
      base.class_eval do
        base.send(:include, FridayHelper)
        alias_method :redmine_base_index, :index

        def index
          if friday_request?
            @sort_by = %w[category date title author].include?(params[:sort_by]) ? params[:sort_by] : "category"
            documents = @project.documents.includes(:attachments, :category).to_a
            case @sort_by
            when "date"
              documents.sort! { |a, b| b.updated_on <=> a.updated_on }
              @grouped = documents.group_by { |d| d.updated_on.to_date }
            when "title"
              @grouped = documents.group_by { |d| d.title.first.upcase }
            when "author"
              @grouped = documents.select { |d| d.attachments.any? }.group_by { |d| d.attachments.last.author }
            else
              @grouped = documents.group_by(&:category)
            end
            if @project
              render_project_response({
                docs: @grouped.map(&:to_json)
              })
            else
              render json: {
                docs: @grouped.map(&:to_json)
              }
            end
          else
            redmine_base_index
          end
        end
      end
    end
  end
end

DocumentsController.send(:include, FridayPlugin::DocumentsControllerPatch) unless DocumentsController.included_modules.include?(FridayPlugin::DocumentsControllerPatch)

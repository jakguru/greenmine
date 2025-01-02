module FridayPlugin
  module NewsControllerPatch
    def self.included(base)
      base.class_eval do
        base.send(:include, FridayHelper)
        alias_method :redmine_base_index, :index

        def index
          if friday_request?
            @limit = 10
            scope = @project ? @project.news.visible : News.visible
            @news_count = scope.count
            @news_pages = Redmine::Pagination::Paginator.new @news_count, @limit, params["page"]
            @offset ||= @news_pages.offset
            @newss = scope.includes([:author, :project])
              .order("#{News.table_name}.created_on DESC")
              .limit(@limit)
              .offset(@offset)
              .to_a
            if @project
              render_project_response({
                news: {
                  articles: @newss.map { |news| news.as_json },
                  total: @news_count,
                  pages: @news_pages.last_page || 1
                }
              })
            else
              render json: {
                articles: @newss.map { |news| news.as_json },
                total: @news_count,
                pages: @news_pages.last_page || 1
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

NewsController.send(:include, FridayPlugin::NewsControllerPatch) unless NewsController.included_modules.include?(FridayPlugin::NewsControllerPatch)

module FridayPlugin
  module SearchControllerPatch
    def self.included(base)
      base.class_eval do
        base.send(:include, FridayHelper)
        def index
          @question = params[:q]&.strip || ""
          @all_words = params[:all_words] ? params[:all_words].present? : true
          @titles_only = params[:titles_only] ? params[:titles_only].present? : false
          @search_attachments = params[:attachments].presence || "0"
          @open_issues = params[:open_issues] ? params[:open_issues].present? : false

          case params[:format]
          when "xml", "json"
            @offset, @limit = api_offset_and_limit
          else
            @offset = nil
            @limit = Setting.search_results_per_page.to_i
            @limit = 10 if @limit == 0
          end

          # quick jump to an issue
          if !api_request? && (m = @question.match(/^#?(\d+)$/)) && (issue = Issue.visible.find_by_id(m[1].to_i))
            redirect_to issue_path(issue)
            return
          end

          projects_to_search =
            case params[:scope]
            when "all"
              nil
            when "my_projects"
              User.current.projects
            when "bookmarks"
              Project.where(id: User.current.bookmarked_project_ids)
            when "subprojects"
              @project ? (@project.self_and_descendants.to_a) : nil
            else
              @project
            end

          @object_types = Redmine::Search.available_search_types.dup
          if projects_to_search.is_a? Project
            # don't search projects
            @object_types.delete("projects")
            # only show what the user is allowed to view
            @object_types = @object_types.select { |o| User.current.allowed_to?(:"view_#{o}", projects_to_search) }
          end

          @scope = @object_types.select { |t| params[t].present? }
          @scope = @object_types if @scope.empty?

          fetcher = Redmine::Search::Fetcher.new(
            @question, User.current, @scope, projects_to_search,
            all_words: @all_words, titles_only: @titles_only, attachments: @search_attachments, open_issues: @open_issues,
            cache: params[:page].present?, params: params.to_unsafe_hash
          )

          if fetcher.tokens.present?
            @result_count = fetcher.result_count
            @result_count_by_type = fetcher.result_count_by_type
            @tokens = fetcher.tokens

            @result_pages = Paginator.new @result_count, @limit, params["page"]
            @offset ||= @result_pages.offset
            @results = fetcher.results(@offset, @result_pages.per_page)
          else
            @question = ""
          end
          if request.xhr?
            searchable_projects = [[l(:label_project_all), "all"]]
            searchable_projects << [l(:label_my_projects), "my_projects"] unless User.current.memberships.empty?
            searchable_projects << [l(:label_my_bookmarks), "bookmarks"] unless User.current.bookmarked_project_ids.empty?
            searchable_projects << [l(:label_and_its_subprojects, @project.name), "subprojects"] unless @project.nil? || @project.descendants.active.empty?
            searchable_projects << [@project.name, ""] unless @project.nil?
            return render json: {
              form: {
                question: @question,
                all_words: @all_words,
                titles_only: @titles_only,
                attachments: @search_attachments,
                open_issues: @open_issues,
                offset: @offset,
                limit: @limit,
                scope: @scope,
                projects: searchable_projects,
                projects_to_search: projects_to_search,
                object_types: @object_types
              },
              results: {
                items: @results || [],
                counts: {
                  total: @result_count || 0,
                  pages: @result_pages || 0,
                  by_type: @result_count_by_type || {}
                }
              }
            }
          end
          respond_to do |format|
            format.html { render layout: false if request.xhr? }
            format.api do
              @results ||= []
              render layout: false
            end
          end
        end
      end
    end
  end
end

SearchController.send(:include, FridayPlugin::SearchControllerPatch) unless SearchController.included_modules.include?(FridayPlugin::SearchControllerPatch)

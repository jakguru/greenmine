module FridayPlugin
  module WikiControllerPatch
    def self.included(base)
      base.class_eval do
        base.send(:include, FridayHelper)
        alias_method :redmine_base_show, :show

        def index
          pages = @pages.group_by(&:parent_id)
          wiki_response({
            pages: pages
          })
        end

        def date_index
          pages = @pages.group_by { |p| p.updated_on.to_date }
          wiki_response({
            pages: pages
          })
        end

        def new
          @page = WikiPage.new(wiki: @wiki, title: params[:title])
          wiki_content_response
        end

        def show
          wiki_content_response
        end

        def edit
          wiki_content_response
        end

        def update
          wiki_response
        end

        def rename
          wiki_response
        end

        def protect
          wiki_response
        end

        def history
          wiki_response
        end

        def diff
          wiki_response
        end

        def annotate
          wiki_response
        end

        def destroy
          wiki_response
        end

        def destroy_version
          wiki_response
        end

        def export
          wiki_response
        end

        def preview
          wiki_response
        end

        def wiki_content_response
          content = if params[:version] && !User.current.allowed_to?(:view_wiki_edits, @project)
            @page.content_for_version(nil)
          else
            @page.content_for_version(params[:version])
          end
          wiki_response({
            title: @page.pretty_title,
            content: content,
            attachments: content.nil? ? [] : content.page.attachments
          })
        end

        def wiki_response(additional = {})
          if friday_request?
            if @project
              render_project_response({
                wikiData: get_wiki_data(additional)
              })
            else
              render json: get_wiki_data(additional)
            end
          else
            render_blank
          end
        end

        def get_wiki_data(additional = {})
          pages_by_parent = @wiki.pages.with_updated_on
            .includes(wiki: :project)
            .includes(:parent)
            .to_a
            .sort_by { |p| p.is_start_page ? 0 : 1 }
            .group_by(&:parent_id)
          {
            permissions: {
              view_wiki_edits: User.current.allowed_to?(:view_wiki_edits, @project),
              edit_wiki_pages: User.current.allowed_to?(:edit_wiki_pages, @project),
              export_wiki_pages: User.current.allowed_to?(:export_wiki_pages, @project)
            },
            toc: build_tree(pages_by_parent)
          }.merge(additional)
        end

        def build_tree(pages_by_parent, parent_id = nil)
          # Find all pages with the given parent_id
          pages = pages_by_parent[parent_id] || []
          if pages.empty?
            if parent_id.nil?
              return []
            else
              return nil
            end
          end
          pages.map do |page|
            parent = page.parent
            {
              id: page.id,
              title: page.title,
              path: project_wiki_page_path(page.wiki.project, page.title, parent: parent&.title),
              children: build_tree(pages_by_parent, page.id) # Recursively build children
            }
          end
        end

        def save_wiki_response
          unless User.current.allowed_to?(:edit_wiki_pages, @project) && editable?
            render json: {error: "You are not authorized to edit this wiki page."}, status: 403
            return
          end
          @page.safe_attributes = params[:wiki_page]

          @content = @page.content || WikiContent.new(page: @page)
          content_params = params[:content]
          if content_params.nil? && params[:wiki_page].present?
            content_params = params[:wiki_page].slice(:text, :comments, :version)
          end
          content_params ||= {}

          @content.comments = content_params[:comments]
          @text = content_params[:text]
          if params[:section].present? && Redmine::WikiFormatting.supports_section_edit?
            @section = params[:section].to_i
            @section_hash = params[:section_hash]
            @content.text = Redmine::WikiFormatting.formatter.new(@content.text).update_section(@section, @text, @section_hash)
          else
            @content.version = content_params[:version] if content_params[:version]
            @content.text = @text
          end
          @content.author = User.current

          if @page.save_with_content(@content)
            Attachment.attach_files(@page, params[:attachments] || (params[:wiki_page] && params[:wiki_page][:uploads]))
            render json: {
              location: project_wiki_page_path(@project, @page.title)
            }, status: :created
          else
            respond_to do |format|
              format.html { render action: "edit" }
              format.api { render_validation_errors(@content) }
            end
          end
        rescue ActiveRecord::StaleObjectError, Redmine::WikiFormatting::StaleSectionError
          # Optimistic locking exception
          respond_to do |format|
            format.html do
              flash.now[:error] = l(:notice_locking_conflict)
              render action: "edit"
            end
            format.api { render_api_head :conflict }
          end
        end
      end
    end
  end
end

WikiController.send(:include, FridayPlugin::WikiControllerPatch) unless WikiController.included_modules.include?(FridayPlugin::WikiControllerPatch)

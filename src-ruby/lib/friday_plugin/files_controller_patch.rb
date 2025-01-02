module FridayPlugin
  module FilesControllerPatch
    def self.included(base)
      base.class_eval do
        base.send(:include, FridayHelper)
        alias_method :redmine_base_index, :index

        def index
          if friday_request?
            if @project
              render_project_response({
                attachedFiles: attached_files_response
              })
            else
              render json: attached_files_response
            end
          else
            redmine_base_index
          end
        end

        def attached_files_response
          sort_init "filename", "asc"
          sort_update "filename" => "#{Attachment.table_name}.filename",
            "created_on" => "#{Attachment.table_name}.created_on",
            "size" => "#{Attachment.table_name}.filesize",
            "downloads" => "#{Attachment.table_name}.downloads"

          @containers = [Project.includes(:attachments)
            .references(:attachments).reorder(sort_clause).find(@project.id)]
          @containers += @project.versions.includes(:attachments)
            .references(:attachments).reorder(sort_clause).to_a.sort.reverse
          @containers.map(&:attachments).flatten
        end
      end
    end
  end
end

FilesController.send(:include, FridayPlugin::FilesControllerPatch) unless FilesController.included_modules.include?(FridayPlugin::FilesControllerPatch)

module FridayPlugin
  module AdminControllerPatch
    def self.included(base)
      base.class_eval do
        base.send(:include, FridayHelper)
        alias_method :redmine_base_index, :index
        alias_method :redmine_base_info, :info
        alias_method :redmine_base_plugins, :plugins

        def index
          if friday_request?
            @no_configuration_data = Redmine::DefaultData::Loader.no_data?
            render json: {noConfigurationData: @no_configuration_data}
          else
            redmine_base_index
          end
        end

        def info
          if friday_request?
            checklist = {
              defaultAdministratorAccountChanged: User.default_admin_account_changed?,
              fileRepositoryWritable: File.writable?(Attachment.storage_path),
              pluginAssetsWritable: File.writable?(Redmine::Plugin.public_directory),
              allMigrationsHaveBeenRun: !ActiveRecord::Base.connection.migration_context.needs_migration?,
              minimagickAvailable: Object.const_defined?(:MiniMagick),
              convertAvailable: Redmine::Thumbnail.convert_available?,
              gsAvailable: Redmine::Thumbnail.gs_available?
            }
            if Rails.env.production?
              checklist[:defaultActiveJobQueueChanged] = Rails.application.config.active_job.queue_adapter != :async
            end
            render json: {
              redmine: Redmine::Info.versioned_name,
              checklist: checklist,
              environment: Redmine::Info.environment
            }
          else
            redmine_base_info
          end
        end

        def plugins
          if friday_request?
            render json: {plugins: Redmine::Plugin.all}
          else
            redmine_base_plugins
          end
        end

        def integrations
          if friday_request?
            render json: {}
          else
            render_blank
          end
        end
      end
    end
  end
end

AdminController.send(:include, FridayPlugin::AdminControllerPatch) unless AdminController.included_modules.include?(FridayPlugin::AdminControllerPatch)

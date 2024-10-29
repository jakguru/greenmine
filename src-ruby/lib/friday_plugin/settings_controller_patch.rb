module FridayPlugin
  module SettingsControllerPatch
    def self.included(base)
      base.class_eval do
        base.send(:include, FridayHelper)
        alias_method :redmine_base_plugin, :plugin

        def plugin
          if friday_request?
            plugin = Redmine::Plugin.find(params[:id])
            unless plugin.configurable?
              render_404
              nil
            end
            if request.post?
              setting = params[:settings] ? params[:settings].permit!.to_h : {}
              Setting.send :"plugin_#{plugin.id}=", setting
            end
            settings = Setting.send :"plugin_#{plugin.id}"
            render json: {plugin: plugin, settings: settings}
          else
            redmine_base_plugin
          end
        end
      end
    end
  end
end

SettingsController.send(:include, FridayPlugin::SettingsControllerPatch) unless SettingsController.included_modules.include?(FridayPlugin::SettingsControllerPatch)

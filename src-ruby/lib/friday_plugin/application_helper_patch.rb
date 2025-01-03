module FridayPlugin
  module ApplicationHelperPatch
    def self.included(base)
      base.class_eval do
        alias_method :redmine_format_object, :format_object

        def format_object(object, html = true, &block)
          case object
          when BacklogSprint
            object.name
          when Sprint
            object[:name]
          else
            redmine_format_object(object, html, &block)
          end
        end
      end
    end
  end
end

ApplicationHelper.send(:include, FridayPlugin::ApplicationHelperPatch) unless ApplicationHelper.included_modules.include?(FridayPlugin::ApplicationHelperPatch)

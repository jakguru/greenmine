module FridayPlugin
  module QueriesControllerPatch
    def self.included(base)
      base.class_eval do
        base.send(:include, FridayHelper)
        alias_method :redmine_base_filter, :filter

        def filter
          redmine_base_filter
        end
      end
    end
  end
end

QueriesController.send(:include, FridayPlugin::QueriesControllerPatch) unless QueriesController.included_modules.include?(FridayPlugin::QueriesControllerPatch)

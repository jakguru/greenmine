require_dependency "user"

module FridayPlugin
  module UserPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        has_many :user_gitlab_users, class_name: "UserGitlabUser", foreign_key: "user_id"
        has_many :gitlab_users, through: :user_gitlab_projects
        alias_method :redmine_base_allowed_to, :allowed_to?
        safe_attributes "avatar"
        def allowed_to?(action, context, options = {}, &block)
          case action
          when :manage_sprints
            allowed_to_manage_sprints
          else
            redmine_base_allowed_to(action, context, options, &block)
          end
        end
      end
    end

    module InstanceMethods
      def allowed_to_manage_sprints
        if admin? || Setting["plugin_friday"]["users_allowed_to_manage_sprints"].include?(id.to_s)
          true
        end
        group_ids = groups.map(&:id).map(&:to_s)
        Setting["plugin_friday"]["groups_allowed_to_manage_sprints"].any? { |group_id| group_ids.include?(group_id) }
      end
    end
  end
end

User.send(:include, FridayPlugin::UserPatch) unless User.included_modules.include?(FridayPlugin::UserPatch)

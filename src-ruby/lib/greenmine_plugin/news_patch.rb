require_dependency 'news'

module GreenminePlugin
  module NewsPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
      def as_json(options = {})
        original_hash = super(options)
        original_hash.delete('project_id')
        original_hash.delete('author_id')
        original_hash['project'] = project.as_json(only: [:id, :name, :identifier]) if project
        original_hash['author'] = author.as_json(only: [:id, :login, :firstname, :lastname]) if author
        original_hash
      end
    end
  end
end

News.send(:include, GreenminePlugin::NewsPatch) unless News.included_modules.include?(GreenminePlugin::NewsPatch)

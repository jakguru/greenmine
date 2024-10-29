plugin_lib_dir = File.join(File.dirname(__FILE__), "lib", "friday_plugin")

if Rails.try(:autoloaders).try(:zeitwerk_enabled?)
  Rails.autoloaders.main.push_dir plugin_lib_dir
else
  Dir.glob(File.join(plugin_lib_dir, "**", "*.rb")).each do |file|
    require_dependency file
  end
end

Rails.configuration.to_prepare do
  require_dependency "friday_plugin/news_patch"
end

Redmine::Plugin.register :friday do
  name "Friday"
  author "Jak Guru"
  description "A Redmine plugin to transform Redmine into a modern UX/UI Experience"
  version "1.0.0"
  requires_redmine version_or_higher: "5.1"

  settings partial: "settings/friday",
    default: {
      "repository_base_path" => "/var/redmine/repos"
    }
end

if ENV["REDIS_URL"] && !(defined?(Rails::Console) || File.split($0).last == "rake")
  x = Sidekiq.configure_embed do |config|
    config.queues = %w[critical default low]
    config.concurrency = 2
  end
  x.run
  Rails.logger.info "Sidekiq started"
end

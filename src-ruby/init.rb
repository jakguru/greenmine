plugin_lib_dir = File.join(File.dirname(__FILE__), 'lib', 'greenmine_plugin')

if Rails.try(:autoloaders).try(:zeitwerk_enabled?)
  Rails.autoloaders.main.push_dir plugin_lib_dir
else
  Dir.glob(File.join(plugin_lib_dir, '**', '*.rb')).each do |file|
    require_dependency file
  end
end

Rails.configuration.to_prepare do
  require_dependency 'greenmine_plugin/news_patch'
end

Redmine::Plugin.register :greenmine do
  name 'Greenmine'
  author 'Jak Guru'
  description 'A new updated UI for Redmine using VueJS + Vuetify'
  version '1.0.0'
  requires_redmine version_or_higher: '5.1'
end
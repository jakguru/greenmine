Redmine::Plugin.register :greenmine do
  name 'Greenmine'
  author 'Jak Guru'
  description 'A new updated UI for Redmine using VueJS + Vuetify'
  version '1.0.0'
  requires_redmine version_or_higher: '5.1'
end
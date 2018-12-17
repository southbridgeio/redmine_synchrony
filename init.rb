require 'active_resource'

Rails.application.config.eager_load_paths << "#{Rails.root}/plugins/redmine_synchrony/{lib}"

Redmine::Plugin.register :redmine_synchrony do
  name 'Redmine Synchrony plugin'
  author 'Centos-admin.ru'
  description 'Plugin makes copies of issues and journals from another redmine instance via API.'
  version '0.0.5'
  url 'https://github.com/centosadmin/redmine_synchrony'
  author_url 'http://centos-admin.ru'
  settings default: {'empty' => true}, partial: 'settings/synchrony_settings'
end

require 'active_resource'

Rails.application.config.eager_load_paths += Dir.glob("#{Rails.root}/plugins/redmine_synchrony/{lib}")

Redmine::Plugin.register :redmine_synchrony do
  name 'Redmine Synchrony plugin'
  author 'Southbridge'
  description 'Plugin makes copies of issues and journals from another redmine instance via API.'
  version '0.0.5'
  url 'https://github.com/southbridgeio/redmine_synchrony'
  author_url 'https://southbridge.io'
  settings default: {'empty' => true}, partial: 'settings/synchrony_settings'
end

Redmine::Plugin.register :redmine_synchrony do
  name 'Redmine Synchrony plugin'
  author 'Pavel Nemkin'
  description 'Plugin synchronize issues from remote redmine via API'
  version '0.0.1'
  url 'https://github.com/kanfet/redmine_synchrony'
  author_url 'https://github.com/kanfet'
  settings default: {'empty' => true}, partial: 'settings/synchrony_settings'
end

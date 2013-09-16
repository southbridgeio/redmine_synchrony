namespace :redmine_synchrony do

  desc 'Synchronize issues from remote redmine'
  task :issues => :environment do
    require 'synchrony/updater'
    if Setting.plugin_redmine_synchrony['redmine'].present?
      Setting.plugin_redmine_synchrony['redmine'].each do |site_settings|
        Synchrony::Updater.new(site_settings).sync_issues
      end
    end
  end

end
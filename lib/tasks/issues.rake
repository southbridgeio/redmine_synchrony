namespace :redmine_synchrony do

  desc 'Synchronize issues from remote redmine'
  task :issues => :environment do
    require 'synchrony/updater'
    Synchrony::Updater.update_issues
  end

end
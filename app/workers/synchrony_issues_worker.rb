class SynchronyIssuesWorker
  include Sidekiq::Worker

  def perform
    if Setting.plugin_redmine_synchrony['redmine'].present?
      Setting.plugin_redmine_synchrony['redmine'].each do |site_settings|
        Synchrony::Updater.new(site_settings).sync_issues
      end
    end
  end
end

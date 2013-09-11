module Synchrony

  class Updater

    attr_reader :settings

    def initialize(settings)
      @settings = settings
    end

    def update_issues
      prepare_remote_resources
      prepare_local_resources
      issues = RemoteIssue.all(params: { tracker_id: source_tracker.id, updated_on: ">=#{Date.yesterday.strftime('%Y-%m-%d')}" })
      issues.each do |remote_issue|
        issue = Issue.where(synchrony_id: remote_issue.id, project_id: target_project).first
        issue = create_issue(remote_issue) unless issue.present?
      end
    end

    private

    def prepare_remote_resources
      RemoteTracker.site = source_site
      RemoteTracker.headers['X-Redmine-API-Key'] = api_key
      RemoteIssue.site = source_site
      RemoteIssue.headers['X-Redmine-API-Key'] = api_key
      unless source_tracker.present?
        raise StandardError.new("#{I18n.t('synchrony.settings.source_tracker')} with name '#{settings['source_tracker']}' does not exists on #{source_site}")
      end
    end

    def prepare_local_resources
      raise_setting_not_defined('target_project') unless target_project.present?
      raise_setting_not_defined('target_tracker') unless target_tracker.present?
      target_project.trackers << target_tracker unless target_project.trackers.include?(target_tracker)
    end

    def raise_setting_not_defined(setting_name)
      raise StandardError.new("Define '#{I18n.t("synchrony.settings.#{setting_name}")}' in settings")
    end

    def source_site
      raise_setting_not_defined('source_site') unless settings['source_site'].present?
      @source_site ||= (settings['source_site'].end_with?('/') ? settings['source_site'] : "#{settings['source_site']}/")
    end

    def api_key
      raise_setting_not_defined('api_key') unless settings['api_key'].present?
      @api_key ||= settings['api_key']
    end

    def source_tracker
      raise_setting_not_defined('source_tracker') unless settings['source_tracker'].present?
      @source_tracker ||= RemoteTracker.all.find{ |t| t.name == settings['source_tracker'] }
    end

    def target_project
      @target_project ||= Project.where(id: settings['target_project']).first
    end

    def target_tracker
      @target_tracker ||= Tracker.where(id: settings['target_tracker']).first
    end

    def create_issue(remote_issue)
      description = "#{source_site}issues/#{remote_issue.id}\n\n________________\n\n#{remote_issue.description}"
      Issue.create(
          synchrony_id: remote_issue.id,
          subject: remote_issue.subject,
          description: description,
          tracker: target_tracker,
          project: target_project,
          author: User.anonymous
      )
    end

  end

  class RemoteIssue < ActiveResource::Base
    self.format = :xml
    self.element_name = 'issue'
  end

  class RemoteTracker < ActiveResource::Base
    self.format = :xml
    self.element_name = 'tracker'
  end

end
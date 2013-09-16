module Synchrony

  class Updater

    attr_reader :settings

    def initialize(settings)
      @settings = settings
      I18n.locale = :ru # TODO move to settings
      prepare_remote_resources
      prepare_local_resources
    end

    def update_issues
      created_issues = 0
      updated_issues = 0
      issues = RemoteIssue.all(params: { tracker_id: source_tracker.id,
                                         updated_on: ">=#{Date.yesterday.strftime('%Y-%m-%d')}" })
      issues.each do |remote_issue|
        issue = Issue.where(synchrony_id: remote_issue.id, project_id: target_project).first
        if issue.present?
          remote_updated_on = Time.parse(remote_issue.updated_on)
          if issue.synchronized_at != remote_updated_on
            update_journals(issue, remote_issue)
            issue.update_column(:synchronized_at, remote_updated_on)
            updated_issues += 1
          end
        else
          issue = create_issue(remote_issue) unless issue.present?
          update_journals(issue, remote_issue)
          created_issues += 1
        end
      end
      puts "Issues created: #{created_issues}"
      puts "Issues updated: #{updated_issues}"
    end

    private

    def prepare_remote_resources
      %w(Synchrony::RemoteTracker Synchrony::RemoteIssue Synchrony::RemoteIssueStatus
                Synchrony::RemoteUser Synchrony::RemoteIssuePriority).each do |resource_class_name|
        resource_class = resource_class_name.constantize
        resource_class.site = source_site
        resource_class.headers['X-Redmine-API-Key'] = api_key
      end
      begin
        unless source_tracker.present?
          raise StandardError.new("#{I18n.t('synchrony.settings.source_tracker')} " +
                                      "with name '#{settings['source_tracker']}' does not exists on #{source_site}")
        end
      rescue
        raise StandardError.new("Connection refused to #{source_site}. " +
                                    "Please check '#{I18n.t('synchrony.settings.source_site')}'")
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
      Issue.transaction do
        issue = Issue.create(
            synchrony_id: remote_issue.id,
            subject: remote_issue.subject,
            description: description,
            tracker: target_tracker,
            project: target_project,
            author: User.anonymous,
            synchronized_at: Time.parse(remote_issue.updated_on)
        )
        issue.reload
      end
    end

    def update_journals(issue, remote_issue)
      remote_issue = RemoteIssue.find(remote_issue.id, params: { include: :journals })
      remote_issue.journals.each do |remote_journal|
        journal = issue.journals.where(synchrony_id: remote_journal.id).first
        remote_created_on = Time.parse(remote_journal.created_on)
        unless journal.present?
          notes = "h3. \"#{remote_journal.user.name}\":#{source_site}users/#{remote_journal.user.id}:\n\n" +
              "#{journal_details(remote_journal)}#{remote_journal.notes}"
          Journal.transaction do
            issue.journals.create(user: User.anonymous, notes: notes, synchrony_id: remote_journal.id)
            Journal.where(id: issue.journals.last.id).update_all(created_on: remote_created_on)
          end
        end
        issue.journals.reload
      end
    end

    def journal_details(remote_journal)
      return '' if remote_journal.details.empty?
      remote_journal.details.map do |detail|
        if detail.property == 'attr' && %w(status_id assigned_to_id priority_id).include?(detail.name)
          self.send("details_for_#{detail.name}", detail)
        end
      end.reject{ |d| d.blank? }.join("\n") + "\n\n"
    end

    def details_for_status_id(detail)
      result = ''
      old_status = RemoteIssueStatus.by_id(detail.old_value)
      new_status = RemoteIssueStatus.by_id(detail.new_value)
      result << "*#{I18n.t(:label_issue_status)}:* "
      result << old_status.name if old_status
      result << ' >> '
      result << new_status.name if new_status
      result
    end

    def details_for_assigned_to_id(detail)
      result = ''
      old_user = RemoteUser.find(detail.old_value) if detail.old_value.present?
      new_user = RemoteUser.find(detail.new_value) if detail.new_value.present?
      result << "*#{I18n.t(:field_assigned_to)}:* "
      result << "#{old_user.firstname} #{old_user.lastname}" if old_user
      result << ' >> '
      result << "#{new_user.firstname} #{new_user.lastname}" if new_user
      result
    end

    def details_for_priority_id(detail)
      result = ''
      old_priority = RemoteIssuePriority.by_id(detail.old_value)
      new_priority = RemoteIssuePriority.by_id(detail.new_value)
      result << "*#{I18n.t(:field_priority)}:* "
      result << old_priority.name if old_priority
      result << ' >> '
      result << new_priority.name if new_priority
      result
    end

  end

end
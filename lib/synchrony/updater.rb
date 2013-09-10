module Synchrony

  class Updater

    def self.update_issues
      issues = RemoteIssue.all(params: { updated_on: ">=#{Date.yesterday.strftime('%Y-%m-%d')}" })
      issues.each do |issue|
        # TODO Issue.create()
      end
    end

  end

  class RemoteIssue < ActiveResource::Base
    headers['X-Redmine-API-Key'] = 'd632644143fd7a41f37df26e44a59480d29bf19a' # TODO from settings
    self.format = :xml
    self.element_name = 'issue'
    self.site = 'http://localhost:3001/' # TODO from settings
  end

end
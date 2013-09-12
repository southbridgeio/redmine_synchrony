module Synchrony

  class RemoteIssueStatus < ActiveResource::Base
    self.format = :xml
    self.element_name = 'issue_status'

    def self.by_id(id)
      RemoteIssueStatus.all.find{ |s| s.id == id }
    end
  end

end
module Synchrony

  class RemoteIssuePriority < ActiveResource::Base
    self.format = :xml
    self.element_name = 'issue_priority'
    self.prefix = '/enumerations/'

    def self.by_id(id)
      RemoteIssuePriority.all.find{ |s| s.id == id }
    end
  end

end
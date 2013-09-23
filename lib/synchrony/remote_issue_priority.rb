module Synchrony

  class RemoteIssuePriority < ActiveResource::Base
    self.format = :xml
    self.element_name = 'issue_priority'
    self.prefix = '/enumerations/'

    def self.by_id(id)
      priorities = RemoteIssuePriority.all
      priorities.find{ |s| s.id == id } if priorities.present?
    end
  end

end
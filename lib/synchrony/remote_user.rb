module Synchrony

  class RemoteUser < ActiveResource::Base
    self.format = :xml
    self.element_name = 'user'

    def self.by_id(id)
      RemoteUser.find(id)
    rescue ActiveResource::ResourceNotFound
      Rails.logger.warn "#{self.site} User with id='#{id}' not found"
      nil
    end
  end

end
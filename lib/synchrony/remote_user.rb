module Synchrony

  class RemoteUser < ActiveResource::Base
    self.format = :xml
    self.element_name = 'user'
  end

end
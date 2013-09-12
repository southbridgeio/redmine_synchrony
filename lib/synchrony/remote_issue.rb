module Synchrony

  class RemoteIssue < ActiveResource::Base
    self.format = :xml
    self.element_name = 'issue'
  end

end
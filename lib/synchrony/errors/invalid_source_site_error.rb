module Synchrony::Errors

  class InvalidSourceSiteError < StandardError

    def initialize(source_site)
      super("Connection refused to #{source_site}. Please check '#{I18n.t('synchrony.settings.source_site')}'")
    end

  end

end
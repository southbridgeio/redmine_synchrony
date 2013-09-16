module Synchrony::Errors

  class InvalidSourceTrackerError < StandardError

    def initialize(tracker, site)
      super("#{I18n.t('synchrony.settings.source_tracker')} with name '#{tracker}' does not exists on #{site}")
    end

  end

end
module Synchrony::Errors

  class InvalidSettingError < StandardError

    def initialize(setting_name)
      super("Define '#{I18n.t("synchrony.settings.#{setting_name}")}' in settings")
    end

  end

end
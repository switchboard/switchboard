module I18nExtension
  extend ActiveSupport::Concern

  module ClassMethods
    def locale_for(opts)
      val = opts[:val]
      key = opts[:key]

      available_locales.detect do |locale|
        locale_val = t(key, locale: locale)
        if locale_val.is_a?(Array)
          val.in? locale_val
        else
          val == locale_val
        end
      end

    end
  end
end

I18n.send(:include, I18nExtension)
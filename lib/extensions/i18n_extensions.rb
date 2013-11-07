module I18nExtension
  extend ActiveSupport::Concern

  module ClassMethods
    def locales_for(*args)
      options  = args.last.is_a?(Hash) ? args.pop : {}
      key      = args.shift

      {}.tap do |hsh|
        available_locales.collect do |locale|
          options[:locale] = locale
          hsh[t(key, options)] = locale
        end
      end
    end
  end
end

I18n.send(:include, I18nExtension)
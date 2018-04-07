require 'i18n'

I18n.config.available_locales = :en

module Normalizer
  def self.normalize_name(name)
    I18n.transliterate(name).downcase.gsub(/[^\w]/,' ').split.compact.sort.uniq.join(' ')
  end
end
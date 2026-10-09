# frozen_string_literal: true

module AppHost
  def self.canonical
    ENV.fetch('APP_HOST')
  end

  # NOTE: for en dont use path /en but /
  def self.locale_for_url(locale = I18n.locale)
    return nil if locale&.to_sym == I18n.default_locale

    locale
  end

  # Экземпляр обслуживает одну локаль (I18n.default_locale): переключение локалей выключено в LocaleConcern,
  # а /ru и /en отдают ту же страницу, что и /. Для поисковиков это дубли, поэтому карты сайта, hreflang и robots.txt
  # строятся только по served_locales, а адреса с префиксом локали редиректятся на канонические (config/routes.rb).
  # SINGLE_LOCALE=false возвращает прежнее многоязычное поведение.
  def self.single_locale?
    ENV.fetch('SINGLE_LOCALE', 'true') != 'false'
  end

  def self.served_locales
    single_locale? ? [I18n.default_locale] : I18n.available_locales
  end

  # Карты сайта пишутся в S3-бакет (DO Spaces) только в production при заданном бакете, иначе — файлами в public/sitemaps/
  def self.sitemap_in_bucket?
    Rails.env.production? && ENV['DO_SPACES_SITEMAP_BUCKET'].present?
  end
end

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

  # Карты сайта пишутся в S3-бакет (DO Spaces) только при явном SITEMAP_STORAGE=bucket в production, иначе — файлами в
  # public/sitemaps/. Одного DO_SPACES_SITEMAP_BUCKET мало: эти переменные могут быть в .env «по умолчанию» и указывать на чужой бакет.
  def self.sitemap_in_bucket?
    Rails.env.production? && ENV['SITEMAP_STORAGE'] == 'bucket' && ENV['DO_SPACES_SITEMAP_BUCKET'].present?
  end

  # Образы упражнений публикуются под тегом lv<id версии> (docker tag + push) только при EXERCISE_IMAGES_VERSIONED=true;
  # по умолчанию (Codica, нет доступа к реестру Hexlet) — локальный :latest без push.
  def self.versioned_exercise_images?
    ENV['EXERCISE_IMAGES_VERSIONED'] == 'true'
  end
end

# frozen_string_literal: true

# Set the host name for URL creation
SitemapGenerator::Sitemap.create_index = true
SitemapGenerator::Sitemap.max_sitemap_links = 45_000
# Главная добавляется ниже явно: так она попадает в карту один раз
SitemapGenerator::Sitemap.include_root = false

if AppHost.sitemap_in_bucket?
  SitemapGenerator::Sitemap.adapter = SitemapGenerator::AwsSdkAdapter.new(
    configus.sitemap.bucket.name,
    **configus.sitemap.bucket.credentials
  )

  SitemapGenerator::Sitemap.compress = true
else
  # без бакета карта лежит файлами в public/sitemaps/<локаль>/ (sitemap.xml и файлы групп)
  SitemapGenerator::Sitemap.compress = false
end

module SitemapGeneratorHelper
  # hreflang для карты: только локали, которые обслуживает экземпляр (AppHost.served_locales);
  # x-default ведёт на локаль по умолчанию. Для одной локали альтернатив нет вовсе.
  def build_alternates(options)
    return [] if AppHost.served_locales.size < 2

    existed_in_locales = AppHost.served_locales.filter do |locale|
      options[:current] == locale || options[:check_exists].call(locale)
    end

    alternates = existed_in_locales.map do |locale|
      { href: options[:url].call(AppHost.locale_for_url(locale)), lang: locale }
    end

    alternates << { href: options[:url].call(AppHost.locale_for_url(I18n.default_locale)), lang: :'x-default' } if alternates.size > 1

    alternates
  end
end

SitemapGenerator::Interpreter.include SitemapGeneratorHelper

AppHost.served_locales.each do |current_locale|
  I18n.with_locale(current_locale) do
    SitemapGenerator::Sitemap.sitemaps_path = "sitemaps/#{current_locale}/"
    # карта всегда с https и каноническим хостом (root_url давал http://, т.к. протокол в default_url_options не задан)
    Rails.application.routes.default_url_options[:protocol] = 'https'
    SitemapGenerator::Sitemap.default_host = "https://#{AppHost.canonical}"

    SitemapGenerator::Sitemap.create do
      add root_path(locale: AppHost.locale_for_url(current_locale)), changefreq: :daily, priority: 1.0

      group(filename: :languages) do
        scope = Language.with_progress(:completed).joins(current_version: :infos)
        scope.merge(Language::Version::Info.with_locale).find_each do |language|
          alternates = build_alternates(current: current_locale,
                                        check_exists: ->(locale) { scope.merge(Language::Version::Info.with_locale(locale)).exists?(slug: language.slug) },
                                        url: ->(locale) { language_url(id: language.slug, locale: locale) })
          add language_path(language.slug, locale: AppHost.locale_for_url(current_locale)), changefreq: :weekly, lastmod: nil, alternates: alternates, priority: 0.9

          # только уроки текущей версии курса: страница урока (Web::Languages::LessonsController#show) для остальных отдаёт 404
          language.current_lessons.find_each do |lesson|
            alternates = build_alternates(current: current_locale,
                                          check_exists: ->(locale) { scope.merge(Language::Version::Info.with_locale(locale)).find_by(slug: language.slug)&.lessons&.exists?(slug: lesson.slug) },
                                          url: ->(locale) { language_lesson_url(language.slug, lesson.slug, locale: locale) })
            add language_lesson_path(language.slug, lesson.slug, locale: AppHost.locale_for_url(current_locale)), changefreq: :weekly, lastmod: nil, priority: 0.8, alternates: alternates
          end
        end
      end
    end
  end
end

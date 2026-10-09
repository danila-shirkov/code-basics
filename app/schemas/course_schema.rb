# frozen_string_literal: true

class CourseSchema
  class << self
    include Rails.application.routes.url_helpers

    def to_builder(language, info)
      Jbuilder.new do |json|
        json.set! '@type', 'Course'
        # squish: значения из БД приходят с переводом строки в конце, он попадал в name и description
        json.name info.header.to_s.squish
        json.url language_url(language.slug, locale: AppHost.locale_for_url(info.locale))
        json.description info.description.to_s.squish
        json.inLanguage info.locale.to_s
        json.isAccessibleForFree true
        json.provider ProviderSchema.to_builder
      end
    end
  end
end

# frozen_string_literal: true

# JSON-LD урока: учебный ресурс, входящий в курс. Показывается на странице урока в связке с BreadcrumbList.
class LessonSchema
  class << self
    include Rails.application.routes.url_helpers

    def to_builder(language, lesson, info, course_name:)
      locale = AppHost.locale_for_url(info.locale)

      Jbuilder.new do |json|
        json.set! '@type', 'LearningResource'
        json.name info.name.to_s.squish
        json.url language_lesson_url(language.slug, lesson.slug, locale: locale)
        json.description MetaDescription.build(info.theory, fallback: info.name)
        json.inLanguage info.locale.to_s
        json.isAccessibleForFree true
        json.learningResourceType 'lesson'
        json.isPartOf do
          json.set! '@type', 'Course'
          json.name course_name.to_s.squish
          json.url language_url(language.slug, locale: locale)
        end
        json.provider ProviderSchema.to_builder
      end
    end
  end
end

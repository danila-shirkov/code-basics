# frozen_string_literal: true

# Данные главной страницы: группы курсов (по категориям), число уроков и первый урок каждого курса — всё из базы.
#
# Правила (ТЗ главной, п. 5):
# - «урок» — урок текущей версии курса, у которого есть текст в нужной локали (как на странице курса: @infos_by_lesson);
# - «первый урок» — урок текущей версии с минимальным natural_order (как @first_lesson на странице курса), а не первый в sitemap;
# - часы — Language#duration, то же число, что показывает страница курса.
class HomeCatalog
  # Курс, с которого предлагаем начать (кнопка в hero); если его нет в базе — первый курс каталога
  START_SLUG = 'python'

  # Порядок групп на странице; категории вне списка идут следом
  GROUP_ORDER = %w[layouting programming].freeze

  Course = Struct.new(:language, :lessons_count, :first_lesson_slug) do
    delegate :slug, :duration, to: :language

    def name
      language.current_version.name
    end

    def lessons_count?
      lessons_count.to_i.positive?
    end

    def hours?
      duration.to_i.positive?
    end
  end

  Group = Struct.new(:category, :courses)

  def initialize(locale: I18n.locale)
    @locale = locale
  end

  # [Group, ...] — только группы, в которых есть курсы
  def groups
    @groups ||= begin
      by_category = languages.group_by(&:category)
      by_category.reject { |category, _| category.nil? }.sort_by { |category, _| group_position(category) }.map do |category, group_languages|
        Group.new(category, group_languages.map { |language| build_course(language) })
      end
    end
  end

  def courses
    @courses ||= groups.flat_map(&:courses)
  end

  # Курс для кнопки hero: Python, а если его нет (или в нём нет уроков) — первый курс, в котором есть первый урок
  def start_course
    courses.find { |course| course.slug == START_SLUG && course.first_lesson_slug } || courses.find(&:first_lesson_slug)
  end

  private

  def build_course(language)
    version_id = language.current_version_id
    Course.new(language, lessons_counts[version_id], first_lesson_slugs[version_id])
  end

  def languages
    @languages ||= Language.with_progress(:completed)
                           .with_locale(@locale)
                           .ordered
                           .includes(:current_version, :category)
                           .to_a
  end

  def version_ids
    @version_ids ||= languages.filter_map(&:current_version_id)
  end

  # { language_version_id => число уроков с текстом в локали }
  def lessons_counts
    @lessons_counts ||= Language::Lesson::Version::Info
                        .with_locale(@locale)
                        .where(language_version_id: version_ids)
                        .group(:language_version_id)
                        .distinct
                        .count(:version_id)
  end

  # { language_version_id => slug урока с минимальным natural_order }
  def first_lesson_slugs
    @first_lesson_slugs ||= Language::Lesson::Version
                            .where(language_version_id: version_ids)
                            .select('DISTINCT ON (language_lesson_versions.language_version_id) language_lesson_versions.*')
                            .order(Arel.sql('language_lesson_versions.language_version_id, language_lesson_versions.natural_order'))
                            .includes(:lesson)
                            .to_h { |lesson_version| [lesson_version.language_version_id, lesson_version.lesson.slug] }
  end

  def group_position(category)
    GROUP_ORDER.index(category.slug) || GROUP_ORDER.size
  end
end

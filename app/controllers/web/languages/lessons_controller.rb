# frozen_string_literal: true

class Web::Languages::LessonsController < Web::Languages::ApplicationController
  before_action :authenticate_user!, only: [:next_lesson]

  def show
    # AMP-версии уроков не поддерживаем (невалидны, чужой счётчик, Google не требует): отдаём 301 на обычную страницу
    if params[:format] == 'amp'
      redirect_to language_lesson_path(params[:language_id], params[:id], format: nil), status: :moved_permanently
      return
    end

    # Несуществующий урок — настоящая 404 (раньше был 302 на страницу курса, для поисковиков «мягкая» ошибка)
    @lesson = resource_language.lessons.find_by!(slug: params[:id])

    @lesson_version = resource_language.current_lesson_versions.find_by!(lesson: @lesson)
    @info = @lesson_version.infos.with_locale.sole
    @language_lessons_count = resource_language.current_lessons.count
    @lessons_info = resource_language.current_lesson_infos
                                     .joins(version: :lesson)
                                     .includes(version: :lesson)
                                     .with_locale
                                     .order('language_lesson_versions.natural_order')

    if current_user.guest?
      gon.lesson_member = Language::Lesson::MemberFake.new
    else
      language_member = resource_language.members.find_or_create_by!(user: current_user)
      lesson_member = language_member.lesson_members.find_or_create_by!(language: resource_language, user: current_user, lesson: @lesson)

      gon.lesson_member = lesson_member
    end

    gon.language = resource_language.slug
    gon.lesson_version = @lesson_version
    gon.lesson = @lesson

    title = [@info, resource_language.current_version.name].join(' | ').squish
    # без markdown/HTML и префикса «[Язык] — Урок —» (название уже в title), ≈155 символов по границе слова
    description = MetaDescription.build(@info.theory, fallback: @info.name)

    seo_tags = {
      title: title,
      canonical: language_lesson_url(@lesson.language.slug, @lesson.slug),
      image_src: view_context.image_url("#{@lesson.language.slug}.png"),
      description: description,
      og: {
        type: 'article',
        locale: I18n.locale,
        title: title,
        url: language_lesson_url(@lesson.language.slug, @lesson.slug),
        image: view_context.image_url("#{@lesson.language.slug}.png")
      }
    }
    set_meta_tags seo_tags

    @switching_locales.each do |locale,|
      if @lesson_version.infos.exists?(locale: locale)
        @switching_locales[locale] = language_lesson_url(resource_language.slug, @lesson.slug, locale: AppHost.locale_for_url(locale))
      end
    end
  end

  def next_lesson
    language_slug = params[:language_id]
    lesson = resource_language.lessons.find_by!(slug: params[:id])
    lesson_version = resource_language.current_lesson_versions.find_by!(lesson: lesson)

    # language_member = current_user.language_members.find_by! language: resource_language

    next_lesson = lesson_version.next_lesson

    # TODO Добавить сериализацию language, lesson, language_member
    # NOTE Временно отключил и заменил на language_finished
    # js_event_options = {
    #   user: current_user,
    #   language: resource_language.to_hash,
    #   lesson: next_lesson&.to_hash,
    #   language_member: language_member.to_hash,
    #   lessons_started: current_user.lesson_members.where(language: resource_language).count,
    #   lessons_finished: current_user.lesson_members.where(language: resource_language).finished.count
    # }
    # js_event :next_lesson, js_event_options

    if next_lesson.nil?
      redirect_to language_path(language_slug)
    else
      redirect_to language_lesson_path(language_slug, next_lesson.slug)
    end
  end

  def prev_lesson
    language_slug = params[:language_id]
    lesson = resource_language.lessons.find_by!(slug: params[:id])
    lesson_version = resource_language.current_lesson_versions.find_by!(lesson: lesson)

    prev_lesson = lesson_version.prev_lesson

    if prev_lesson.nil?
      redirect_to language_path(language_slug)
    else
      redirect_to language_lesson_path(language_slug, prev_lesson.slug)
    end
  end
end

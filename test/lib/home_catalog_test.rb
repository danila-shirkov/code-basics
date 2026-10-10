# frozen_string_literal: true

require 'test_helper'

class HomeCatalogTest < ActiveSupport::TestCase
  setup do
    @catalog = HomeCatalog.new
  end

  test 'groups follow the configured category order' do
    positions = @catalog.groups.map { |group| HomeCatalog::GROUP_ORDER.index(group.category.slug) || HomeCatalog::GROUP_ORDER.size }

    assert_not_empty positions
    assert_equal positions.sort, positions
  end

  test 'only completed courses with a text in the locale are listed' do
    slugs = @catalog.courses.map(&:slug)

    assert_includes slugs, 'javascript'
    assert_not_includes slugs, 'elixir' # in_development
  end

  test 'lessons count is the number of current lessons with a text in the locale, as on the course page' do
    course = @catalog.courses.find { |item| item.slug == 'javascript' }
    expected = course.language.current_lesson_infos.with_locale.index_by(&:version_id).size

    assert_predicate expected, :positive?
    assert_equal expected, course.lessons_count
  end

  test 'lessons total is the sum over the listed courses' do
    assert_equal @catalog.courses.sum { |course| course.lessons_count.to_i }, @catalog.lessons_total
    assert_equal @catalog.courses.size, @catalog.courses_count
  end

  test 'first lesson is the one with the minimal natural_order, as on the course page' do
    course = @catalog.courses.find { |item| item.slug == 'javascript' }

    assert_equal course.language.current_lessons.ordered.first.slug, course.first_lesson_slug
  end

  test 'start course is python, or the first course with a lesson when python is not available' do
    expected = @catalog.courses.find { |course| course.slug == HomeCatalog::START_SLUG && course.first_lesson_slug } ||
               @catalog.courses.find(&:first_lesson_slug)

    assert_not_nil @catalog.start_course
    assert_equal expected, @catalog.start_course
    assert_not_nil @catalog.start_course.first_lesson_slug
  end

  test 'a missing lessons count or hours is not shown instead of zero' do
    course = HomeCatalog::Course.new(Language.new(lessons_count: 0), 0, nil)

    assert_not course.lessons_count?
    assert_not course.hours?
  end
end

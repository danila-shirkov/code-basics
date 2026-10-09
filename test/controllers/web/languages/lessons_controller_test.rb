# frozen_string_literal: true

require 'test_helper'

class Web::Languages::LessonsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @lesson = language_lessons(:two)
    @language = @lesson.language
    @info = @lesson.infos.last
    @user = users(:full)
  end

  test 'show' do
    get language_lesson_url(@language.slug, @lesson.slug)
    assert_response :success
  end

  test 'show amp redirects to the regular page' do
    get language_lesson_url(@language.slug, @lesson.slug, format: :amp)
    assert_response :moved_permanently
    assert_redirected_to language_lesson_url(@language.slug, @lesson.slug)
  end

  test 'show unknown lesson is a real 404' do
    assert_raises(ActiveRecord::RecordNotFound) do
      get language_lesson_url(@language.slug, 'no-such-lesson')
    end
  end

  test 'show has a clean description without markdown' do
    get language_lesson_url(@language.slug, @lesson.slug)
    assert_response :success
    assert_select 'meta[name=description]' do |tags|
      content = tags.first['content']
      assert_not_includes content, '```'
      assert_operator content.length, :<=, 160
    end
    assert_select 'link[rel=amphtml]', 0
  end

  test 'show (signed in)' do
    sign_in_as(:full)
    get language_lesson_url(@language.slug, @lesson.slug)
    assert_response :success
  end

  test 'show first lesson (signed in)' do
    # TODO add fixtures
    # sign_in_as(:full)
    # get language_lesson_url(@language.slug, @lesson.slug)
    # assert_response :success
  end

  test 'show last lesson (signed in)' do
    # TODO add fixtures
    # sign_in_as(:full)
    # get language_lesson_url(@language.slug, @lesson.slug)
    # assert_response :success
  end

  test 'next_lesson' do
    sign_in_as(:full)
    third_language_lesson = language_lessons(:three)

    get next_lesson_language_lesson_url(@language.slug, @lesson.slug)
    assert_response :redirect

    assert_redirected_to language_lesson_url(@language.slug, third_language_lesson.slug)
  end

  test 'prev_lesson' do
    first_language_lesson = language_lessons(:one)

    get prev_lesson_language_lesson_url(@language.slug, @lesson.slug)
    assert_response :redirect

    assert_redirected_to language_lesson_url(@language.slug, first_language_lesson.slug)
  end
end

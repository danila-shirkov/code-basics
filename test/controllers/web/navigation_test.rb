# frozen_string_literal: true

require 'test_helper'

class Web::NavigationTest < ActionDispatch::IntegrationTest
  setup do
    @codica = ENV.fetch('BASE_DOMAIN')
  end

  test 'the name Códica Básicos is text, not a picture, and leads to the home page of this site, not to codica.la' do
    I18n.with_locale(:es) do
      get root_url

      assert_select '.navbar a.navbar-brand' do |links|
        assert_equal root_path, links.first['href']
        assert_equal 'Códica Básicos', links.first.text.strip
      end
      assert_select '.navbar a.navbar-brand img', 0
    end
  end

  test 'ways to codica.la are separate explicit links marked as external' do
    I18n.with_locale(:es) do
      get root_url

      assert_select ".navbar a.nav-link[href='#{@codica}/carreras'][title]", text: /Carreras/
      assert_select ".navbar a.nav-link[href='#{@codica}'][title]", text: /Códica/
      assert_select '.navbar a.nav-link', text: /Nosotros/, count: 0
    end
  end

  test 'courses menu starts with all courses and the categories' do
    I18n.with_locale(:es) do
      get root_url

      assert_select ".dropdown-menu a.dropdown-item[href='#{root_path(anchor: 'cursos')}']", text: 'Todos los cursos'
      Language::Category.find_each do |category|
        assert_select ".dropdown-menu a.dropdown-item[href='#{language_category_path(category.slug)}']", 1
      end
    end
  end

  test 'about us and contacts are in the footer' do
    I18n.with_locale(:es) do
      get root_url

      assert_select "footer a[href='#{@codica}/nosotros']", text: 'Nosotros'
      assert_select "footer a[href='#{@codica}/contactos']", text: 'Contacto'
    end
  end

  test 'the header on a lesson page is compact: no links that lead away from the task' do
    lesson = language_lessons(:two)

    get language_lesson_url(lesson.language.slug, lesson.slug)

    assert_select '.navbar a.navbar-brand', 1
    assert_select ".navbar a.nav-link[href='#{@codica}/carreras']", 0
    assert_select ".navbar a.nav-link[href='#{@codica}']", 0
  end
end

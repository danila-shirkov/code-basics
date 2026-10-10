# frozen_string_literal: true

require 'test_helper'
require 'minitest/mock'

class Web::HomeControllerTest < ActionDispatch::IntegrationTest

  test 'index' do
    get root_url
    assert_response :success
  end

  test '#index with stored locale' do
    open_session do |s|
      s.get s.root_url(locale: :ru), headers: {
        'User-Agent': 'Mozilla'
      }
      s.assert_response :success

      s.get s.root_url(locale: nil), headers: {
        'User-Agent': 'Mozilla'
      }
      s.assert_response :redirect
    end
  end

  test '#robots' do
    get robots_url(format: :txt)
    assert_response :success
  end

  # --- экземпляр с одной локалью (см. AppHost.single_locale?) ---

  test '#robots with single locale lists only the default locale sitemap' do
    AppHost.stub :single_locale?, true do
      get '/robots.txt'
      assert_response :success
      assert_includes response.body, "/sitemaps/#{I18n.default_locale}/sitemap.xml"
      I18n.available_locales.without(I18n.default_locale).each do |locale|
        assert_not_includes response.body, "/sitemaps/#{locale}/sitemap.xml"
      end
    end
  end

  test 'single locale: urls with a locale prefix redirect to the canonical url' do
    AppHost.stub :single_locale?, true do
      %w[/ru /en /es].each do |path|
        get path
        assert_response :moved_permanently, path
        assert_redirected_to '/'
      end

      get '/ru/languages/html?utm=1'
      assert_response :moved_permanently
      assert_redirected_to '/languages/html?utm=1'
    end
  end

  test 'single locale: url without a prefix is not redirected' do
    AppHost.stub :single_locale?, true do
      get '/'
      assert_response :success
    end
  end

  test 'structured data describes the organization of this site, not Hexlet' do
    get root_url
    assert_response :success
    assert_not_includes response.body, 'Helsinki'
    assert_not_includes response.body, 'FI26641607'
    assert_includes response.body, 'codica.la'
  end

  test 'single locale: hreflang points only to the default locale' do
    AppHost.stub :single_locale?, true do
      get '/'
      assert_response :success
      assert_select "link[rel=alternate][hreflang='#{I18n.default_locale}']", 1
      assert_select "link[rel=alternate][hreflang='x-default']", 1
      I18n.available_locales.without(I18n.default_locale).each do |locale|
        assert_select "link[rel=alternate][hreflang='#{locale}']", 0
      end
    end
  end

  # --- новая главная (ТЗ главной) ---

  test 'landing has one h1, five h2 for guests and six native faq items without scripts of its own' do
    get root_url
    assert_response :success

    assert_select 'main h1', 1
    assert_select 'main h2', 5
    assert_select 'main details', 6
    assert_select 'main details[open]', 1
    assert_select 'main script', 0
    assert_select 'main a.hb-btn--primary', 1
  end

  test 'tag manager (with the counters inside) is loaded only in production' do
    get root_url

    assert_not_includes response.body, 'googletagmanager.com'
  end

  test 'landing hides the sign up call for signed in users' do
    sign_in_as :one
    get root_url
    assert_response :success

    assert_select 'main h1', 1
    assert_select 'main h2', 4
    assert_select '.hb-final', 0
    assert_select '.hb-note', 0
  end

  test 'landing links every course to its first lesson by position and to the course page' do
    get root_url
    course = HomeCatalog.new.courses.find { |item| item.slug == 'javascript' }

    assert_select "#cursos a[href='#{language_lesson_path(course.slug, course.first_lesson_slug)}']", 1
    assert_select "#cursos a[href='#{language_path(course.slug)}']", 1
    Language::Category.find_each do |category|
      next unless HomeCatalog.new.groups.any? { |group| group.category == category }

      assert_select "#cursos a[href='#{language_category_path(category.slug)}']", 2
    end
  end

  test 'landing numbers come from the database' do
    get root_url
    catalog = HomeCatalog.new

    assert_select '.hb-stat strong', text: catalog.courses_count.to_s
    assert_select '.hb-stat strong', text: catalog.lessons_total.to_s
  end

  test 'landing in Spanish: copy, metadata, brand and links to codica.la' do
    I18n.with_locale(:es) do
      get root_url
      assert_response :success

      assert_select 'main h1', text: 'Aprende programación gratis, paso a paso'
      assert_select 'main h1 mark', text: 'gratis'
      assert_select 'main h2', text: 'Elige tu camino'
      assert_select 'main h2', text: 'Así aprendes, lección por lección'
      assert_select 'main h2', text: '¿Y después de los cursos gratuitos?'
      assert_select 'main h2', text: 'Preguntas frecuentes'
      assert_select 'main h2', text: 'Empieza hoy tu primera lección'

      title = css_select('title').first.text
      description = css_select('meta[name=description]').first['content']

      assert_equal 'Cursos gratuitos de programación en línea | Códica Básicos', title
      assert_operator title.length, :<=, 60
      assert_equal 'Cursos gratuitos de programación para principiantes: Python, JavaScript, HTML, CSS, PHP y Java. Aprende en español con Códica Básicos.', description
      assert_operator description.length, :<=, 155
      assert_select "meta[property='og:site_name'][content='Códica Básicos']"
      assert_select "meta[property='og:title'][content='Cursos gratuitos de programación en línea']"

      assert_no_match(/code\s*basics/i, response.body)
      assert_operator css_select('main').first.text.split.size, :>=, 300

      utm = 'utm_source=basicos&utm_medium=site&utm_campaign=home_carreras'
      assert_select "main a[href='https://codica.la/carreras/frontend?#{utm}']", 1
      assert_select "main a[href='https://codica.la/carreras/fullstack?#{utm}']", 1
      assert_select "main a[href='https://codica.la/carreras/python?#{utm}']", 1
      assert_select "main a[href='https://codica.la/carreras?#{utm}']", 2 # кнопка блока 5 и ссылка в ответе про сертификат
      assert_select 'main a[rel*=nofollow]', 0

      assert_select 'main summary', text: '¿Hay certificado al terminar?'
      assert_select 'main details p a', text: 'carreras'
      assert_select '.hb-final a[href=?]', new_user_path
    end
  end
end

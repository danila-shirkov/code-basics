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
end

# frozen_string_literal: true

require 'test_helper'

class Web::PagesControllerTest < ActionDispatch::IntegrationTest
  %w[tos about privacy authors].each do |slug|
    test slug do
      get page_url(slug)
      assert_response :success
    end
  end

  test 'about in Spanish tells what the project is: open source, made by Códica students' do
    I18n.with_locale(:es) do
      get page_url(:about)
      assert_response :success

      assert_select 'h1', text: '¿Qué es Códica Básicos?'
      assert_select '.container', text: /código abierto creado por estudiantes de Códica/
      assert_select "a[href='#{ExternalLinks.platform_source_curl}']"
      assert_select "a[href='#{ENV.fetch('BASE_DOMAIN')}/carreras']"
      assert_no_match(/code\s*basics|hexlet team/i, response.body)
      assert_select 'meta[name=description]' do |tags|
        assert_operator tags.first['content'].length, :<=, 155
      end
    end
  end

  test 'the footer links to the about page' do
    I18n.with_locale(:es) do
      get root_url

      assert_select "footer a[href='#{page_path(:about)}']", text: 'Acerca del proyecto'
    end
  end
end

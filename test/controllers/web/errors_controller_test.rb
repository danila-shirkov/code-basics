# frozen_string_literal: true

require 'test_helper'

# NOTE: ActionController::TestCase, а не IntegrationTest: статический public/404.html перехватывает маршрут /404 до контроллера
# rubocop:disable Rails/ActionControllerTestCase
class Web::ErrorsControllerTest < ActionController::TestCase
  tests Web::ErrorsController

  ACCEPT_HEADERS = ['text/javascript', 'application/json', 'text/plain', '*/*'].freeze

  # NOTE: боты запрашивают несуществующие /app.js, /config.js с Accept: text/javascript. Ответ с таким типом защита от подделки
  # запросов (verify_same_origin_request) считает «чужим скриптом» и роняла страницу ошибки в 500 вместо 404.
  setup do
    @forgery_protection = Web::ErrorsController.allow_forgery_protection
    Web::ErrorsController.allow_forgery_protection = true
  end

  teardown do
    Web::ErrorsController.allow_forgery_protection = @forgery_protection
  end

  [
    ['not_found', :not_found],
    ['forbidden', :forbidden],
    ['server_error', :internal_server_error]
  ].each do |action, status|
    ACCEPT_HEADERS.each do |accept|
      test "#{action} answers #{status} for Accept: #{accept}" do
        request.headers['Accept'] = accept
        get action

        assert_response status
      end
    end

    test "#{action} renders the page for html" do
      request.headers['Accept'] = 'text/html'
      get action

      assert_response status
      assert_includes response.media_type, 'html'
      assert_predicate response.body, :present?
    end
  end
end
# rubocop:enable Rails/ActionControllerTestCase

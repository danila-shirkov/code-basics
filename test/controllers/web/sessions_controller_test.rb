# frozen_string_literal: true

require 'test_helper'

class Web::SessionsControllerTest < ActionDispatch::IntegrationTest
  test 'new' do
    get new_session_url
    assert_response :success
  end

  test 'create' do
    user = users(:one)

    post session_url, params: { sign_in_form: { email: user.email, password: 'password' } }
    assert_response :redirect

    assert { signed_in? }
  end

  test 'create with a wrong password shows a visible notification and the form again' do
    user = users(:one)

    post session_url, params: { sign_in_form: { email: user.email, password: 'wrong-password' } }

    assert_response :success
    assert_select '.alert-danger'
    assert_select 'form[action=?]', session_path
    assert { !signed_in? }
  end

  test 'a stale session cookie of the whole domain is expired, so that the login stays' do
    key = Rails.application.config.session_options[:key]

    get new_session_url, headers: { 'Cookie' => "#{key}=stale-from-domain; #{key}=current" }

    assert_includes response.headers['Set-Cookie'], "domain=.#{request.domain}"
    assert_match(/#{key}=; .*(max-age=0|expires=Thu, 01 Jan 1970)/i, response.headers['Set-Cookie'])
  end

  test 'a single session cookie is not touched' do
    key = Rails.application.config.session_options[:key]

    get new_session_url, headers: { 'Cookie' => "#{key}=current" }

    assert_not_includes response.headers['Set-Cookie'].to_s, 'domain='
  end

  test 'destroy' do
    sign_in_as(:one)
    assert { signed_in? }

    delete session_url
    assert_response :redirect

    # assert { !signed_in? }
  end
end

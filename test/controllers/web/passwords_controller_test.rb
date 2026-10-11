# frozen_string_literal: true

require 'test_helper'

class Web::PasswordsControllerTest < ActionDispatch::IntegrationTest
  test 'edit' do
    user = users(:full)

    get edit_password_url(reset_password_token: user.reset_password_token)
    assert_response :success
  end

  test 'update' do
    user = users(:full)
    before_password_digest = user.password_digest

    patch password_url(reset_password_token: user.reset_password_token), params: { user_password_form: { password: 'new_password' } }
    assert_redirected_to new_session_url
    assert_equal 1, flash.to_h.slice('success').size

    user.reload
    assert { before_password_digest != user.password_digest }
    assert_nil user.reset_password_token
  end

  test 'update with a too short password shows a notification and the form' do
    user = users(:full)

    patch password_url(reset_password_token: user.reset_password_token), params: { user_password_form: { password: '123' } }

    assert_response :success
    assert_select '.alert-danger'
    assert_select 'form'
  end

  test 'a link with an unknown or used token leads to a new request with a notification' do
    get edit_password_url(reset_password_token: 'no-such-token')

    assert_redirected_to new_remind_password_url
    assert_not_nil flash[:error]
  end

  test 'the link is one-time: after the password is changed the same token no longer works' do
    user = users(:full)
    token = user.reset_password_token

    patch password_url(reset_password_token: token), params: { user_password_form: { password: 'new_password' } }
    get edit_password_url(reset_password_token: token)

    assert_redirected_to new_remind_password_url
  end
end

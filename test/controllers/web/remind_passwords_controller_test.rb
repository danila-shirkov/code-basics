# frozen_string_literal: true

require 'test_helper'
require 'minitest/mock'

class Web::RemindPasswordsControllerTest < ActionDispatch::IntegrationTest
  test 'new' do
    get new_remind_password_url
    assert_response :success
  end

  test 'create' do
    user = users(:full)
    before_token = user.reset_password_token

    post remind_password_url, params: { remind_password_form: { email: user.email } }
    assert_response :redirect

    user.reload
    assert { before_token != user.reset_password_token }
  end

  test 'create sends the email right away, not through a queue' do
    user = users(:full)

    assert_emails 1 do
      post remind_password_url, params: { remind_password_form: { email: user.email } }
    end

    mail = ActionMailer::Base.deliveries.last
    assert_equal [user.email], mail.to
    assert_includes mail.body.to_s, user.reload.reset_password_token
  end

  test 'create answers with a message, not a 500, when the mail server is not available' do
    user = users(:full)

    UserService.stub :reset_password!, ->(_user) { raise Net::SMTPAuthenticationError, '535 authentication failed' } do
      post remind_password_url, params: { remind_password_form: { email: user.email } }
    end

    assert_response :service_unavailable
    assert_select '.alert-danger'
    assert_select 'form'
  end
end

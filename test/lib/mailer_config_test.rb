# frozen_string_literal: true

require 'test_helper'

class MailerConfigTest < ActiveSupport::TestCase
  test 'the sender is an address of the codica.la domain, whose SPF includes the mail provider' do
    assert_equal 'no-contestar@codica.la', ApplicationMailer.default[:from]
  end

  test 'reset password email is built for the user' do
    user = users(:full)
    mail = UserMailer.reset_password(user.id)

    assert_equal [user.email], mail.to
    assert_equal ['no-contestar@codica.la'], mail.from
    assert_includes mail.body.to_s, 'reset_password_token='
  end
end

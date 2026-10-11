# frozen_string_literal: true

class UserService
  # Сбои отправки почты (SMTP отказал во входе или недоступен, таймаут): вызывающий показывает сообщение вместо 500
  MAIL_ERRORS = [Net::SMTPError, Net::OpenTimeout, Net::ReadTimeout, SocketError, SystemCallError, IOError, OpenSSL::SSL::SSLError].freeze

  # NOTE: письмо уходит сразу (deliver_now), а не через очередь: Sidekiq на сервере не запущен, и письма из очереди никто не отправлял
  def self.reset_password!(user)
    token = SecureHelper.generate_token
    user.update!(reset_password_token: token)

    UserMailer.reset_password(user.id).deliver_now
  end
end

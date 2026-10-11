# frozen_string_literal: true

class Web::RemindPasswordsController < Web::ApplicationController
  def new
    @remind_password_form = RemindPasswordForm.new
  end

  def create
    @remind_password_form = RemindPasswordForm.new(params[:remind_password_form])

    if @remind_password_form.valid?
      user = @remind_password_form.user

      begin
        UserService.reset_password!(user)
      rescue *UserService::MAIL_ERRORS => e
        Rails.logger.error("reset password mail for user #{user.id} was not sent: #{e.class}: #{e.message}")
        Sentry.capture_exception(e)

        f(:error, now: true)
        render :new, status: :service_unavailable
      else
        f(:success)
        redirect_to root_path
      end
    else
      render :new
    end
  end
end

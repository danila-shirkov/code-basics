# frozen_string_literal: true

class Web::PasswordsController < Web::ApplicationController
  before_action :assert_reset_token_passed

  def edit
    @user = find_user
    return if @user

    reject_invalid_token
  end

  def update
    @user = find_user
    return reject_invalid_token unless @user

    if @user.update(params[:user_password_form])
      # NOTE: ссылка из письма одноразовая; раньше токен оставался, и по ссылке можно было менять пароль снова и снова
      @user.update_column(:reset_password_token, nil)
      f(:success)
      redirect_to new_session_path
    else
      f(:error, now: true)
      render :edit
    end
  end

  private

  def find_user
    User::PasswordForm.find_by(reset_password_token: params[:reset_password_token])
  end

  def reject_invalid_token
    f(:invalid_token, type: :error)
    redirect_to new_remind_password_path
  end

  def assert_reset_token_passed
    return if params[:reset_password_token].present?

    redirect_to root_path
  end
end

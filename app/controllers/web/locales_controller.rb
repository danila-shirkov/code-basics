# frozen_string_literal: true

class Web::LocalesController < Web::ApplicationController
  # NOTE: колбэк prepare_locale_settings удалён из Web::ApplicationController (он не подключён), поэтому skip_before_action
  # для него здесь падает при eager load в production («callback has not been defined»)

  def switch
    locale = params[:new_locale]
    # redirect_path = requst.referer || root_path

    unless I18n.available_locales.include?(locale&.to_sym)
      redirect_back fallback_location: root_path(locale: AppHost.locale_for_url(I18n.default_locale))
      return
    end

    unless current_user.guest?
      current_user.locale = locale
      current_user.save!
    end

    session[:locale] = locale

    redirect_to root_url(locale: AppHost.locale_for_url(locale)), allow_other_host: true
  end
end

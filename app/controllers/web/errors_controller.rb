# frozen_string_literal: true

class Web::ErrorsController < Web::ApplicationController
  before_action do
    set_meta_tags title: t('.base')
  end

  # NOTE: for 404 page locale from route params is undefined
  around_action :use_locale, only: :not_found

  # NOTE: ответ не-HTML формата (боты просят /app.js, /config.js с Accept: text/javascript) отдаём как text/plain: иначе защита от
  # подделки запросов принимает пустой JS-ответ за «чужой скрипт» и страница ошибки превращается в 500
  def forbidden
    respond_to do |format|
      format.html { render status: :forbidden }
      format.all { head :forbidden, content_type: 'text/plain' }
    end
  end

  def not_found
    respond_to do |format|
      format.html { render status: :not_found }
      format.all { head :not_found, content_type: 'text/plain' }
    end
  end

  def server_error
    respond_to do |format|
      format.html { render status: :internal_server_error }
      format.all { head :internal_server_error, content_type: 'text/plain' }
    end
  end

  private

  def use_locale(&)
    locale = URI.parse(request.original_url).path.split('/').second || ''
    locale = I18n.available_locales.include?(locale.to_sym) ? locale : I18n.default_locale

    I18n.with_locale(locale, &)
  end
end

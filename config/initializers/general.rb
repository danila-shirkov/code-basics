# frozen_string_literal: true

require 'app_host'

Rails.application.routes.default_url_options[:host] = AppHost.canonical
# URL-хелперы вне запроса (JSON-LD на главной и курсах, карта сайта, письма) иначе получают http://; за nginx сайт открыт по https
Rails.application.routes.default_url_options[:protocol] = 'https' if Rails.env.production?

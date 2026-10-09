# frozen_string_literal: true

# Организация для разметки в футере (выводится на каждой странице). Раньше здесь были данные Hexlet (юрлицо, адрес в Хельсинки,
# VAT, логотип), а не Códica.
class OrganizationSchema
  SAME_AS = %w[
    https://www.facebook.com/codica.la
    https://www.instagram.com/codica.la/
    https://www.linkedin.com/company/codicala/
  ].freeze

  class << self
    include Rails.application.routes.url_helpers

    def to_builder
      Jbuilder.new do |json|
        json.set! :@type, 'Organization'
        json.name 'Códica'
        json.url 'https://codica.la'
        json.logo do
          json.set! :@type, 'ImageObject'
          json.url "https://#{AppHost.canonical}#{ActionController::Base.helpers.asset_path('logo_codica.svg')}"
        end
        json.sameAs SAME_AS
      end
    end
  end
end

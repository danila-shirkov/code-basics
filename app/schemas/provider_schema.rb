# frozen_string_literal: true

class ProviderSchema
  class << self
    include Rails.application.routes.url_helpers

    def to_builder
      Jbuilder.new do |json|
        json.set! '@type', 'Organization'
        json.name 'Códica Básicos'
        json.sameAs root_url
      end
    end
  end
end

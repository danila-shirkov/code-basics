# frozen_string_literal: true

class Web::PagesController < Web::ApplicationController
  PAGES = %w[about].freeze

  def show
    @page = params[:id]
    unless PAGES.include? @page
      raise ActionController::RoutingError, 'Page not found'
    end

    set_meta_tags title: t(@page, scope: 'web.pages')
  end
end

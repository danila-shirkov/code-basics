# frozen_string_literal: true

class Web::HomeController < Web::ApplicationController
  def index
    @catalog = HomeCatalog.new

    completed_languages = Language.with_progress(:completed).with_locale.ordered
    infos = Language::Version::Info.with_locale.where(language: completed_languages).includes(:language)
    infos_by_language = infos.index_by { |item| item.language.id }
    item_builders = completed_languages.map { |l| CourseSchema.to_builder(l, infos_by_language.fetch(l.id)) }

    @builder = ItemListSchema.to_builder(item_builders)

    seo_tags = {
      title: t('.title'),
      description: t('.meta_description'),
      canonical: root_url,
      image_src: view_context.asset_url('logo.png'),
      twitter: {
        card: 'summary' # NOTE: twitter:site с аккаунтом Hexlet убран — у Códica его нет
      },
      og: {
        title: t('.title'),
        type: 'website',
        description: t('.meta_description'),
        site_name: 'Códica Básicos',
        url: root_url,
        image: view_context.asset_url('logo.png')
      }
    }
    set_meta_tags seo_tags
  end

  def robots
    respond_to :text
  end
end

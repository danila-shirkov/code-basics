# frozen_string_literal: true

require 'test_helper'
require 'sitemap_generator'

class SitemapTest < ActiveSupport::TestCase
  setup do
    @dir = Dir.mktmpdir('sitemap-test')
    SitemapGenerator.verbose = false
    SitemapGenerator::Sitemap.public_path = @dir
    SitemapGenerator::Interpreter.run(config_file: Rails.root.join('config/sitemap.rb').to_s)
  end

  teardown do
    FileUtils.remove_entry(@dir)
  end

  def urls
    Dir.glob(File.join(@dir, 'sitemaps/es/*.xml')).flat_map { |file| File.read(file).scan(%r{<loc>([^<]+)</loc>}).flatten }
  end

  # NOTE: курсы и уроки в карте проверять нечем: у фикстур нет испанских текстов (карта берёт только курсы с текстом на своей локали)
  test 'the sitemap lists the home page, the about page and the categories with courses' do
    host = "https://#{AppHost.canonical}"

    assert_includes urls, host
    assert_includes urls, "#{host}/pages/about"
    assert_includes urls, "#{host}/language_categories/programming"
    assert_includes urls, "#{host}/language_categories/layouting"
  end

  test 'the sitemap does not list removed or private pages' do
    assert(urls.none? { |url| url.match?(%r{/(blog_posts|reviews|session|users|remind_password|password|pages/(privacy|tos|authors|cookie_policy))}) })
    assert_not_includes urls, "https://#{AppHost.canonical}/language_categories"
  end
end

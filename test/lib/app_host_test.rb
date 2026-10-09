# frozen_string_literal: true

require 'test_helper'
require 'minitest/mock'

class AppHostTest < ActiveSupport::TestCase
  def with_env(vars)
    old = vars.keys.index_with { |k| ENV.fetch(k, nil) }
    vars.each { |k, v| ENV[k] = v }
    yield
  ensure
    old.each { |k, v| ENV[k] = v }
  end

  test 'single_locale? is on by default and can be switched off' do
    with_env('SINGLE_LOCALE' => nil) { assert_predicate AppHost, :single_locale? }
    with_env('SINGLE_LOCALE' => 'false') { assert_not AppHost.single_locale? }
  end

  test 'served_locales is the default locale in single locale mode' do
    with_env('SINGLE_LOCALE' => 'true') { assert_equal [I18n.default_locale], AppHost.served_locales }
    with_env('SINGLE_LOCALE' => 'false') { assert_equal I18n.available_locales, AppHost.served_locales }
  end

  test 'sitemap is stored in a bucket only when explicitly requested in production' do
    Rails.stub :env, ActiveSupport::StringInquirer.new('production') do
      with_env('SITEMAP_STORAGE' => nil, 'DO_SPACES_SITEMAP_BUCKET' => 'some-bucket') { assert_not AppHost.sitemap_in_bucket? }
      with_env('SITEMAP_STORAGE' => 'bucket', 'DO_SPACES_SITEMAP_BUCKET' => 'some-bucket') { assert_predicate AppHost, :sitemap_in_bucket? }
      with_env('SITEMAP_STORAGE' => 'bucket', 'DO_SPACES_SITEMAP_BUCKET' => nil) { assert_not AppHost.sitemap_in_bucket? }
    end
  end

  test 'exercise images are tagged lv<id> only when versioned images are enabled' do
    version = Language::Version.new(id: 42)

    with_env('EXERCISE_IMAGES_VERSIONED' => nil) { assert_equal :latest, version.image_tag }
    with_env('EXERCISE_IMAGES_VERSIONED' => 'true') { assert_equal 'lv42', version.image_tag }
  end
end

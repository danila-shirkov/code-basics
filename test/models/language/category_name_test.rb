# frozen_string_literal: true

require 'test_helper'

class Language::CategoryNameTest < ActiveSupport::TestCase
  setup do
    @category = Language::Category.new(slug: 'programming', name_en: 'Programming', name_ru: 'Программирование')
  end

  test 'name uses the Spanish translation for es' do
    I18n.with_locale(:es) { assert_equal 'Programación', @category.name }
  end

  test 'name keeps the columns for en and ru' do
    I18n.with_locale(:en) { assert_equal 'Programming', @category.name }
    I18n.with_locale(:ru) { assert_equal 'Программирование', @category.name }
  end

  test 'name falls back to name_en for a category without a translation' do
    category = Language::Category.new(slug: 'unknown', name_en: 'Unknown')

    I18n.with_locale(:es) { assert_equal 'Unknown', category.name }
  end
end

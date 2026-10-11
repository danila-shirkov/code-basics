# frozen_string_literal: true

require 'test_helper'

class LanguageCategoriesControllerTest < ActionDispatch::IntegrationTest
  test 'the list of categories is removed: it was a developer placeholder' do
    assert_raises(ActionController::RoutingError) { get '/language_categories' }
  end

  test 'should get show' do
    category = language_categories(:programming)
    get language_category_url(id: category.slug)
    assert_response :success
  end
end

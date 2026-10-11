# frozen_string_literal: true

require 'test_helper'

class Web::BlogPostsControllerTest < ActionDispatch::IntegrationTest
  test 'the list of posts is removed: there are no posts to show' do
    assert_raises(ActionController::RoutingError) { get '/blog_posts' }
  end

  test 'should get show' do
    post = blog_posts('from-full')
    get blog_post_url(post.slug)
    assert_response :success
  end
end

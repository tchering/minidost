# frozen_string_literal: true

require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test 'should get home' do
    get static_pages_home_url
    assert_response :success
  end

  test 'should get contact' do
    get static_pages_contact_url
    assert_response :success
  end

  test 'should get blog' do
    get static_pages_blog_url
    assert_response :success
  end

  test 'should get help' do
    get static_pages_help_url
    assert_response :success
  end
end

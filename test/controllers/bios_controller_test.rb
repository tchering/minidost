# frozen_string_literal: true

require 'test_helper'

class BiosControllerTest < ActionDispatch::IntegrationTest
  test 'should get show' do
    get bios_show_url
    assert_response :success
  end

  test 'should get new' do
    get bios_new_url
    assert_response :success
  end

  test 'should get create' do
    get bios_create_url
    assert_response :success
  end

  test 'should get edit' do
    get bios_edit_url
    assert_response :success
  end

  test 'should get update' do
    get bios_update_url
    assert_response :success
  end
end

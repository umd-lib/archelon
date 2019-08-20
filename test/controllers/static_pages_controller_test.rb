# frozen_string_literal: true

require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  setup do
    @cas_user = cas_users(:one)
    mock_cas_login(@cas_user.cas_directory_id)
  end

  test 'should get about' do
    get :about
    assert_response :success
  end
end

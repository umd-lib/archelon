# frozen_string_literal: true

require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  setup do
    @cas_user = cas_users(:one)
    mock_cas_login(@cas_user.cas_directory_id)
  end

  test 'should get about' do
    stub_request(:get, 'http://localhost:8983/solr/fedora4')
      .to_return(status: 200, body: '', headers: {})
    get :about
    assert_response :success
  end
end

# frozen_string_literal: true

require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  setup do
    @cas_user = cas_users(:one)
    mock_cas_login(@cas_user.cas_directory_id)
  end

  test 'should get about' do
    mock_env('SOLR_URL' => 'http://localhost:8983/solr/fedora4') do
      stub_request(:get, ENV['SOLR_URL']).to_return(status: 200, body: '', headers: {})
      get :about
      assert_response :success
    end
  end
end

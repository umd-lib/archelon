# frozen_string_literal: true

require 'test_helper'

# Integration test for CasAuthentication service
class CasAuthenticationTest < ActionDispatch::IntegrationTest
  def setup
  end

  # Stubs an empty Solr response, for use when actually retrieving a
  # web page in the test.
  def stub_solr_response
    # UMD Blacklight 8 Fix
    solr_response = double(Blacklight::Solr::Response)
    expect(solr_response).to receive(:aggregations).at_least(:once).and_return({})
    expect_any_instance_of(Blacklight::SearchService).to receive(:search_results).and_return(solr_response)
    # End UMD Blacklight 8 Fix
  end

  test 'valid logins should have session and cookie values set' do
    stub_solr_response
    # Using mock_cas_login_for_integration_tests, because this is an
    # existing test fixtures user
    mock_cas_login_for_integration_tests('test_user')

    get root_path

    assert_response :success
    assert_equal 'test_user', session[:cas_user]
    # cookies[:cas_user] is encypted, so we'll just assume if it is
    # set, then it has the correct value
    assert cookies[:cas_user].present?
  end

  test 'session and cookie values should be destroyed on logout' do
    # Using mock_cas_login_for_integration_tests, because this is an
    # existing test fixtures user
    mock_cas_login_for_integration_tests('test_user')

    get logout_path

    assert_redirected_to 'https://login.umd.edu/cas/logout'
    assert session[:cas_user].nil?
    assert_equal '', cookies[:cas_user]
  end
end

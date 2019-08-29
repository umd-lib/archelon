# frozen_string_literal: true

require 'test_helper'
# Integration test for CAS authorization functionality
class CasAuthorizationTest < ActionDispatch::IntegrationTest
  def setup
  end

  # Stubs an empty Solr response, for use when actually retrieving a
  # web page in the test.
  def stub_solr_response
    solr_response = double(Blacklight::Solr::Response)
    expect(solr_response).to receive(:aggregations).at_least(:once).and_return({})
    expect_any_instance_of(CatalogController).to receive(:search_results).and_return([solr_response, []])
  end

  # LDAP call will return the given CAS user ldap_attrs map
  def stub_ldap_response(ldap_attrs)
    expect(CasUser).to receive(:ldap_attributes).and_return(ldap_attrs)
  end

  test 'existing cas_user can access application' do
    stub_solr_response
    # Using mock_cas_login_for_integration_tests, because this is an
    # existing test fixtures user
    mock_cas_login_for_integration_tests('test_user')

    get root_path
    assert_response :success
    assert_template 'catalog/index'
  end

  test 'new cas_user with User Grouper group can access application' do
    stub_solr_response
    stub_ldap_response(name: 'New CAS User', groups: [GROUPER_USER_GROUP])

    cas_login('new_cas_user1')

    get root_path
    assert_response :success
    assert_template 'catalog/index'
  end

  test 'new cas_user can with User Grouper group has assigned "user" type' do
    stub_ldap_response(name: 'New CAS User', groups: [GROUPER_USER_GROUP])

    cas_login('new_cas_user2')

    assert CasUser.find_by(cas_directory_id: 'new_cas_user2').user?
  end

  test 'new cas_user can with Admin Grouper group can access application' do
    stub_solr_response
    stub_ldap_response(name: 'New Admin CAS User', groups: [GROUPER_ADMIN_GROUP])

    cas_login('new_admin_cas_user1')

    get root_path
    assert_response :success
    assert_template 'catalog/index'
  end

  test 'new cas_user can with Admin Grouper group has "admin" type' do
    stub_ldap_response(name: 'New Admin CAS User', groups: [GROUPER_ADMIN_GROUP])

    cas_login('new_admin_cas_user2')

    assert CasUser.find_by(cas_directory_id: 'new_admin_cas_user2').admin?
  end

  test 'new cas_user without Grouper groups cannot access application' do
    stub_ldap_response(name: 'Unauthorized User', groups: ['SOME_OTHER_GROUP'])

    cas_login('new_unauth_user1')

    get root_path
    assert_response(:forbidden)
  end

  test 'new cas_user without Grouper groups has "unauthorized" type' do
    stub_ldap_response(name: 'Unauthorized User', groups: ['SOME_OTHER_GROUP'])

    cas_login('new_unauth_user2')

    assert CasUser.find_by(cas_directory_id: 'new_unauth_user2').unauthorized?
  end

  test 'existing admin cas_user type is updated based on Grouper group changes during login' do
    assert CasUser.find_by(cas_directory_id: 'prior_admin').admin?

    stub_ldap_response(name: 'Prior Admin', groups: [GROUPER_USER_GROUP])

    cas_login('prior_admin')

    assert CasUser.find_by(cas_directory_id: 'prior_admin').user?
  end

  test 'existing cas_user type is updated based on Grouper group changes during login' do
    assert CasUser.find_by(cas_directory_id: 'prior_user1').user?

    stub_ldap_response(name: 'Prior User1', groups: [GROUPER_ADMIN_GROUP])

    cas_login('prior_user1')

    assert CasUser.find_by(cas_directory_id: 'prior_user1').admin?
  end

  test 'existing authorized cas_user should be unauthorized if no longer belong to Archelon Grouper groups' do
    assert CasUser.find_by(cas_directory_id: 'prior_user2').user?

    stub_ldap_response(name: 'Prior User2', groups: ['SOME_OTHER_GROUP'])

    cas_login('prior_user2')

    assert CasUser.find_by(cas_directory_id: 'prior_user2').unauthorized?
  end

  test 'non-existent cas_user cannot access application' do
    # In this test, the non-existent CAS user is created by the "cas_login"
    # call, which will check for LDAP attritbutes, so stub LDAP call.
    stub_ldap_response(name: 'No Such User', groups: [])

    cas_login('no_such_user')

    get root_path
    assert_response(:forbidden)
  end

  def teardown
  end
end

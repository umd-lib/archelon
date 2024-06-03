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
  def stub_ldap_response(name:, groups:)
    expect(LdapUserAttributes).to receive(:create).and_return(LdapUserAttributes.send(:new, name, groups))
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
    stub_ldap_response(name: 'New CAS User', groups: [GROUPER_GROUPS['Users']])

    cas_login('new_cas_user1')

    get root_path
    assert_response :success
    assert_template 'catalog/index'
  end

  test 'new cas_user can with User Grouper group has assigned "user" type' do
    stub_ldap_response(name: 'New CAS User', groups: [GROUPER_GROUPS['Users']])

    cas_login('new_cas_user2')

    assert CasUser.find_by(cas_directory_id: 'new_cas_user2').user?
  end

  test 'new cas_user can with Admin Grouper group can access application' do
    stub_solr_response
    stub_ldap_response(name: 'New Admin CAS User', groups: [GROUPER_GROUPS['Administrators']])

    cas_login('new_admin_cas_user1')

    get root_path
    assert_response :success
    assert_template 'catalog/index'
  end

  test 'new cas_user can with Admin Grouper group has "admin" type' do
    stub_ldap_response(name: 'New Admin CAS User', groups: [GROUPER_GROUPS['Administrators']])

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

    stub_ldap_response(name: 'Prior Admin', groups: [GROUPER_GROUPS['Users']])

    cas_login('prior_admin')

    assert CasUser.find_by(cas_directory_id: 'prior_admin').user?
  end

  test 'existing cas_user type is updated based on Grouper group changes during login' do
    assert CasUser.find_by(cas_directory_id: 'prior_user1').user?

    stub_ldap_response(name: 'Prior User1', groups: [GROUPER_GROUPS['Administrators']])

    cas_login('prior_user1')

    assert CasUser.find_by(cas_directory_id: 'prior_user1').admin?
  end

  test 'existing authorized cas_user should be unauthorized if no longer belong to Archelon Grouper groups' do
    assert CasUser.find_by(cas_directory_id: 'prior_user2').user?

    stub_ldap_response(name: 'Prior User2', groups: ['SOME_OTHER_GROUP'])

    cas_login('prior_user2')

    assert CasUser.find_by(cas_directory_id: 'prior_user2').unauthorized?
  end

  test 'existing unauthorized user should update to user on login' do
    user = CasUser.find_by cas_directory_id: 'prior_unauthorized'
    assert user.unauthorized?
    assert_not user.user?
    assert_not user.admin?

    # do the critical steps of a login
    stub_ldap_response(name: 'Prior Unauthorized', groups: [GROUPER_GROUPS['Users']])
    user = CasUser.find_or_create_from_auth_hash(uid: user.cas_directory_id)

    # they should be a user now
    assert_not user.unauthorized?
    assert user.user?
    assert_not user.admin?
  end

  test 'existing unauthorized user should update to admin on login' do
    user = CasUser.find_by cas_directory_id: 'prior_unauthorized2'
    assert user.unauthorized?
    assert_not user.user?
    assert_not user.admin?

    # do the critical steps of a login
    stub_ldap_response(name: 'Prior Unauthorized 2', groups: [GROUPER_GROUPS['Administrators']])
    user = CasUser.find_or_create_from_auth_hash(uid: user.cas_directory_id)

    # they should be an admin now
    assert_not user.unauthorized?
    assert_not user.user?
    assert user.admin?
  end

  test 'non-existent cas_user cannot access application' do
    # In this test, the non-existent CAS user is created by the "cas_login"
    # call, which will check for LDAP attritbutes, so stub LDAP call.
    stub_ldap_response(name: 'No Such User', groups: [])

    cas_login('no_such_user')

    get root_path
    assert_response(:forbidden)
  end

  test 'ldap group name checks should ignore case' do
    stub_ldap_response(name: 'New User', groups: [GROUPER_GROUPS['Administrators'].downcase])
    user = CasUser.find_or_create_from_auth_hash(uid: 'newuser')

    assert user.in_group? :Administrators
  end

  def teardown
  end
end

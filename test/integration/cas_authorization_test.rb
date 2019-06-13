require 'test_helper'
# Integration test for CAS authorization functionality
class CasAuthorizationTest < ActionDispatch::IntegrationTest
  test 'existing cas_user can access application' do
    cas_login('test_user')

    get root_path
    assert_response :success
    assert_template 'catalog/index'
  end

  test 'new cas_user with User Grouper group can access application' do
    ldap_attrs = {
      name: "New CAS User",
      groups: [GROUPER_USER_GROUP]
    }
    CasUser.stub :ldap_attributes, ldap_attrs do
      cas_login('new_cas_user1')
    end
    get root_path
    assert_response :success
    assert_template 'catalog/index'
  end

  test 'new cas_user can with User Grouper group has assigned "user" type' do
    ldap_attrs = {
      name: "New CAS User",
      groups: [GROUPER_USER_GROUP]
    }
    CasUser.stub :ldap_attributes, ldap_attrs do
      cas_login('new_cas_user2')
    end
    assert CasUser.find_by(cas_directory_id: 'new_cas_user2').user?
  end

  test 'new cas_user can with Admin Grouper group can access application' do
    ldap_attrs = {
      name: "New Admin CAS User",
      groups: [GROUPER_ADMIN_GROUP]
    }
    CasUser.stub :ldap_attributes, ldap_attrs do
      cas_login('new_admin_cas_user1')
    end
    
    get root_path
    assert_response :success
    assert_template 'catalog/index'
  end

  test 'new cas_user can with Admin Grouper group has "admin" type' do
    ldap_attrs = {
      name: "New Admin CAS User",
      groups: [GROUPER_ADMIN_GROUP]
    }
    CasUser.stub :ldap_attributes, ldap_attrs do
      cas_login('new_admin_cas_user2')
    end
    assert CasUser.find_by(cas_directory_id: 'new_admin_cas_user2').admin?
  end

  test 'new cas_user without Grouper groups cannot access application' do
    ldap_attrs = {
      name: "Unauthorized User",
      groups: ["SOME_OTHER_GROUP"]
    }
    CasUser.stub :ldap_attributes, ldap_attrs do
      cas_login('new_unauth_user1')
    end

    get root_path
    assert_response(:forbidden)
  end

  test 'new cas_user without Grouper groups has "unauthorized" type' do
    ldap_attrs = {
      name: "Unauthorized User",
      groups: ["SOME_OTHER_GROUP"]
    }
    CasUser.stub :ldap_attributes, ldap_attrs do
      cas_login('new_unauth_user2')
    end
  
    assert CasUser.find_by(cas_directory_id: 'new_unauth_user2').unauthorized?
  end

  test 'non-existent cas_user cannot access application' do
    cas_login('no_such_user')

    get root_path
    assert_response(:forbidden)
  end

  def teardown
    # Restore normal "test_user"
    cas_login(DEFAULT_TEST_USER)
  end
end

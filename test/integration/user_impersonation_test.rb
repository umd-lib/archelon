require 'test_helper'
# Integration test for CAS authorization functionality
class UserImpersonationTest < ActionDispatch::IntegrationTest


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

  test 'existing admin cas_user type is updated based on Grouper group changes during login' do
    ldap_attrs = {
      name: "Prior Admin",
      groups: [GROUPER_USER_GROUP]
    }
    assert CasUser.find_by(cas_directory_id: 'prior_admin').admin?
    CasUser.stub :ldap_attributes, ldap_attrs do
      cas_login('prior_admin')
    end
    assert CasUser.find_by(cas_directory_id: 'prior_admin').user?
  end

  test 'existing cas_user type is updated based on Grouper group changes during login' do
    ldap_attrs = {
      name: "Prior User1",
      groups: [GROUPER_ADMIN_GROUP]
    }
    assert CasUser.find_by(cas_directory_id: 'prior_user1').user?
    CasUser.stub :ldap_attributes, ldap_attrs do
      cas_login('prior_user1')
    end
    assert CasUser.find_by(cas_directory_id: 'prior_user1').admin?
  end

  test 'existing authorized cas_user should be unauthorized if no longer belong to Archelon Grouper groups' do
    ldap_attrs = {
      name: "Prior User2",
      groups: ["SOME_OTHER_GROUP"]
    }
    assert CasUser.find_by(cas_directory_id: 'prior_user2').user?
    CasUser.stub :ldap_attributes, ldap_attrs do
      cas_login('prior_user2')
    end
    assert CasUser.find_by(cas_directory_id: 'prior_user2').unauthorized?
  end

  test 'non-existent cas_user cannot access application' do
    cas_login('no_such_user')

    get root_path
    assert_response(:forbidden)
  end

  test 'admin user can impersonate non-admin user' do
    admin_user = cas_users(:test_admin)
    cas_login(admin_user.cas_directory_id)
    non_admin_user = cas_users(:test_user)

    get admin_user_login_as_path(user_id: non_admin_user.id)
    assert session[:cas_user], non_admin_user.cas_directory_id
  end

  test 'admin user cannot impersonate admin user' do
    admin_user = cas_users(:test_admin)
    cas_login(admin_user.cas_directory_id)
    admin_user2 = cas_users(:test_admin2)

    get admin_user_login_as_path(user_id: admin_user2.id)
    assert session[:cas_user], admin_user.cas_directory_id
  end

  test 'regular user cannot impersonate' do
    non_admin_user = cas_users(:test_user)
    cas_login(non_admin_user.cas_directory_id)
    admin_user = cas_users(:test_admin)

    get admin_user_login_as_path(user_id: admin_user.id)
    assert session[:cas_user], non_admin_user.cas_directory_id
  end

  def teardown
    # Restore normal "test_user"
    cas_login(DEFAULT_TEST_USER)
  end
end

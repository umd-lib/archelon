require 'test_helper'
# Integration test for CAS authorization functionality
class UserImpersonationTest < ActionDispatch::IntegrationTest

  test 'admin user can impersonate non-admin user' do
    admin_user = cas_users(:test_admin)
    cas_login(admin_user.cas_directory_id)
    non_admin_user = cas_users(:test_user)

    get admin_user_login_as_path(user_id: non_admin_user.id)
    assert session[:cas_user], non_admin_user.cas_directory_id
  end

  test 'admin user should remain on current page when impersonation is stopped' do
    admin_user = cas_users(:test_admin)
    cas_login(admin_user.cas_directory_id)
    non_admin_user = cas_users(:test_user)

    get admin_user_login_as_path(user_id: non_admin_user.id)
    assert session[:cas_user], non_admin_user.cas_directory_id
    
    referring_page = '/some/page'
    get admin_user_login_as_path(user_id: admin_user.id), nil, { HTTP_REFERER: referring_page}
    assert_redirected_to referring_page
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

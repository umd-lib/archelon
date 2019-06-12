require 'test_helper'
# Integration test for CAS authorization functionality
class CasAuthorizationTest < ActionDispatch::IntegrationTest
  test 'existing cas_user can access application' do
    cas_login('test_user')

    get root_path
    assert_response :success
    assert_template 'catalog/index'
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

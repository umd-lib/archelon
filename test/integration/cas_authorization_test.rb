require 'test_helper'
# Integration test for CAS authorization functionality
class CasAuthorizationTest < ActionDispatch::IntegrationTest
  test 'existing cas_user can access application' do
    CASClient::Frameworks::Rails::Filter.fake('test_user')

    get root_path
    assert_template 'catalog/index'
  end

  test 'non-existent cas_user cannot access application' do
    CASClient::Frameworks::Rails::Filter.fake('no_such_user')

    get root_path
    assert_response(:forbidden)
  end

  def teardown
    # Restore normal "test_user"
    CASClient::Frameworks::Rails::Filter.fake('test_user')
  end
end

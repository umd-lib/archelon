require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  setup do
    @cas_user = cas_users(:one)
    mock_cas_login(@cas_user.cas_directory_id)
  end

  test 'should redirect to cas logout url on session destory' do
    get :destroy
    cas_logout_url = Rails.application.config.cas_url + "/logout"
    assert_redirected_to(cas_logout_url)
  end
end

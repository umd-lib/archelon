# frozen_string_literal: true

require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  setup do
    @cas_user = cas_users(:one)
    mock_cas_login(@cas_user.cas_directory_id)
  end

  test 'should redirect to cas logout url on session destroy' do
    assert_equal @cas_user.cas_directory_id, session[:cas_user]
    assert_equal @cas_user.cas_directory_id, cookies.signed[:cas_user]

    get :destroy
    cas_logout_url = "#{CAS_URL}/logout"
    assert_redirected_to(cas_logout_url)

    # User-identifying session and cookie should be destroyed as well
    assert session[:cas_user].nil?
    assert cookies.signed[:cas_user].nil?
  end
end

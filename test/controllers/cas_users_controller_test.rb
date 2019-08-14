require 'test_helper'

class CasUsersControllerTest < ActionController::TestCase
  setup do
    @cas_user = cas_users(:test_admin)
    mock_cas_login(@cas_user.cas_directory_id)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:cas_users)
  end

  test 'should show cas_user' do
    get :show, params: { id: @cas_user }
    assert_response :success
  end

  test 'should destroy cas_user' do
    assert_difference('CasUser.count', -1) do
      delete :destroy, params: { id: @cas_user }
    end

    assert_redirected_to cas_users_path
  end

  test 'non-admin users should not have access to index, new, create, edit, update,destroy' do
    run_as_user(cas_users(:one)) do
      get :index
      assert_response :forbidden

      delete :destroy, params: { id: @cas_user }
      assert_response :forbidden
    end
  end

  test 'non-admin users should not have access to show, except for own record' do
    run_as_user(cas_users(:one)) do
      get :show, params: { id: cas_users(:one) }
      assert_response :success

      get :show, params: { id: cas_users(:two) }
      assert_response :forbidden
    end
  end
end

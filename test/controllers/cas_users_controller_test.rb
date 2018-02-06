require 'test_helper'

class CasUsersControllerTest < ActionController::TestCase
  setup do
    @cas_user = cas_users(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:cas_users)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create cas_user' do
    assert_difference('CasUser.count') do
      post :create, cas_user: { cas_directory_id: 'newuser', name: 'New User' }
    end

    assert_redirected_to cas_user_path(assigns(:cas_user))
  end

  test 'should show cas_user' do
    get :show, id: @cas_user
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @cas_user
    assert_response :success
  end

  test 'should update cas_user' do
    patch :update, id: @cas_user, cas_user: { cas_directory_id: @cas_user.cas_directory_id, name: @cas_user.name }
    assert_redirected_to cas_user_path(assigns(:cas_user))
  end

  test 'should destroy cas_user' do
    assert_difference('CasUser.count', -1) do
      delete :destroy, id: @cas_user
    end

    assert_redirected_to cas_users_path
  end

  test 'non-admin users should not have access to index, new, create, edit, update,destroy' do
    run_as_user(cas_users(:one)) do
      get :index
      assert_response :forbidden

      get :new
      assert_response :forbidden

      post :create, cas_user: { cas_directory_id: 'newuser', name: 'New User' }
      assert_response :forbidden

      get :edit, id: @cas_user
      assert_response :forbidden

      patch :update, id: @cas_user, cas_user: { cas_directory_id: @cas_user.cas_directory_id, name: @cas_user.name }
      assert_response :forbidden

      delete :destroy, id: @cas_user
      assert_response :forbidden
    end
  end

  test 'non-admin users should not have access to show, except for own record' do
    run_as_user(cas_users(:one)) do
      get :show, id: @cas_user
      assert_response :success

      get :show, id: cas_users(:two)
      assert_response :forbidden
    end
  end
end

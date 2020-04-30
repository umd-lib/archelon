# frozen_string_literal: true

require 'test_helper'

class DatatypesControllerTest < ActionController::TestCase
  setup do
    @cas_user = cas_users(:test_admin)
    mock_cas_login(@cas_user.cas_directory_id)

    @datatype = datatypes(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create datatype' do
    vocabulary = vocabularies(:vocab_one)

    assert_difference('Datatype.count') do
      post :create, params: { datatype: { identifier: 'datatype_abc123', vocabulary_id: vocabulary.id } }
    end

    assert_redirected_to datatype_url(Datatype.last)
  end

  test 'should show datatype' do
    get :show, params: { id: @datatype.id }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @datatype.id }
    assert_response :success
  end

  test 'should update datatype' do
    patch :update, params: { id: @datatype.id, datatype: { identifier: 'updated identifier' } }
    assert_response :success
  end

  test 'should destroy datatype' do
    assert_difference('Datatype.count', -1) do
      delete :destroy, params: { id: @datatype.id }
    end

    assert_redirected_to datatypes_url
  end

  test 'only "index" and "show" actions should be available to non-vocabulary editors/non-admins' do
    cas_user = cas_users(:test_user)

    assert_not cas_user.in_group? :VocabularyEditors
    mock_cas_login(cas_user.cas_directory_id)

    get :index
    assert_response :success

    get :show, params: { id: @datatype.id }
    assert_response :success

    get :edit, params: { id: @datatype.id }
    assert_response :forbidden

    post :create, params: { datatype: { identifier: 'ABC123', vocabular: @datatype.vocabulary } }
    assert_response :forbidden

    patch :update, params: { id: @datatype.id, datatype: { identifier: 'ABC123_123', vocabulary: @datatype.vocabulary } }
    assert_response :forbidden

    delete :destroy, params: { id: @datatype.id }
    assert_response :forbidden
  end

  test 'all actions should be available to vocabulary editors' do
    cas_user = cas_users(:vocab_editor)

    assert cas_user.in_group? :VocabularyEditors
    mock_cas_login(cas_user.cas_directory_id)

    get :index
    assert_response :success

    get :show, params: { id: @datatype.id }
    assert_response :success

    get :edit, params: { id: @datatype.id }
    assert_response :success

    post :create, params: { datatype: { identifier: 'ABC123', vocabulary: @datatype.vocabulary } }
    assert_response :success

    patch :update, params: { id: @datatype.id, datatype: { identifier: 'ABC123_123', vocabulary: @datatype.vocabulary } }
    assert_response :success

    delete :destroy, params: { id: @datatype.id }
    assert_redirected_to datatypes_url
  end

  test 'all actions should be available to admins' do
    cas_user = cas_users(:test_admin)

    assert_not cas_user.in_group? :VocabularyEditors
    assert cas_user.admin?
    mock_cas_login(cas_user.cas_directory_id)

    get :index
    assert_response :success

    get :show, params: { id: @datatype.id }
    assert_response :success

    get :edit, params: { id: @datatype.id }
    assert_response :success

    post :create, params: { datatype: { identifier: 'ABC123', vocabulary: @datatype.vocabulary } }
    assert_response :success

    patch :update, params: { id: @datatype.id, datatype: { identifier: 'ABC123_123', vocabulary: @datatype.vocabulary } }
    assert_response :success

    delete :destroy, params: { id: @datatype.id }
    assert_redirected_to datatypes_url
  end
end

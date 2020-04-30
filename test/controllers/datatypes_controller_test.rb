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
    patch :update, params: { id: @datatype.id, datatype: { indentifier: 'updated identifier' } }
    assert_redirected_to datatype_url(@datatype)
  end

  test 'should destroy datatype' do
    assert_difference('Datatype.count', -1) do
      delete :destroy, params: { id: @datatype.id }
    end

    assert_redirected_to datatypes_url
  end
end

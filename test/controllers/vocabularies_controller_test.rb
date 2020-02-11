# frozen_string_literal: true

require 'test_helper'

class VocabulariesControllerTest < ActionController::TestCase
  setup do
    @vocabulary = vocabularies(:vocab_one)
    @cas_user = cas_users(:one)
    mock_cas_login(@cas_user.cas_directory_id)
  end

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create vocabulary' do
    assert_difference('Vocabulary.count') do
      post :create, params: { vocabulary: { identifier: 'abc' } }
    end

    assert_redirected_to Vocabulary.last
  end

  test 'should show vocabulary' do
    get :show, params: { id: @vocabulary.id }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @vocabulary.id }
    assert_response :success
  end

  test 'should update vocabulary' do
    patch :update, params: { id: @vocabulary.id, vocabulary: { name: 'abcabc', description: 'New description' } }
    assert_redirected_to @vocabulary
  end

  test 'should destroy vocabulary' do
    assert_difference('Vocabulary.count', -1) do
      delete :destroy, params: { id: @vocabulary.id }
    end

    assert_redirected_to controller: :vocabularies, action: :index
  end
end

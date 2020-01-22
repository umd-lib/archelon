# frozen_string_literal: true

require 'test_helper'

class VocabulariesControllerTest < ActionController::TestCase
  setup do
    @vocabulary = vocabularies(:one)
    @cas_user = cas_users(:one)
    mock_cas_login(@cas_user.cas_directory_id)
  end

  test 'should get index' do
    get vocabularies_url
    assert_response :success
  end

  test 'should get new' do
    get new_vocabulary_url
    assert_response :success
  end

  test 'should create vocabulary' do
    assert_difference('Vocabulary.count') do
      post vocabularies_url, params: { vocabulary: {} }
    end

    assert_redirected_to vocabulary_url(Vocabulary.last)
  end

  test 'should show vocabulary' do
    get vocabulary_url(@vocabulary)
    assert_response :success
  end

  test 'should get edit' do
    get edit_vocabulary_url(@vocabulary)
    assert_response :success
  end

  test 'should update vocabulary' do
    patch vocabulary_url(@vocabulary), params: { vocabulary: {} }
    assert_redirected_to vocabulary_url(@vocabulary)
  end

  test 'should destroy vocabulary' do
    assert_difference('Vocabulary.count', -1) do
      delete vocabulary_url(@vocabulary)
    end

    assert_redirected_to vocabularies_url
  end
end

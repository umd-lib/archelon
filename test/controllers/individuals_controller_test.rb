# frozen_string_literal: true

require 'test_helper'

class IndividualsControllerTest < ActionController::TestCase
  setup do
    @individual = individuals(:one)
    @cas_user = cas_users(:vocab_editor)
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

  test 'should create individual' do
    assert_difference('Individual.count') do
      post :create, params: { individual: { identifier: 'bar', label: 'Bar', vocabulary_id: vocabularies(:vocab_one) } }
    end

    # redirects back to the parent vocab
    assert_redirected_to vocabularies(:vocab_one)
  end

  test 'should show individual' do
    get :show, params: { id: @individual.id }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @individual.id }
    assert_response :success
  end

  test 'should update individual' do
    patch :update, params: { id: @individual.id, individual: { label: 'FOOOOO' } }
    assert_redirected_to @individual
  end

  test 'should destroy individual' do
    assert_difference('Individual.count', -1) do
      delete :destroy, params: { id: @individual.id }
    end

    assert_redirected_to controller: :individuals, action: :index
  end
end

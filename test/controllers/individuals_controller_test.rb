# frozen_string_literal: true

require 'test_helper'

class IndividualsControllerTest < ActionController::TestCase
  setup do
    @individual = individuals(:one)
    @cas_user = cas_users(:one)
    mock_cas_login(@cas_user.cas_directory_id)
  end

  test 'should get index' do
    get individuals_url
    assert_response :success
  end

  test 'should get new' do
    get new_individual_url
    assert_response :success
  end

  test 'should create individual' do
    assert_difference('Individual.count') do
      post individuals_url, params: { individual: {} }
    end

    assert_redirected_to individual_url(Individual.last)
  end

  test 'should show individual' do
    get individual_url(@individual)
    assert_response :success
  end

  test 'should get edit' do
    get edit_individual_url(@individual)
    assert_response :success
  end

  test 'should update individual' do
    patch individual_url(@individual), params: { individual: {} }
    assert_redirected_to individual_url(@individual)
  end

  test 'should destroy individual' do
    assert_difference('Individual.count', -1) do
      delete individual_url(@individual)
    end

    assert_redirected_to individuals_url
  end
end

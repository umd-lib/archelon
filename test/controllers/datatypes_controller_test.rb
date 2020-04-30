require 'test_helper'

class DatatypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @datatype = datatypes(:one)
  end

  test "should get index" do
    get datatypes_url
    assert_response :success
  end

  test "should get new" do
    get new_datatype_url
    assert_response :success
  end

  test "should create datatype" do
    assert_difference('Datatype.count') do
      post datatypes_url, params: { datatype: { identifier: @datatype.identifier, vocabulary_id: @datatype.vocabulary_id } }
    end

    assert_redirected_to datatype_url(Datatype.last)
  end

  test "should show datatype" do
    get datatype_url(@datatype)
    assert_response :success
  end

  test "should get edit" do
    get edit_datatype_url(@datatype)
    assert_response :success
  end

  test "should update datatype" do
    patch datatype_url(@datatype), params: { datatype: { identifier: @datatype.identifier, vocabulary_id: @datatype.vocabulary_id } }
    assert_redirected_to datatype_url(@datatype)
  end

  test "should destroy datatype" do
    assert_difference('Datatype.count', -1) do
      delete datatype_url(@datatype)
    end

    assert_redirected_to datatypes_url
  end
end

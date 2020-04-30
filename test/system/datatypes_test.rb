require "application_system_test_case"

class DatatypesTest < ApplicationSystemTestCase
  setup do
    @datatype = datatypes(:one)
  end

  test "visiting the index" do
    visit datatypes_url
    assert_selector "h1", text: "Datatypes"
  end

  test "creating a Datatype" do
    visit datatypes_url
    click_on "New Datatype"

    fill_in "Identifier", with: @datatype.identifier
    fill_in "Vocabulary", with: @datatype.vocabulary_id
    click_on "Create Datatype"

    assert_text "Datatype was successfully created"
    click_on "Back"
  end

  test "updating a Datatype" do
    visit datatypes_url
    click_on "Edit", match: :first

    fill_in "Identifier", with: @datatype.identifier
    fill_in "Vocabulary", with: @datatype.vocabulary_id
    click_on "Update Datatype"

    assert_text "Datatype was successfully updated"
    click_on "Back"
  end

  test "destroying a Datatype" do
    visit datatypes_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Datatype was successfully destroyed"
  end
end

# frozen_string_literal: true

require 'application_system_test_case'

class IndividualsTest < ApplicationSystemTestCase
  setup do
    @individual = individuals(:one)
  end

  test 'visiting the index' do
    visit individuals_url
    assert_selector 'h1', text: 'Individuals'
  end

  test 'creating a Individual' do
    visit individuals_url
    click_on 'New Individual'

    click_on 'Create Individual'

    assert_text 'Individual was successfully created'
    click_on 'Back'
  end

  test 'updating a Individual' do
    visit individuals_url
    click_on 'Edit', match: :first

    click_on 'Update Individual'

    assert_text 'Individual was successfully updated'
    click_on 'Back'
  end

  test 'destroying a Individual' do
    visit individuals_url
    page.accept_confirm do
      click_on 'Destroy', match: :first
    end

    assert_text 'Individual was successfully destroyed'
  end
end

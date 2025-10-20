# frozen_string_literal: true

require 'test_helper'

class UmdSearchStateTest < ActionController::TestCase
  setup do
    @blacklight_config = Blacklight::Configuration.new
    @params = ActionController::Parameters.new
    @controller = nil
  end

  test 'identifier searches with "https" should be rewritten so "http" or "https" is found' do
    @params['search_field'] = 'identifier'
    @params['q'] = +'https://handle.example.org/1903.1/18' # +<str> to "unfreeze" string

    umd_search_state = UmdSearchState.new(@params, @blacklight_config, @controller)

    assert_equal('http*://handle.example.org/1903.1/18', umd_search_state.params['q'])
  end

  test 'identifier searches with "http" should be rewritten so "http" or "https" is found' do
    @params['search_field'] = 'identifier'
    @params['q'] = +'http://handle.example.org/1903.1/18' # +<str> to "unfreeze" string

    umd_search_state = UmdSearchState.new(@params, @blacklight_config, @controller)

    assert_equal('http*://handle.example.org/1903.1/18', umd_search_state.params['q'])
  end

  test 'other searches are not rewritten' do
    @params['search_field'] = 'text'
    @params['q'] = +'https://handle.example.org/1903.1/18' # +<str> to "unfreeze" string

    umd_search_state = UmdSearchState.new(@params, @blacklight_config, @controller)
    assert_equal('https://handle.example.org/1903.1/18', umd_search_state.params['q'])
  end
end

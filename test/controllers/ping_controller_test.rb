# frozen_string_literal: true

require 'test_helper'

class PingControllerTest < ActionController::TestCase
  test 'ping service can be accessed without logging in' do
    # Verify that no user is logged in.
    assert session[:cas].nil?

    get :verify
    assert_response(:success)
  end
end

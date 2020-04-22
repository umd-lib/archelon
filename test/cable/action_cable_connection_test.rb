# frozen_string_literal: true

require 'test_helper'

module ApplicationCable
  class ConnectionTest < ActionCable::Connection::TestCase
    test 'connection is created for valid users' do
      cookies.signed[:cas_user] = 'test_user'

      # Simulate a connection
      connect

      # Asserts that the connection identifier is correct
      assert_equal 'test_user', connection.current_user.cas_directory_id
    end

    test 'connection is not created for nonexistent user' do
      cookies.signed[:cas_user] = 'user_does_not_exist'

      # Simulate a connection
      assert_reject_connection do
        connect
      end
    end

    test 'does not connect without user' do
      # Simulate a connection
      assert_reject_connection do
        connect
      end
    end
  end
end
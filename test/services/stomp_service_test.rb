# frozen_string_literal: true

require 'test_helper'

class StompServiceTest < Minitest::Test
  def setup
    @destination = 'jobs_synchronous'
    @body = ''
    @headers = {}
    @receive_timeout = 5

    # Default mock setup
    Stomp::Connection.any_instance.stub(:receive).and_return(nil)
    Stomp::Connection.any_instance.stub(:publish).and_return(nil)
    Stomp::Connection.any_instance.stub(:subscribe).and_return(nil)
  end

  def test_stomp_service_raises_error_when_max_reconnect_attempts_fail
    allow(Stomp::Connection).to receive(:new).and_raise(Stomp::Error::MaxReconnectAttempts)

    exception = assert_raises(MessagingError) do
      StompService.synchronous_message(@destination, @body, @headers, @receive_timeout)
    end

    assert_match 'Unable to connect', exception.message
  end

  def test_stomp_service_raises_error_when_a_nil_message_is_received
    Stomp::Connection.any_instance.stub(:receive).and_return(nil)

    exception = assert_raises(MessagingError) do
      StompService.synchronous_message(@destination, @body, @headers, @receive_timeout)
    end

    assert_match 'No message received', exception.message
  end

  def test_stomp_service_raises_error_when_timeout_occurs
    Stomp::Connection.any_instance.stub(:receive).and_raise(Timeout::Error)

    exception = assert_raises(MessagingError) do
      StompService.synchronous_message(@destination, @body, @headers, @receive_timeout)
    end

    assert_match(/No message received in .* seconds/, exception.message)
  end
end

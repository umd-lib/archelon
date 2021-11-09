# frozen_string_literal: true

# Wrapper service for publishing messages to STOMP destinations
class StompService
  def self.create_connection
    Stomp::Connection.new(
      hosts: [STOMP_SERVER],
      max_reconnect_attempts: 1
    )
  end

  # Sends a message to Plastron and waits for a response
  #
  # Will wait up to "receive_timeout" (in seconds) for a response, which
  # defaults to 2 minutes.
  #
  # Throws a Timeout::Error if the response timeout expires
  def self.synchronous_message(destination, body, headers, receive_timeout = 120) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/LineLength
    destination_queue = STOMP_CONFIG['destinations'][destination.to_s]
    receive_queue = '/temp-queue/synchronous'

    Rails.logger.info("Publishing message synchronously to #{destination_queue}")

    begin
      connection = create_connection
    rescue Stomp::Error::MaxReconnectAttempts
      Rails.logger.error('Unable to connect to STOMP server')
      raise MessagingError('Unable to connect to STOMP server.')
    end

    connection.subscribe(receive_queue)
    headers['reply-to'] = receive_queue
    headers['PlastronJobId'] = "SYNCHRONOUS-#{SecureRandom.uuid}"
    connection.publish(destination_queue, body, headers)

    begin
      Timeout.timeout(receive_timeout) do
        stomp_message = connection.receive
        raise MessagingError('No message received') if stomp_message.nil?

        return PlastronMessage.new(stomp_message)
      rescue Timeout::Error
        raise MessagingError("No message received in #{receive_timeout} seconds. #{t('resource_update_timeout_error')}")
      ensure
        connection.disconnect
      end
    end
  end
end

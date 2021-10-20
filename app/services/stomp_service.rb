# frozen_string_literal: true

# Wrapper service for publishing messages to STOMP destinations
class StompService
  def self.create_connection
    Stomp::Connection.new(
      hosts: [STOMP_SERVER],
      max_reconnect_attempts: 1
    )
  end

  def self.publish_message(destination, body, headers)
    destination = STOMP_CONFIG['destinations'][destination.to_s]
    Rails.logger.info("Publishing message to #{destination}")
    connection = create_connection
    connection.publish(destination, body, headers)
  rescue RuntimeError => e
    # Catch all runtime exceptions and indicate failure to publish the message
    # TODO: retry failed publish and/or implement asynchronous store-and-forward
    Rails.logger.error("Error while communicating with STOMP server: #{e}")
    false
  else
    # no errors when connecting or publishing; disconnect and indicate success
    connection.disconnect
    true
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

    connection = create_connection
    connection.subscribe(receive_queue)
    headers['reply-to'] = receive_queue
    headers['PlastronJobId'] = "SYNCHRONOUS-#{SecureRandom.uuid}"
    connection.publish(destination_queue, body, headers)

    Timeout.timeout(receive_timeout) do
      msg = connection.receive
      return msg
    end
  rescue Stomp::Error::MaxReconnectAttempts
    Rails.logger.error('Unable to connect to STOMP server')
    'Unable to connect to STOMP server.'
  ensure
    connection&.disconnect
  end
end

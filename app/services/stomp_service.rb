# frozen_string_literal: true

# Wrapper service for publishing messages to STOMP destinations
class StompService
  def self.publish_message(destination, body, headers)
    destination = STOMP_CONFIG['destinations'][destination.to_s]
    Rails.logger.info("Publishing message to #{destination}")
    connection = Stomp::Connection.new(hosts: [STOMP_SERVER], max_reconnect_attempts: 1)
    connection.publish(destination, body, headers)
    connection.disconnect
    true
  rescue Stomp::Error::MaxReconnectAttempts
    Rails.logger.error('Unable to connect to STOMP server')
    false
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

    connection = Stomp::Connection.new(hosts: [STOMP_SERVER], max_reconnect_attempts: 1)
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

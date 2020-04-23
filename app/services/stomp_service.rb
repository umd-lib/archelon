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
end

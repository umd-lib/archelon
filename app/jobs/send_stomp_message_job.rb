# frozen_string_literal: true

# Submit a message to the external message queue via STOMP
class SendStompMessageJob < ApplicationJob
  attr_reader :request

  queue_as :default
  retry_on(MessagingError, wait: :exponentially_longer, attempts: STOMP_CONFIG[:max_retry_attempts]) do |job, _error|
    # all retry attempts have failed; message publication failed
    job.request.error!
  end

  def perform(destination, request)
    @request ||= request
    publish_message(destination, request.headers, request.body)
    request.submitted!
  end

  private

    def create_connection
      Stomp::Connection.new(
        hosts: [STOMP_SERVER],
        max_reconnect_attempts: STOMP_CONFIG[:max_reconnect_attempts]
      )
    end

    def publish_message(destination, headers, body)
      Rails.logger.info("Publishing message to #{destination}")
      connection = create_connection
      connection.publish(destination, body, headers)
    rescue RuntimeError => e
      # catch all runtime exceptions and indicate failure to publish the message
      Rails.logger.error("Error while communicating with STOMP server: #{e}")
      raise MessagingError
    else
      # no errors when connecting or publishing; disconnect
      connection.disconnect
    end
end

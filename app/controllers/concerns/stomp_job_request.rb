# frozen_string_literal: true

# Mix-in for controllers that need to send STOMP job requests
module StompJobRequest
  extend ActiveSupport::Concern

  included do
    def submit_job_request(job, request)
      publish_message(STOMP_CONFIG['destinations'][:jobs], request.headers, request.body)
      request.submitted!
    rescue MessagingError
      job.export_error!
    end
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
    ensure
      # always disconnect
      connection.disconnect
    end
end

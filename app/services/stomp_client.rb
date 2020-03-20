# frozen_string_literal: true

# Provides Stomp messaging, including handling subscription to queues
class StompClient
  include Singleton

  # Initializes the client, and subscribes to queues
  def initialize
    connect max_reconnect_attempts: 10
  end

  def connect(opts = {})
    stomp_server = { host: STOMP_CONFIG['host'], port: STOMP_CONFIG['port'] }
    Rails.logger.debug "Initializing STOMP client with server: #{stomp_server}"
    begin
      @stomp_client = Stomp::Client.new(hosts: [stomp_server], **opts)
      subscribe
    rescue Stomp::Error::MaxReconnectAttempts
      Rails.logger.error "Unable to connect to STOMP message broker at #{stomp_server}"
    end
  end

  def subscribe
    export_jobs_completed_queue = STOMP_CONFIG['export_jobs_completed_queue']
    Rails.logger.debug "STOMP client subscribing to #{export_jobs_completed_queue}"
    @stomp_client.subscribe export_jobs_completed_queue do |stomp_msg|
      update_export_job(stomp_msg)
    end
  end

  # Checks if the client is connected
  def connected?
    @stomp_client && !@stomp_client.closed?
  end

  # Publishes the given message to the given destination with the given
  # headers.
  def publish(destination, message, headers = {})
    @stomp_client.publish destination, message, headers
  end

  # Updates ExportJob based on a Stomp message
  def update_export_job(stomp_msg)
    message = PlastronMessage.new(stomp_msg)
    Rails.logger.info "Updating export job #{message.job_id}"
    export_job = ExportJob.from_uri(message.job_id)
    export_job.mark_as_completed(message.headers['PlastronJobStatus'])
    export_job.download_url = message.body_json['download_uri']
    export_job.save!
  end
end

# Convenience class for Plastron STOMP messages
class PlastronMessage
  attr_reader :headers, :body, :job_id

  def initialize(stomp_msg)
    @headers = stomp_msg.headers
    @body = stomp_msg.body
    @job_id = @headers['PlastronJobId']
  end

  # Parse the message body as JSON and return the result.
  def body_json
    JSON.parse(@body)
  end
end

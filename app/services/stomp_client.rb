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
    jobs_completed_queue = STOMP_CONFIG['destinations']['jobs_completed']
    Rails.logger.debug "STOMP client subscribing to #{jobs_completed_queue}"
    @stomp_client.subscribe jobs_completed_queue do |stomp_msg|
      update_job_status(stomp_msg)
    end

    job_status_topic = STOMP_CONFIG['destinations']['job_status']
    Rails.logger.debug "STOMP client subscribing to #{job_status_topic}"
    @stomp_client.subscribe job_status_topic do |stomp_msg|
      update_job_progress(stomp_msg)
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

  # Updates job status based on a Stomp message
  def update_job_status(stomp_msg)
    message = PlastronMessage.new(stomp_msg)
    Rails.logger.debug "Updating job status for #{message.job_id}"
    job_from_uri(message.job_id).update_status(message)
  end

  # Updates job status based on a Stomp message
  def update_job_progress(stomp_msg)
    message = PlastronMessage.new(stomp_msg)
    Rails.logger.debug "Updating job progress for #{message.job_id}"
    job_from_uri(message.job_id).update_progress(message)
  end

  # Get a job model instance from a URI
  def job_from_uri(uri)
    route = Rails.application.routes.recognize_path(uri)
    model_class = route[:controller].classify.constantize
    model_class.find(route[:id])
  end
end

# Convenience class for Plastron STOMP messages
class PlastronMessage
  attr_reader :headers, :body, :job_id

  def initialize(stomp_msg)
    @headers = stomp_msg.headers.with_indifferent_access
    @body = stomp_msg.body
    @job_id = @headers['PlastronJobId']
  end

  # Parse the message headers as JSON and return the result.
  def headers_json
    @headers.to_json
  end

  # Parse the message body as JSON and return the result.
  def body_json
    JSON.parse(@body)
  end
end

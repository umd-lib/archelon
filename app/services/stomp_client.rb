# frozen_string_literal: true

# Provides Stomp messaging, including handling subscription to queues
class StompClient
  # Returns the singleton instance
  def self.instance
    @@instance ||= new # rubocop:disable Style/ClassVars
  end

  private_class_method :new

  # Initializes the client, and subscribes to queues
  def initialize
    connect max_reconnect_attempts: 10
  end

  def connect(opts = {})
    stomp_server = Rails.configuration.stomp_server
    Rails.logger.debug "Initializing STOMP client with server: #{stomp_server}"
    begin
      @stomp_client = Stomp::Client.new(hosts: [stomp_server], **opts)
      subscribe
    rescue Stomp::Error::MaxReconnectAttempts
      Rails.logger.error "Unable to connect to STOMP message broker at #{stomp_server}"
    end
  end

  def subscribe
    export_jobs_completed_queue = Rails.configuration.queues[:export_jobs_completed]
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
    Rails.logger.debug 'Updating export job'
    headers = stomp_msg.headers
    export_job_id = headers['ArchelonExportJobId']
    export_job = ExportJob.find(export_job_id)
    export_job_status = headers['ArchelonExportJobStatus']
    export_job.status = export_job_status
    export_job.download_url = headers['ArchelonExportJobDownloadUrl']
    export_job.save
  end
end

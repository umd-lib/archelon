# frozen_string_literal: true

# Convenience class for Plastron STOMP messages
class PlastronMessage
  attr_reader :headers, :body

  def initialize(stomp_msg)
    @headers = stomp_msg.headers.with_indifferent_access
    @body = stomp_msg.body
  end

  def job_id
    @headers[:PlastronJobId]
  end

  def job_state
    @headers[:PlastronJobState]
  end

  def error?
    @headers.key?(:PlastronJobError)
  end

  def ok?
    !error?
  end

  # Parse the message body as JSON and return the result.
  def body_json
    return nil if @body.blank?

    @body_json ||= JSON.parse(@body)
  end

  def state
    body_json['type']
  end

  # Use the PlastronJobId to find the ImportJob or ExportJob object
  def find_job
    route = Rails.application.routes.recognize_path(job_id)
    model_class = route[:controller].classify.constantize
    model_class.find(route[:id])
  end
end

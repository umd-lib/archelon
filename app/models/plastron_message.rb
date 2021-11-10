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

  # Parses the JSON body of the message, and returns a list of errors, or
  # an empty list if there are no errors.
  #
  # Validation errors from Plastron are expected to look like:
  # "('<name>', '<status>', '<rule>', '<expected>')". These errors are parsed
  # into a Map with "name", "status", "rule", and "expected" keys.
  #
  # Other errors (such as a timeout error) are just a simple string, and
  # are parsed into a Map that contains an "error" key.
  def parse_errors(resource_id) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    stats = body_json['stats']
    validation_errors = stats['invalid'][resource_id]
    other_errors = stats['errors'][resource_id]
    errors = []

    [*validation_errors, *other_errors].each do |str|
      str = str.strip.gsub('(', '').gsub(')', '').gsub("'", '')
      arr = str.split(',').each(&:strip!)

      if arr.length == 4
        h = { name: arr[0], status: arr[1], rule: arr[2], expected: arr[3] }
        # Workaround - "alternative" from Plastron should be "alternate_title"
        h[:name] = 'alternate_title' if h[:name] == 'alternative'
      else
        h = { error: str }
      end
      errors.append(h)
    end
    errors
  end
end

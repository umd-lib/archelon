# frozen_string_literal: true

# Parses the Plastron response for metadata import job.
class ImportJobResponse
  attr_reader :server_error, :num_total, :num_updated, :num_unchanged,
              :num_valid, :num_invalid, :num_error, :invalid_lines,
              :json_headers, :json_body

  def initialize(response_headers, response_body) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/LineLength
    @valid = false
    @server_error = nil
    @num_total = 0
    @num_updated = 0
    @num_unchanged = 0
    @num_valid = 0
    @num_invalid = 0
    @num_error = 0
    @invalid_lines = []

    if response_headers.nil?
      @server_error = :invalid_response_from_server
      return
    end

    begin
      @json_headers = JSON.parse(response_headers)
    rescue JSON::ParserError
      @server_error = :invalid_response_from_server
      return
    end

    if response_body.nil?
      @server_error = :invalid_response_from_server
      return
    end

    begin
      @json_body = JSON.parse(response_body)
    rescue JSON::ParserError
      @server_error = :invalid_response_from_server
      return
    end

    count_hash = @json_body['count']
    if count_hash.nil?
      @server_error = :invalid_response_from_server
      return
    end

    begin
      @num_total = Integer(count_hash['total'] || '')
      @num_updated = Integer(count_hash['updated'] || '')
      @num_unchanged = Integer(count_hash['unchanged'] || '')
      @num_valid = Integer(count_hash['valid'] || '')
      @num_invalid = Integer(count_hash['invalid'] || '')
      @num_error = Integer(count_hash['errors'] || '')
    rescue ArgumentError
      @server_error = :invalid_response_from_server
      return
    end

    @valid = @num_valid.positive? && @num_invalid.zero? && @num_error.zero?

    return if @valid

    validations = @json_body['validation']

    return unless validations

    validations.each do |v|
      validation = ImportJobLineValidation.new(v)

      # Skip any lines without validation errors
      next if validation.valid?

      invalid_lines << validation
    end
  end

  def valid?
    @valid
  end

  def server_error?
    !@server_error.nil?
  end

  # Returns a pretty-printed JSON string representing the response headers,
  # or an empty string if the headers could not be parsed.
  def headers_pretty_print
    return '' if @json_headers.blank?

    begin
      JSON.pretty_generate(@json_headers)
    rescue StandardError => e
      Rails.logger.warn "Could not parse response headers from server: #{e.message}"
      ''
    end
  end

  # Returns a pretty-printed JSON string representing the response body,
  # or an empty string if the body could not be parsed.
  def body_pretty_print
    return '' if @json_body.blank?

    begin
      JSON.pretty_generate(@json_body)
    rescue StandardError => e
      Rails.logger.warn "Could not parse response body from server: #{e.message}"
      ''
    end
  end
end

# Parses the Plastron response regarding the validity of individual lines
# in the import file
class ImportJobLineValidation
  attr_reader :line_location, :line_error, :field_errors

  def initialize(validation) # rubocop:disable Metrics/MethodLength
    @line_location = validation['line']

    # Strip '<>:' from line location, if present
    empty_file = '<>:'
    @line_location = @line_location[empty_file.length..] if @line_location.start_with?(empty_file)

    @valid = validation['is_valid']
    @line_error = validation['error']

    @field_errors = []
    failures = validation['failed']

    return if failures.nil?

    failures.each do |failure|
      @field_errors << failure[0]
    end
  end

  def valid?
    @valid
  end

  def line_error?
    !@line_error.nil?
  end

  def field_errors?
    @field_errors.any?
  end
end

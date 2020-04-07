class ImportJobResponse
  attr_reader :server_error, :num_total, :num_updated, :num_unchanged,
              :num_valid, :num_invalid, :num_error, :invalid_lines

  def initialize(response_message)
    @valid = false
    @server_error = nil
    @num_total = 0
    @num_updated = 0
    @num_unchanged = 0
    @num_valid = 0
    @num_invalid = 0
    @num_error = 0
    @invalid_lines = []

    if response_message.nil?
      @server_error = :invalid_response_from_server
      return
    end

    begin
      msg = JSON.parse(response_message)
    rescue JSON::ParserError
      @server_error = :invalid_response_from_server
      return
    end

    count_hash = msg['count']
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

    validations = msg['validation']

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
end

class ImportJobLineValidation
  attr_reader :line_location, :line_error, :field_errors

  def initialize(validation)
    @line_location = validation['line']
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
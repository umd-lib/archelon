# frozen_string_literal: true

# Encapsulates the response from a REST endpoint returning JSON
class JsonRestResult
  attr_reader :raw_json, :parsed_json, :error_message

  def initialize(raw_json: nil, parsed_json: nil, error_message: nil)
    @raw_json = raw_json
    @parsed_json = parsed_json
    @error_message = error_message
  end

  def self.create_error_result(error_message)
    # Creates a JsonRestResult describing an error communicating with the
    # endpoint.
    JsonRestResult.new(error_message: error_message)
  end

  def self.create_from_json(json)
    # Creates a JsonResultResult with JSON parsed to a Ruby hash
    parsed_json = nil
    begin
      parsed_json = JSON.parse(json)
    rescue StandardError => e
      return JsonRestResult.new(error_message: e.to_s)
    end
    JsonRestResult.new(raw_json: json, parsed_json: parsed_json)
  end

  def error_occurred?
    !@error_message.nil?
  end
end

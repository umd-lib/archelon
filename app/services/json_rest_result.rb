# frozen_string_literal: true

# Encapsulates the response from a REST endpoint returning JSON
#
# A Hash of the parsed JSON is available from the "parsed_json" attribute.
# If an error has occurred, the "error_occurred?" method returns true,
# and the error message is available in the "error_message" attribute.
class JsonRestResult
  attr_reader :raw_json, :parsed_json, :error_message

  def initialize(raw_json: nil, parsed_json: nil, error_message: nil)
    # NOTE: Consider using the "create_from_json" or "create_error_result"
    # methods, insted of creating this object directly.
    @raw_json = raw_json
    @parsed_json = parsed_json
    @error_message = error_message
  end

  # Returns a JsonResultResult with JSON parsed to a Ruby hash
  def self.create_from_json(json)
    parsed_json = nil
    begin
      parsed_json = JSON.parse(json)
    rescue StandardError => e
      Rails.logger.error("Error parsing JSON. e=#{e}")
      return JsonRestResult.new(error_message: e.to_s)
    end
    JsonRestResult.new(raw_json: json, parsed_json: parsed_json)
  end

  # Returns a JsonRestResult describing an error communicating with the
  # endpoint.
  def self.create_error_result(error_message)
    JsonRestResult.new(error_message: error_message)
  end

  def error_occurred?
    !@error_message.nil?
  end
end

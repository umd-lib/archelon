# frozen_string_literal: true

# Encapsulates information from the Plastron "jobs" endpoint.
#
# If an error has occurred, the "error_occurred?" method returns true,
# and the error message is available in the "error_message" attribute.
class ImportJobInfo
  attr_reader :completed, :failed, :invalid, :total

  def initialize(json_rest_result)
    # Constructed from a JsonRestResult object
    @json_rest_result = json_rest_result
    parsed_json = json_rest_result.parsed_json

    @completed = parsed_json&.dig('completed', 'items') || []
    @failed = parsed_json&.dig('dropped', 'failed', 'items') || []
    @invalid = parsed_json&.dig('dropped', 'invalid', 'items') || []
    @total = parsed_json&.dig('total') || 0
  end

  delegate :error_message, to: :json_rest_result
  delegate :error_occurred?, to: :json_rest_result

  private

    attr_reader :json_rest_result
end

# frozen_string_literal: true

# Encapsulates information from the Platron "jobs" endpoint
class ImportJobInfo
  attr_reader :completed, :total, :error_message

  def initialize(json_rest_result)
    @json_rest_result = json_rest_result
    parsed_json = json_rest_result.parsed_json

    if parsed_json.present?
      @completed = parsed_json.dig('completed', 'items')
      @total = parsed_json.dig('total')
    end

    @completed = [] if @completed.blank?
    @total = 0 if @total.blank?
  end

  delegate :error_message, to: :json_rest_result
  delegate :error_occurred?, to: :json_rest_result

  private

    attr_reader :json_rest_result
end

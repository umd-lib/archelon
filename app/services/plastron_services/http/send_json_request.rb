# frozen_string_literal: true

module PlastronServices
  module HTTP
    # Service class that sends JSON requests to an \HTTP endpoint.
    class SendJSONRequest
      def initialize(url:, method: :get, content: nil)
        @url = url
        @method = method
        @content = content || {}
      end

      # JSON-encodes the `content` and sends an \HTTP request (of type `method`:
      # `:get`, `:post`, etc.) to `url`. Returns a JsonRestResult.
      def call # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        body = @content.to_json
        Rails.logger.info("Sending #{body} to #{@url} using #{@method.upcase}")
        response = ::HTTP.headers(content_type: 'application/json').request(@method, @url, body: body)
        Rails.logger.info(response.status)
        raise response.status.reason unless response.status.success?

        JsonRestResult.create_from_json(response.body.to_s)
      rescue ::HTTP::ConnectionError => e
        Rails.logger.error(e)
        JsonRestResult.create_error_result("Unable to send request: #{e}")
      rescue StandardError => e
        Rails.logger.error(e)
        JsonRestResult.create_error_result(e.to_s)
      end
    end
  end
end

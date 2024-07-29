# frozen_string_literal: true

module PlastronServices
  module Http
    # Service class to send a single ActivityStream message to the inbox endpoint
    # of the Plastron HTTP server. The base URL of the endpoint is configured via
    # the `PLASTRON_REST_BASE_URL` environment variable. The inbox endpoint is
    # derived by adding the path "inbox" to the base URL.
    class SendActivityStreamMessage
      def initialize(message)
        @message = message
      end

      # Send the message. By default, uses the SendJSONRequest service class,
      # but this can be overridden by setting `sender` to another service class.
      # The other sender class must accept `method`, `url`, and `content`
      # parameters in the constructor, and have a `call` method that returns
      # a JsonRestResult object.
      def call(sender: SendJsonRequest)
        sender.new(method: :post, url: inbox_url, content: @message).call
      end

      private

        def base_url
          ENV['PLASTRON_REST_BASE_URL']
        end

        def inbox_url
          Addressable::URI.join(base_url, 'inbox')
        end
    end
  end
end

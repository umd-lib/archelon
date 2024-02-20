# frozen_string_literal: true

module PlastronServices
  module HTTP
    # Base class for publication actions. Subclasses must implement
    # the #activity_type method to return the URI of their specific
    # activity type.
    class PublicationCommand
      def initialize(uri:, user:)
        @uri = uri
        @user = user
      end

      # URI of the specific activity type. In this class, this method
      # raises an exception; subclasses are expected to override this
      # method.
      def activity_type
        raise 'not implemented'
      end

      # Hash representation of the ActivityStream message that will
      # be sent.
      def message
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          type: activity_type,
          actor: "acct:#{@user.cas_directory_id}@umd.edu",
          object: @uri
        }
      end

      # Send the #message. By default, uses the SendActivityStreamMessage
      # service class as the sender, but this can be changed by setting
      # the `sender` parameter to a different service class that implements
      # a `call` method.
      def call(sender: PlastronServices::HTTP::SendActivityStreamMessage)
        # sender is parameterized for easy testing
        sender.new(message).call
      end
    end
  end
end

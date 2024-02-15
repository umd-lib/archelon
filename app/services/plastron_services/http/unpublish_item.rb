# frozen_string_literal: true

module PlastronServices
  module HTTP
    # Command to unpublish an item
    class UnpublishItem < PublicationCommand
      def activity_type
        'http://vocab.lib.umd.edu/activity#Unpublish'
      end
    end
  end
end

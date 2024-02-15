# frozen_string_literal: true

module PlastronServices
  module HTTP
    # Command the publish an item
    class PublishItem < PublicationCommand
      def activity_type
        'http://vocab.lib.umd.edu/activity#Publish'
      end
    end
  end
end

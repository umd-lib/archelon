# frozen_string_literal: true

module PlastronServices
  module HTTP
    # Command the publish an item but hide it from search results
    class PublishHiddenItem < PublicationCommand
      def activity_type
        'http://vocab.lib.umd.edu/activity#PublishHidden'
      end
    end
  end
end

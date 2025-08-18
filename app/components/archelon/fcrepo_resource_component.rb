# frozen_string_literal: true

module Archelon
  # Blacklight::Component implementation that adds item details from fcrepo
  # in the unused "embed" slot in Blacklight 8, configurable via configurable
  # via the “config.show.embed_component” configuration parameter in
  # “app/controllers/catalog_controller.rb”.
  # This implementation is likely *not* optimal.
  class FcrepoResourceComponent < Blacklight::Component
    def initialize(document: nil, presenter: nil, document_counter: nil)
      super
      @document = document
    end
  end
end

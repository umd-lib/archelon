# frozen_string_literal: true

module Archelon
  class FcrepoResourceComponent < Blacklight::Component

    def initialize(document: nil, presenter: nil, document_counter: nil)
      @document = document
    end
  end
end

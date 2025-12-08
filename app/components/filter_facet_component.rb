# frozen_string_literal: true

require 'securerandom'

# Basic Facet Component but you can also filter the list
class FilterFacetComponent < Blacklight::FacetFieldListComponent
  def initialize(**)
    super
    @uuid = SecureRandom.uuid
  end
end

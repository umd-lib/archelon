# frozen_string_literal: true

# Data class encapsulating a single vocabulary term
class VocabularyTerm
  attr_reader :identifier, # The simple human-readable identifier for the term, typically "dc:identifier"
              :uri,        # Tne URI for the term (typically http://vocab.lib.umd.edu/<identifier>#)
              :label,      # The "rdfs:label" for the term (may be nil)
              :same_as     # The "'owl:sameAs" id for the term (may be nil)

  # Creates a VocabularyTerm with the given parameters
  def initialize(identifier:, uri:, label:, same_as:)
    @identifier = identifier
    @uri = uri
    @label = label
    @same_as = same_as
  end
end

# frozen_string_literal: true

# Data class encapsulating a single Vocabulary
class Vocab
  # The simple human-readable identifier for the vocabulary
  attr_reader :identifier

  # A (possibly empty) list of VocabTerm objects the terms for the vocabulary
  attr_reader :terms

  # Creates a new Vocab object with the given identifier and terms
  def initialize(identifier, terms)
    @identifier = identifier
    @terms = terms
  end

  # Returns the VocabTerm in the vocabulary for the given URI, or nil if
  # the URI is not found
  def term(term_uri)
    id = term_uri.delete_prefix(uri)
    terms.find { |term| term.identifier == id }
  end

  # Returns the URI for this vocabulary
  def uri
    VOCAB_CONFIG['local_authority_base_uri'] + identifier + '#'
  end
end

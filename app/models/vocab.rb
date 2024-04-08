# frozen_string_literal: true

# A controlled vocabulary that contains uris and terms
class Vocab
  attr_accessor :identifier

  def initialize(identifier)
    @identifier = identifier
    @options_hash = VocabService.vocab_options_hash_by_identifier(identifier)
  end

  def self.find_by(identifier:)
    Vocab.new(identifier)
  end

  def self.all
    known_vocabulary_ids = %w[
      access collection datatype form model rightsStatement set
    ]

    known_vocabulary_ids.map { |id| Vocab.new(id) }
  end

  def self.[](identifier)
    VocabService.vocab_options_hash_by_identifier(identifier)
    # vocab = find_by(identifier: identifier)
    # vocab.nil? ? {} : vocab.as_hash
  end

  def as_hash
    @options_hash
    # Hash[terms.map do |term|
    #   [term.uri, term.respond_to?(:label) ? term.label : term.identifier]
    # end]
  end

  def terms
    as_hash.map { |key, value| OpenStruct.new(uri: key, identifier: value, label: value) }
    # individuals + types + datatypes
  end

  def term(term_uri)
    id = term_uri.delete_prefix(uri)
    terms.find { |term| term.identifier == id }
  end

  def uri
    VOCAB_CONFIG['local_authority_base_uri'] + identifier + '#'
  end

  def published_uri
    VOCAB_CONFIG['publication_base_uri'] + identifier + '.json'
  end

  def term_count
    terms.count
  end
end

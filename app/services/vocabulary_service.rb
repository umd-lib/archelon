# frozen_string_literal: true

# Queries a Vocabulary server at VOCAB_CONFIG['local_authority_base_uri']
# for vocabulary information
class VocabularyService
  # Returns a Vocab object for the given identifier
  # A Vocab object will always be returned, but will contain an empty
  # "terms" field, if the vocabulary cannot be found, or an error occurs
  # retrieving the vocabulary.
  def self.get_vocabulary(identifier)
    url = generate_url(identifier)
    json_rest_result = retrieve(url)
    terms = parse(json_rest_result)
    Vocabulary.new(identifier, terms)
  end

  # Returns either an empty hash, or an options hash of terms indexed by their
  # Local URI for the given content model field.
  #
  # The returned hash will be filtered to contain only the terms listed in the
  # "terms" field of the content model field (if present), otherwise all the
  # terms in the vocabulary will be returned.
  #
  # The returned hash is suitable for use in the "vocab" field of the
  # ControlledURIRef React component.
  def self.vocab_options_hash(content_model_field)
    return {} unless valid?(content_model_field)

    vocab_identifier = content_model_field[:vocab]
    allowed_terms = content_model_field[:terms]

    Rails.logger.info("vocab_identifier='#{vocab_identifier}', allowed_terms='#{allowed_terms}'")

    vocab = VocabularyService.get_vocabulary(vocab_identifier)

    filtered_terms = filter_terms(vocab.terms, allowed_terms)
    filtered_options = parse_options(filtered_terms)
    Rails.logger.debug { "filtered_options: #{filtered_options}" }

    filtered_options
  end

  # Parses the given terms, returning a Hash suitable for use in the "vocab"
  # field of the ControlledURIRef React component.
  def self.parse_options(terms)
    Hash[terms.map { |r| [r.uri, r.label] }]
  end

  class << self
    private

      # Returns true if the given content model field has the expected values,
      # false otherwise.
      def valid?(content_model_field)
        content_model_field.present? && content_model_field[:vocab].present?
      end

      # Returns the URL to query for the given identifier
      def generate_url(identifier)
        base_uri = VOCAB_CONFIG['local_authority_base_uri']
        base_uri = "#{base_uri}/" unless base_uri.end_with?('/')
        "#{base_uri}#{identifier}#"
      end

      # Returns a JsonRestResult from querying the given url
      def retrieve(url)
        Rails.logger.info("Retrieving vocabulary: url='#{url}'")

        send_json_request = SendJSONRequest.new(url: url, follow_redirects: true)
        json_rest_result = send_json_request.call

        Rails.logger.debug do
          "vocabulary retrieved: parsed_json=#{json_rest_result.parsed_json}," \
          "error_message='#{json_rest_result.error_message}'"
        end

        json_rest_result
      end

      # Parses the JSON result from the network requestm returning either an
      # empty array, or an array of VocabularyTerm objects.
      def parse(json_rest_result)
        return [] if json_rest_result.error_occurred?

        graph = json_rest_result.parsed_json['@graph']

        # @graph element exists for vocabularies with two or more elements
        return graph.map { |g| parse_entry(g) } if graph.present?

        # Single term vocabularies don't have "@graph" element, but do have
        # "@id" and (possibly) "@rdfs.label" elements, so we can just go
        # straight to the "parse_entry" function, and then wrap the result
        # in an array before converting into a hash
        [parse_entry(json_rest_result.parsed_json)]
      end

      # Filters a list of terms, only returning the terms whose "label"
      # attribute matches an entry in the the given allowed terms list
      def filter_terms(terms, allowed_terms)
        if allowed_terms.nil?
          Rails.logger.debug('Skipping filtering, as allowed_terms is nil')
          return terms
        end

        terms.select { |term| allowed_terms.include?(term.label) }
      end

      # Parses a single term from the graph, returning a VocabularyTerm object
      def parse_entry(graph_entry)
        id = graph_entry['@id']
        label = graph_entry['rdfs:label'].nil? ? id.split('#').last : graph_entry['rdfs:label']
        identifier = id.split('#').last
        same_as = graph_entry.dig('owl:sameAs', '@id')
        VocabularyTerm.new(uri: id, identifier: identifier, label: label, same_as: same_as)
      end
  end
end

# frozen_string_literal: true

# Queries a Vocabulary server at VOCAB_CONFIG['local_authority_base_uri']
# for vocabulary information
class VocabService
  # Returns either an empty hash, or an options hash of terms indexed by their
  # Local URI
  def self.vocab_options_hash(content_model_field)
    return {} unless valid?(content_model_field)

    vocab_identifier = content_model_field[:vocab]
    allowed_terms = content_model_field[:terms]

    Rails.logger.info("vocab_identifier='#{vocab_identifier}', allowed_terms='#{allowed_terms}'")

    all_options = VocabService.vocab_options_hash_by_identifier(vocab_identifier)

    filtered_options = filter_options(all_options, allowed_terms)
    Rails.logger.debug { "filtered_options: #{filtered_options}" }
    filtered_options
  end

  def self.vocab_options_hash_by_identifier(identifier)
    url = generate_url(identifier)
    json_rest_result = retrieve(url)
    parse_options(json_rest_result)
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

      # Parses a JsonRestResult, returning either an empty Hash (if any errors
      # have occurred), or an options hash of terms indexed by their Local URI
      def parse_options(json_rest_result)
        return {} if json_rest_result.error_occurred?

        graph = json_rest_result.parsed_json['@graph']

        # @graph element exists for vocabularies with two or more elements
        return Hash[graph.map { |g| parse_entry(g) }] if graph.present?

        # Single term vocabularies don't have "@graph" element, but do have
        # "@id" and (possibly) "@rdfs.label" elements, so we can just go
        # straight to the "parse_entry" function, and then wrap the result
        # in an array before converting into a hash
        Hash[[parse_entry(json_rest_result.parsed_json)]]
      end

      # Filters a map of parsed options, removing any entry whose term does
      # not match a term in the given list of allowed terms
      def filter_options(options, allowed_terms)
        if allowed_terms.nil?
          Rails.logger.debug('Skipping filtering, as allowed_terms is nil')
          return options
        end

        options.select { |_k, v| allowed_terms.include?(v) }
      end

      # Parses a single term from the graph, returns a two-part array
      # consisting of [@id, label]. If the graph entry does not contain
      # an "rdfs:label" value, a label value is generated from the @id
      # value.
      def parse_entry(graph_entry)
        id = graph_entry['@id']
        label = graph_entry['rdfs:label'].nil? ? id.split('#').last : graph_entry['rdfs:label']
        [id, label]
      end
  end
end
